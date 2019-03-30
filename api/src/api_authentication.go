/*
 * Doctors on Demand API
 */

package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"regexp"
	"strings"
	"time"

	"github.com/google/uuid"
)

var GenderEnum = struct {
	Male   string
	Female string
	Other  string
}{
	"Male",
	"Female",
	"Other",
}

type LoginModel struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LogoutModel struct {
	SessionID string `json:"sessionID"`
}

type AuthNav struct {
	Title      string `json:"title"`
	Icon       string `json:"icon"`
	APIURL     string `json:"apiURL"`
	ScreenType string `json:"screenType"`
}

type AuthResponse struct {
	SessionID string    `json:"sessionID"`
	Role      string    `json:"role"`
	Nav       []AuthNav `json:"nav"`
}

type ProfileModel struct {
	Role             string  `json:"role"`
	Name             string  `json:"name"`
	Address          string  `json:"address"`
	City             string  `json:"city"`
	State            *States `json:"state"`
	PostalCode       string  `json:"postalCode"`
	PharmacyLocation string  `json:"pharmacylocation"`
	Phone            string  `json:"phone"`
	Photo            string  `json:"photo"`
	SecretQuestion   string  `json:"secretQuestion"`
	SecretAnswer     string  `json:"secretAnswer"`
	DOB              string  `json:"dob"`
	Gender           string  `json:"gender"`
	// required for doctor sign-ups
	DoctorLicences     []SignupDoctorLicences `json:"doctorLicences,omitempty"`
	DoctorSpecialities []int                  `json:"doctorSpecialities,omitempty"`
}

type UpdateProfileModel struct {
	Name             string  `json:"name"`
	Password         string  `json:"password"`
	Address          string  `json:"address"`
	City             string  `json:"city"`
	State            *States `json:"state"`
	PostalCode       string  `json:"postalCode"`
	PharmacyLocation string  `json:"pharmacylocation"`
	Phone            string  `json:"phone"`
	Photo            string  `json:"photo"`
	SecretQuestion   string  `json:"secretQuestion"`
	SecretAnswer     string  `json:"secretAnswer"`
	DOB              string  `json:"dob"`
	Gender           string  `json:"gender"`
	// required for doctor sign-ups
	DoctorLicences     []SignupDoctorLicences `json:"doctorLicences,omitempty"`
	DoctorSpecialities []int                  `json:"doctorSpecialities,omitempty"`
}

type PasswordResetModel struct {
	Email          string `json:"email"`
	SecretQuestion string `json:"secretQuestion"`
	SecretAnswer   string `json:"secretAnswer"`
	NewPassword    string `json:"newPassword"`
}

type SignupPatientPharmacy struct {
	State    *States `json:"state"`
	Pharmacy string  `json:"pharmacy"`
}

type SignupDoctorLicences struct {
	State   *States `json:"state"`
	License string  `json:"license"`
}

type SignupModel struct {
	Email    string `json:"email"`
	Password string `json:"password"`
	// can only be patient or doctor
	Role             string  `json:"role"`
	Name             string  `json:"name"`
	Address          string  `json:"address"`
	City             string  `json:"city"`
	State            *States `json:"state"`
	PostalCode       string  `json:"postalCode"`
	PharmacyLocation string  `json:"pharmacylocation"`
	Phone            string  `json:"phone"`
	Photo            string  `json:"photo"`
	SecretQuestion   string  `json:"secretQuestion"`
	SecretAnswer     string  `json:"secretAnswer"`
	DOB              string  `json:"dob"`
	Gender           string  `json:"gender"`
	// required for doctor sign-ups
	DoctorLicences     []SignupDoctorLicences `json:"doctorLicences,omitempty"`
	DoctorSpecialities []int                  `json:"doctorSpecialities,omitempty"`
}

type DoctorSpecialities struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

func dbUserLogin(e string, p string) AuthResponse {
	dbUserClearSessions()

	db := getDB()
	if db == nil {
		return AuthResponse{}
	}
	defer db.Close()

	userIDSt, _ := db.Prepare("select USER_ID, ROLE, PASSW from `dod`.`USERS` u where u.`EMAIL` = ?")
	defer userIDSt.Close()

	var userID int
	var role, pHash string
	lisrerr := userIDSt.QueryRow(e).Scan(&userID, &role, &pHash)
	if lisrerr != nil {
		return AuthResponse{}
	}

	if checkPassword(p, pHash) == false {
		dbAuditAction(userID, "Login:Failure")
		return AuthResponse{}
	}

	sessionID, _ := uuid.NewUUID()

	sessionSt, _ := db.Prepare("insert into `dod`.`SESSIONS` (USER_ID, SESSION_ID, EXP_DT) values (?, ?, NOW() + INTERVAL 1 DAY)")
	_, sessionStErr := sessionSt.Exec(userID, sessionID)
	defer sessionSt.Close()
	if sessionStErr != nil {
		return AuthResponse{}
	}

	dbAuditAction(userID, "Login:Success")

	return AuthResponse{
		SessionID: sessionID.String(),
		Role:      role,
		Nav:       getNav(sessionID.String(), role),
	}
}

func dbUserLogout(s string) {
	dbUserClearSessions()

	db := getDB()
	if db == nil {
		return
	}
	defer db.Close()

	userIDSt, _ := db.Prepare("delete from dod.SESSIONS where `SESSION_ID` = ?")
	defer userIDSt.Close()

	//no audit needed here as logouts are not a security concern
	userIDSt.Exec(s)
}

func dbUserPasswordReset(p PasswordResetModel) (AuthResponse, error) {
	dbUserClearSessions()

	db := getDB()
	if db == nil {
		return AuthResponse{}, errors.New("Unable to connect to db")
	}
	defer db.Close()

	// validate inputs
	if p.Email == "" || p.SecretAnswer == "" || p.SecretQuestion == "" || p.NewPassword == "" {
		return AuthResponse{}, errors.New("Missing required fields")
	}
	if validatePassword(p.NewPassword) == false {
		return AuthResponse{}, errors.New("Password not complex enough")
	}

	//find the user
	userIDSt, _ := db.Prepare("select USER_ID, SECRET_Q, SECRET_A from `dod`.`USERS` u where u.`EMAIL` = ?")
	defer userIDSt.Close()

	var userID int
	var secretQ, secretA string
	lisrerr := userIDSt.QueryRow(p.Email).Scan(&userID, &secretQ, &secretA)
	if lisrerr != nil {
		dbAuditAction(userID, "ResetPassword:Failure")
		return AuthResponse{}, errors.New("Unable to reset password")
	}

	//check the secret question and answer
	if strings.TrimSpace(strings.ToLower(secretQ)) != strings.TrimSpace(strings.ToLower(p.SecretQuestion)) || strings.TrimSpace(strings.ToLower(secretA)) != strings.TrimSpace(strings.ToLower(p.SecretAnswer)) {
		dbAuditAction(userID, "ResetPassword:Failure")
		return AuthResponse{}, errors.New("Unable to reset password")
	}

	//create password hash
	passwd := hashPassword(p.NewPassword)

	//change password
	updatePWSt, _ := db.Prepare("UPDATE `dod`.`USERS` SET `PASSW` = ? WHERE `EMAIL` = ?")
	defer updatePWSt.Close()
	_, err := updatePWSt.Exec(passwd, p.Email)
	if err != nil {
		dbAuditAction(userID, "ResetPassword:Failure")
		return AuthResponse{}, errors.New("Internal error please try again later")
	}
	dbAuditAction(userID, "ResetPassword:Success")

	auth := dbUserLogin(p.Email, p.NewPassword)

	return auth, nil
}

func dbGetDoctorSpecialities() ([]DoctorSpecialities, error) {
	dbUserClearSessions()

	var resp []DoctorSpecialities
	db := getDB()
	if db == nil {
		return resp, errors.New("Unable to connect to db")
	}
	defer db.Close()

	specSt, _ := db.Prepare("SELECT `DOCTOR_SPECIALITY_ID`, `SPECIALITY` FROM `dod`.`DOCTOR_SPECIALITIES` ORDER BY `SPECIALITY` ASC")
	defer specSt.Close()
	rows, err := specSt.Query()
	if err != nil {
		return resp, errors.New("Unable to fetch doctor specialities")
	}
	for rows.Next() {
		var id int
		var name string
		if err := rows.Scan(&id, &name); err != nil {
			return resp, errors.New("Unable to fetch doctor speciality")
		}
		resp = append(resp, DoctorSpecialities{
			ID:   id,
			Name: name,
		})
	}
	return resp, nil
}

func dbUserSignup(sm SignupModel) (AuthResponse, error) {
	dbUserClearSessions()

	db := getDB()
	if db == nil {
		return AuthResponse{}, errors.New("Unable to connect to db")
	}
	defer db.Close()

	//check signup has valid data in it
	emailReg := regexp.MustCompile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
	if emailReg.MatchString(sm.Email) == false {
		return AuthResponse{}, errors.New("Invalid Email")
	}
	if sm.Address == "" {
		return AuthResponse{}, errors.New("Address is required")
	}
	if sm.City == "" {
		return AuthResponse{}, errors.New("City is required")
	}
	if sm.State == nil {
		return AuthResponse{}, errors.New("State is required")
	}
	if sm.PostalCode == "" {
		return AuthResponse{}, errors.New("Postal Code is required")
	}
	if sm.PharmacyLocation == "" {
		return AuthResponse{}, errors.New("Pharmacy Location is required")
	}
	if sm.Password == "" {
		return AuthResponse{}, errors.New("Password is required")
	}
	if validatePassword(sm.Password) == false {
		return AuthResponse{}, errors.New("Password not complex enough")
	}
	if sm.SecretQuestion == "" {
		return AuthResponse{}, errors.New("Secret Question is required")
	}
	if sm.SecretAnswer == "" {
		return AuthResponse{}, errors.New("Secret Answer is required")
	}
	if sm.Name == "" {
		return AuthResponse{}, errors.New("Name is required")
	}
	if sm.Phone == "" {
		return AuthResponse{}, errors.New("Phone is required")
	}
	if sm.DOB == "" {
		return AuthResponse{}, errors.New("DOB is required")
	}
	if sm.DOB == "" {
		return AuthResponse{}, errors.New("DOB is required")
	}
	_, err := time.Parse("2006-01-02", sm.DOB)
	if err != nil {
		return AuthResponse{}, errors.New("Invalid DOB format YYYY-MM-DD")
	}
	if sm.Gender == "" {
		return AuthResponse{}, errors.New("Gender is required")
	}
	if sm.Gender != GenderEnum.Female && sm.Gender != GenderEnum.Male && sm.Gender != GenderEnum.Other {
		return AuthResponse{}, errors.New("Gender can only be " + GenderEnum.Male + ", " + GenderEnum.Female + " or " + GenderEnum.Other)
	}
	if sm.Role == "" {
		return AuthResponse{}, errors.New("Role is required")
	}
	if sm.Role != "patient" && sm.Role != "doctor" {
		return AuthResponse{}, errors.New("Invalid Role selected")
	}
	if sm.DoctorLicences == nil && sm.Role == "doctor" {
		return AuthResponse{}, errors.New("Doctors must have one license")
	}
	if sm.DoctorLicences != nil && sm.Role == "doctor" {
		for _, lic := range sm.DoctorLicences {
			if lic.License == "" || lic.State == nil {
				return AuthResponse{}, errors.New("All Doctor Licenceses must include the number and state")
			}
		}
	}
	if sm.DoctorSpecialities != nil && sm.Role == "doctor" {
		for _, spec := range sm.DoctorSpecialities {
			if spec == 0 {
				return AuthResponse{}, errors.New("Doctor Speciality ids must be greater than 0")
			}
		}
	}

	//check to see if email is already in use
	emailSt, _ := db.Prepare("select count(1) from `dod`.`USERS` u where u.`EMAIL` = ?")
	defer emailSt.Close()
	var emailFound int
	emailSt.QueryRow(sm.Email).Scan(&emailFound)
	if emailFound > 0 {
		return AuthResponse{}, errors.New("Email already in use")
	}

	//setup data to insert
	pHash := hashPassword(sm.Password)
	signupSt, _ := db.Prepare("INSERT INTO `dod`.`USERS` (`CREATED_DT`,`ROLE`,`PASSW`,`NAME`,`EMAIL`,`ADDR`,`CITY`,`STATE`,`POSTAL_CODE`,`PHARM_LOC`,`PHONE`,`SECRET_Q`, `SECRET_A`, `PHOTO`, `DOB`, `GENDER`) VALUES (now(),?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
	defer signupSt.Close()
	signupRes, signupErr := signupSt.Exec(sm.Role, pHash, sm.Name, sm.Email, sm.Address, sm.City, sm.State, sm.PostalCode, sm.PharmacyLocation, sm.Phone, sm.SecretQuestion, sm.SecretAnswer, sm.Photo, sm.DOB, sm.Gender)
	if signupErr != nil {
		return AuthResponse{}, errors.New("Internal error please try again later")
	}
	userIDInt, signupResErr := signupRes.LastInsertId()
	userID := int(userIDInt)
	if signupResErr != nil {
		return AuthResponse{}, errors.New("Internal error for id please try again later")
	}

	//rollback handling
	rollback := false
	var errMsg error

	//handle doctor licenses if role doctor
	if sm.Role == "doctor" {
		//insert new license for doctor
		for _, lic := range sm.DoctorLicences {
			insertLicenseSt, _ := db.Prepare("INSERT INTO `dod`.`LICENSES` (`LICENSE_ID`,`STATE`,`USER_ID`) VALUES (?,?,?)")
			defer insertLicenseSt.Close()

			if _, err := insertLicenseSt.Exec(lic.License, lic.State, userID); err != nil {
				//rollback
				errMsg = errors.New("Unable to update licenses")
				rollback = true
			}
		}
	}
	if !rollback && sm.Role == "doctor" {
		for _, spec := range sm.DoctorSpecialities {
			insertSpecSt, _ := db.Prepare("INSERT INTO `dod`.`USERS_DOCTOR_SPECIALITIES` (`DOCTOR_SPECIALITIES_ID`,`USER_ID`) VALUES (?,?)")
			defer insertSpecSt.Close()

			if _, err := insertSpecSt.Exec(spec, userID); err != nil {
				//rollback
				errMsg = errors.New("Unable to update licenses")
				rollback = true
			}
		}
	}

	if rollback {
		if sm.Role == "doctor" {
			//delete doc specs
			docSpecRmSt, _ := db.Prepare("DELETE FROM `dod`.`USERS_DOCTOR_SPECIALITIES` WHERE USER_ID = ?")
			defer docSpecRmSt.Close()
			docSpecRmSt.Exec(userID)
			//delete doc lics
			docLicRmSt, _ := db.Prepare("DELETE FROM `dod`.`LICENSES` WHERE USER_ID = ?")
			defer docLicRmSt.Close()
			docLicRmSt.Exec(userID)
		}
		//delete user
		userRmSt, _ := db.Prepare("DELETE FROM `dod`.`USERS` WHERE USER_ID = ?")
		defer userRmSt.Close()
		userRmSt.Exec(userID)
		return AuthResponse{}, errMsg
	}
	auth := dbUserLogin(sm.Email, sm.Password)

	dbAuditAction(userID, "Signup:Success")

	return auth, nil
}

func dbGetProfileGet(s string) (ProfileModel, error) {
	dbUserClearSessions()

	var profile ProfileModel

	db := getDB()
	if db == nil {
		return profile, errors.New("Unable to connect to db")
	}
	defer db.Close()

	//fetch profile using session dbGetUserID
	userID, role := dbGetUserIDAndRole(s)
	if userID == 0 {
		return profile, errors.New("Bad Session")
	}

	profileSt, _ := db.Prepare("select `NAME`,`ROLE`,`ADDR`,`CITY`,`STATE`,`POSTAL_CODE`,`PHONE`,`PHARM_LOC`,`SECRET_Q`, `SECRET_A`, `PHOTO` , `DOB` , `GENDER` from `dod`.`USERS` u where u.`USER_ID` = ?")
	defer profileSt.Close()

	err := profileSt.QueryRow(userID).Scan(&profile.Name, &profile.Role, &profile.Address, &profile.City, &profile.State, &profile.PostalCode, &profile.Phone, &profile.PharmacyLocation, &profile.SecretQuestion, &profile.SecretAnswer, &profile.Photo, &profile.DOB, &profile.Gender)
	if err != nil {
		fmt.Println(err.Error())
		return profile, errors.New("Unable to fetch profile")
	}

	//get doctor licenses & specialities if role is doctor
	if role == "doctor" {
		//licenses
		licenseSt, _ := db.Prepare("SELECT `LICENSE_ID`,`STATE` FROM `dod`.`LICENSES` WHERE `USER_ID` = ?")
		defer licenseSt.Close()
		licRows, licErr := licenseSt.Query(userID)
		if licErr != nil {
			return profile, errors.New("Unable to fetch licenses")
		}
		profile.DoctorLicences = []SignupDoctorLicences{}
		for licRows.Next() {
			var lic string
			var state string
			if err := licRows.Scan(&lic, &state); err != nil {
				return profile, errors.New("Unable to fetch license data")
			}
			tmpState := States(state)
			profile.DoctorLicences = append(profile.DoctorLicences, SignupDoctorLicences{
				License: lic,
				State:   &tmpState,
			})
		}

		//specialities
		specialitiesSt, _ := db.Prepare("select DOCTOR_SPECIALITIES_ID from `dod`.`USERS_DOCTOR_SPECIALITIES` where USER_ID = ?")
		defer specialitiesSt.Close()
		specRows, specErr := specialitiesSt.Query(userID)
		if specErr != nil {
			return profile, errors.New("Unable to fetch specalities")
		}
		for specRows.Next() {
			var speciality int
			if err := specRows.Scan(&speciality); err != nil {
				return profile, errors.New("Unable to fetch speciality data")
			}
			profile.DoctorSpecialities = append(profile.DoctorSpecialities, speciality)
		}
	}

	return profile, nil
}

func dbUpdateProfilePost(sessionID string, profile UpdateProfileModel) error {
	dbUserClearSessions()

	db := getDB()
	if db == nil {
		return errors.New("Unable to connect to db")
	}
	defer db.Close()

	//fetch profile using session dbGetUserID
	userID, role := dbGetUserIDAndRole(sessionID)
	if userID == 0 {
		return errors.New("Bad Session")
	}
	if profile.Address == "" {
		return errors.New("Address is required")
	}
	if profile.City == "" {
		return errors.New("City is required")
	}
	if profile.State == nil {
		return errors.New("State is required")
	}
	if profile.PostalCode == "" {
		return errors.New("Postal Code is required")
	}
	if profile.PharmacyLocation == "" && role == "patient" {
		return errors.New("Pharmacy Location is required")
	}
	if profile.Password != "" && validatePassword(profile.Password) == false {
		return errors.New("Password not complex enough")
	}
	if profile.SecretQuestion == "" {
		return errors.New("Secret Question is required")
	}
	if profile.SecretAnswer == "" {
		return errors.New("Secret Answer is required")
	}
	if profile.Name == "" {
		return errors.New("Name is required")
	}
	if profile.Phone == "" {
		return errors.New("Phone is required")
	}
	if profile.DOB == "" {
		return errors.New("DOB is required")
	}
	_, err := time.Parse("2006-01-02", profile.DOB)
	if err != nil {
		return errors.New("Invalid DOB format YYYY-MM-DD")
	}
	if profile.Gender == "" {
		return errors.New("Gender is required")
	}
	if profile.Gender != GenderEnum.Female && profile.Gender != GenderEnum.Male && profile.Gender != GenderEnum.Other {
		return errors.New("Gender can only be " + GenderEnum.Male + ", " + GenderEnum.Female + " or " + GenderEnum.Other)
	}
	if profile.DoctorLicences == nil && role == "doctor" {
		return errors.New("Doctors must have one license")
	}
	if profile.DoctorLicences != nil {
		for _, lic := range profile.DoctorLicences {
			if lic.License == "" || lic.State == nil {
				return errors.New("All Doctor Licenceses must include the number and state")
			}
		}
	}

	profileSt, _ := db.Prepare("UPDATE `dod`.`USERS` SET `NAME` = ?, `ADDR`= ?,`CITY`= ?,`STATE`= ?,`POSTAL_CODE`= ?,`PHARM_LOC`= ?,`PHONE`= ?,`SECRET_Q`= ?, `SECRET_A`= ?, `PHOTO`= ?, `DOB`= ?, `GENDER`= ? WHERE `USER_ID` = ?")
	defer profileSt.Close()

	_, err = profileSt.Exec(profile.Name, profile.Address, profile.City, profile.State, profile.PostalCode, profile.PharmacyLocation, profile.Phone, profile.SecretQuestion, profile.SecretAnswer, profile.Photo, profile.DOB, profile.Gender, userID)
	if err != nil {
		return errors.New("Unable to update profile")
	}

	if profile.Password != "" {
		passwordStr := hashPassword(profile.Password)

		passwordSt, _ := db.Prepare("UPDATE `dod`.`USERS` SET `PASSW`=? WHERE USER_ID = ?")
		defer passwordSt.Close()

		if _, err := profileSt.Exec(passwordStr, userID); err != nil {
			dbAuditAction(userID, "UserProfile:Update")
			return errors.New("Unable to update password")
		}
	}

	//handle doctor licenses if role doctor
	if role == "doctor" {
		//delete all existing licenses for doctor
		deleteLicenseSt, _ := db.Prepare("DELETE from `dod`.`LICENSES` WHERE `USER_ID` = ?")
		defer deleteLicenseSt.Close()

		if _, err := deleteLicenseSt.Exec(userID); err != nil {
			dbAuditAction(userID, "UserProfile:Update")
			return errors.New("Unable to update password")
		}
		//insert new license for doctor
		for _, lic := range profile.DoctorLicences {
			insertLicenseSt, _ := db.Prepare("INSERT INTO `dod`.`LICENSES` (`LICENSE_ID`,`STATE`,`USER_ID`) VALUES (?,?,?)")
			defer insertLicenseSt.Close()

			if _, err := insertLicenseSt.Exec(lic.License, lic.State, userID); err != nil {
				dbAuditAction(userID, "UserProfile:Update")
				return errors.New("Unable to update licenses")
			}
		}

		//delete all existing specialities for doctor
		deleteSpecialitiesSt, _ := db.Prepare("DELETE from `dod`.`USERS_DOCTOR_SPECIALITIES` WHERE `USER_ID` = ?")
		defer deleteSpecialitiesSt.Close()

		if _, err := deleteSpecialitiesSt.Exec(userID); err != nil {
			dbAuditAction(userID, "UserProfile:Update")
			return errors.New("Unable to update password")
		}
		//insert new specialities for doctor
		for _, spec := range profile.DoctorSpecialities {
			insertLicenseSt, _ := db.Prepare("INSERT INTO `dod`.`USERS_DOCTOR_SPECIALITIES` (`DOCTOR_SPECIALITIES_ID`,`USER_ID`) VALUES (?,?)")
			defer insertLicenseSt.Close()

			if _, err := insertLicenseSt.Exec(spec, userID); err != nil {
				dbAuditAction(userID, "UserProfile:Update")
				return errors.New("Unable to update specialities")
			}
		}
	}

	dbAuditAction(userID, "UserProfile:Update")
	return nil
}

func PasswordResetPost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	var input PasswordResetModel

	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Unable to understand request", 400)
		return
	}

	resp, err := dbUserPasswordReset(input)
	if err != nil {
		http.Error(w, err.Error(), 401)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(resp)
}

func LoginPost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	var input LoginModel

	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Unable to understand request", 400)
		return
	}

	auth := dbUserLogin(input.Email, input.Password)

	if auth.SessionID == "" {
		http.Error(w, "Invalid credentials", 401)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(auth)
}

func LogoutPost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}

	w.WriteHeader(http.StatusOK)
	dbUserLogout(sessionID)
}

func SignupPost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	var input SignupModel

	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Unable to understand request", 400)
		return
	}

	resp, err := dbUserSignup(input)
	if err != nil {
		http.Error(w, err.Error(), 400)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(resp)
}

func GetProfileGet(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}

	profile, err := dbGetProfileGet(sessionID)

	if err != nil {
		if err.Error() == "Bad Session" {
			http.Error(w, "Invalid credentials", 401)
			return
		}
		http.Error(w, err.Error(), 400)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(profile)
}

func UpdateProfilePost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	var input UpdateProfileModel

	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Unable to understand request", 400)
		return
	}

	sessionID := r.URL.Query().Get("sessionID")
	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}

	err = dbUpdateProfilePost(sessionID, input)

	if err != nil {
		if err.Error() == "Bad Session" {
			http.Error(w, "Invalid credentials", 401)
			return
		}
		http.Error(w, err.Error(), 400)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func GetDoctorSpecialities(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	specialities, err := dbGetDoctorSpecialities()

	if err != nil {
		http.Error(w, err.Error(), 400)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(specialities)
}

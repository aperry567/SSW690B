/*
 * Doctors on Demand API
 */

package main

import (
	"encoding/json"
	"errors"
	"net/http"
	"regexp"
	"strings"

	"github.com/google/uuid"
)

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
	// required for doctor sign-ups
	DoctorLicences []SignupDoctorLicences `json:"doctorLicences,omitempty"`
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
	// required for doctor sign-ups
	DoctorLicences []SignupDoctorLicences `json:"doctorLicences,omitempty"`
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
	// required for doctor sign-ups
	DoctorLicences []SignupDoctorLicences `json:"doctorLicences,omitempty"`
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
	signupSt, _ := db.Prepare("INSERT INTO `dod`.`USERS` (`CREATED_DT`,`ROLE`,`PASSW`,`NAME`,`EMAIL`,`ADDR`,`CITY`,`STATE`,`POSTAL_CODE`,`PHARM_LOC`,`PHONE`,`SECRET_Q`, `SECRET_A`, `PHOTO`) VALUES (now(),?,?,?,?,?,?,?,?,?,?,?,?,?)")
	defer signupSt.Close()
	_, signupErr := signupSt.Exec(sm.Role, pHash, sm.Name, sm.Email, sm.Address, sm.City, sm.State, sm.PostalCode, sm.PharmacyLocation, sm.Phone, sm.SecretQuestion, sm.SecretAnswer, sm.Photo)
	if signupErr != nil {
		return AuthResponse{}, errors.New("Internal error please try again later")
	}

	//TODO: push doctor licenses if role is doctor

	auth := dbUserLogin(sm.Email, sm.Password)

	userID := dbGetUserID(auth.SessionID)
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

	profileSt, _ := db.Prepare("select `NAME`,`ROLE`,`ADDR`,`CITY`,`STATE`,`POSTAL_CODE`,`PHONE`,`PHARM_LOC`,`SECRET_Q`, `SECRET_A`, `PHOTO` from `dod`.`USERS` u where u.`USER_ID` = ?")
	defer profileSt.Close()

	err := profileSt.QueryRow(userID).Scan(&profile.Name, &profile.Role, &profile.Address, &profile.City, &profile.State, &profile.PostalCode, &profile.Phone, &profile.PharmacyLocation, &profile.SecretQuestion, &profile.SecretAnswer, &profile.Photo)
	if err != nil {
		return profile, errors.New("Unable to fetch profile")
	}

	//get doctor licenses if role is doctor
	if role == "doctor" {
		licenseSt, _ := db.Prepare("SELECT `LICENSE_ID`,`STATE` FROM `dod`.`LICENSES` WHERE `USER_ID` = ?")
		defer licenseSt.Close()

		rows, licErr := licenseSt.Query(userID)
		if licErr != nil {
			return profile, errors.New("Unable to fetch licenses")
		}
		profile.DoctorLicences = []SignupDoctorLicences{}
		for rows.Next() {
			var lic string
			var state string
			if err := rows.Scan(&lic, &state); err != nil {
				return profile, errors.New("Unable to fetch license data")
			}
			tmpState := States(state)
			profile.DoctorLicences = append(profile.DoctorLicences, SignupDoctorLicences{
				License: lic,
				State:   &tmpState,
			})
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

	profileSt, _ := db.Prepare("UPDATE `dod`.`USERS` SET `NAME` = ?, `ADDR`= ?,`CITY`= ?,`STATE`= ?,`POSTAL_CODE`= ?,`PHARM_LOC`= ?,`PHONE`= ?,`SECRET_Q`= ?, `SECRET_A`= ?, `PHOTO`= ? WHERE `USER_ID` = ?")
	defer profileSt.Close()

	_, err := profileSt.Exec(profile.Name, profile.Address, profile.City, profile.State, profile.PostalCode, profile.Phone, profile.PharmacyLocation, profile.SecretQuestion, profile.SecretAnswer, profile.Photo, userID)
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

	var input LogoutModel

	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Unable to understand request", 400)
		return
	}

	w.WriteHeader(http.StatusOK)
	dbUserLogout(input.SessionID)
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

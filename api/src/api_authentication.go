/*
 * Doctors on Demand API
 */

package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"regexp"

	"github.com/google/uuid"
)

type LoginModel struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LogoutModel struct {
	SessionID string `json:"sessionID"`
}

type AuthResponse struct {
	SessionID string `json:"sessionID"`
	Role      string `json:"role"`
}

type SignupDoctorLicences struct {
	State   *States `json:"state"`
	License string  `json:"license"`
}

type SignupModel struct {
	Email    string `json:"email"`
	Password string `json:"password"`
	// can only be patient or doctor
	Role           string  `json:"role"`
	Name           string  `json:"name"`
	Address        string  `json:"address"`
	City           string  `json:"city"`
	State          *States `json:"state"`
	PostalCode     string  `json:"postalCode"`
	Phone          string  `json:"phone"`
	Photo          string  `json:"photo"`
	SecretQuestion string  `json:"secretQuestion"`
	SecretAnswer   string  `json:"secretAnswer"`
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
	if sm.Password == "" {
		return AuthResponse{}, errors.New("Password is required")
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
	if sm.DoctorLicences != nil {
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
	var docLicStr sql.NullString
	if sm.DoctorLicences != nil {
		jsonStr, _ := json.Marshal(sm.DoctorLicences)
		docLicStr = sql.NullString{String: string(jsonStr), Valid: true}
	} else {
		docLicStr = sql.NullString{String: docLicStr.String, Valid: false}
	}
	var photo sql.NullString
	if sm.Photo != "" {
		photo = sql.NullString{String: sm.Photo, Valid: true}
	} else {
		photo = sql.NullString{String: sm.Photo, Valid: false}
	}
	signupSt, _ := db.Prepare("INSERT INTO `dod`.`USERS` (`CREATED_DT`,`ROLE`,`PASSW`,`NAME`,`EMAIL`,`ADDR`,`CITY`,`STATE`,`POSTAL_CODE`,`PHONE`,`LICENSES`, `SECRET_Q`, `SECRET_A`, `PHOTO`) VALUES (now(),?,?,?,?,?,?,?,?,?,?,?,?,?)")
	defer signupSt.Close()
	_, signupErr := signupSt.Exec(sm.Role, pHash, sm.Name, sm.Email, sm.Address, sm.City, sm.State, sm.PostalCode, sm.Phone, docLicStr, sm.SecretQuestion, sm.SecretAnswer, photo)
	if signupErr != nil {
		return AuthResponse{}, errors.New("Internal error please try again later")
	}

	auth := dbUserLogin(sm.Email, sm.Password)

	userID := dbGetUserID(auth.SessionID)
	dbAuditAction(userID, "Signup:Success")

	return auth, nil
}

func PasswordResetPost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	var input SignupModel

	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, err.Error(), 400)
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

func LoginPost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	var input LoginModel

	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, err.Error(), 400)
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
		http.Error(w, err.Error(), 400)
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
		http.Error(w, err.Error(), 400)
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

/*
 * Doctors on Demand API
 */

package main

import (
	"encoding/json"
	"fmt"
	"net/http"

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
	Role       string  `json:"role"`
	Name       string  `json:"name"`
	Address    string  `json:"address"`
	City       string  `json:"city"`
	State      *States `json:"state"`
	PostalCode string  `json:"postalCode"`
	Phone      string  `json:"phone"`
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
		fmt.Println("1: ", lisrerr.Error())
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
		fmt.Println("2: ", sessionStErr.Error())
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

	dbUserLogout(input.SessionID)

	w.WriteHeader(http.StatusOK)
}

func SignupPost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	var input SignupModel

	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, err.Error(), 400)
		return
	}

	w.WriteHeader(http.StatusOK)

	//handle login request
	resp := AuthResponse{
		SessionID: "12345",
		Role:      input.Role,
	}
	json.NewEncoder(w).Encode(resp)
}

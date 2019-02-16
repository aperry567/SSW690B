/*
 * Doctors on Demand API
 */

package main

import (
	"encoding/json"
	"net/http"
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

func LoginPost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)

	var input LoginModel

	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, err.Error(), 400)
		return
	}
	//handle login request
	resp := AuthResponse{
		SessionID: "12345",
		Role:      "patient",
	}
	json.NewEncoder(w).Encode(resp)
}

func LogoutPost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)

	var input LogoutModel

	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, err.Error(), 400)
		return
	}
}

func SignupPost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)

	var input SignupModel

	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, err.Error(), 400)
		return
	}
	//handle login request
	resp := AuthResponse{
		SessionID: "12345",
		Role:      input.Role,
	}
	json.NewEncoder(w).Encode(resp)
}

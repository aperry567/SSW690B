//Prescription code for api_presciption.go
/*
 * Doctors on Demand API prescriptions
 */

package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
)

type UpdatePrescriptionRequest struct {
	Title    string `json:"title"`
	Subtitle string `json:"subtitle"`
	Details  string `json:"details"`
}

func dbGetPrescriptionDetail(sessionID string, prescriptionIDstr string) (DetailResponse, error) {
	dbUserClearSessions()

	var resp DetailResponse

	db := getDB()
	if db == nil {
		return resp, errors.New("Unable to connect to db")
	}
	defer db.Close()

	//fetch profile using session dbGetUserID
	userID, role := dbGetUserIDAndRole(sessionID)
	if userID == 0 {
		return resp, errors.New("Bad Session")
	}

	prescriptionID, numErr := strconv.ParseInt(prescriptionIDstr, 0, 64)
	if numErr != nil {
		return resp, errors.New("Refills must be a number")
	}

	//build query string
	getQueryStr := "SELECT CREATED_TIME, `NAME`, `INSTRUCTIONS`, CONCAT('Refills: ', REFILLS) FROM dod.PRESCRIPTIONS WHERE `PRESCRIPTION_ID` = ? AND `PATIENT_USER_ID` = ?"
	if role == "doctor" {
		getQueryStr = strings.Replace(getQueryStr, "`PATIENT_USER_ID`", "`DOCTOR_USER_ID`", 1)
	}
	prescriptionSt, errSt := db.Prepare(getQueryStr)
	defer prescriptionSt.Close()
	if errSt != nil {
		fmt.Println(errSt.Error())
	}

	err := prescriptionSt.QueryRow(prescriptionID, userID).Scan(&resp.DateTime, &resp.Title, &resp.Details, &resp.Subtitle)
	if err != nil {
		return resp, errors.New("Unable to find prescription")
	}

	resp.Label = "Rx"
	resp.LabelColor = LABEL_COLOR_PRESCRIPTION

	if role == "doctor" {
		resp.TitleEditable = true
		resp.SubtitleEditable = true
		resp.DetailsEditable = true
		resp.UpdateURL = "/api/UpdatePrescription?sessionID=" + sessionID + "&prescriptionID=" + prescriptionIDstr
	}

	return resp, nil
}

func dbUpdatePrescription(sessionID string, prescriptionID string, req UpdatePrescriptionRequest) error {
	dbUserClearSessions()

	db := getDB()
	if db == nil {
		return errors.New("Unable to connect to db")
	}
	defer db.Close()

	//fetch user_id and role
	userID, role := dbGetUserIDAndRole(sessionID)
	if userID == 0 {
		return errors.New("Bad Session")
	}

	if role != "doctor" {
		return errors.New("Can only be used by doctors")
	}

	if req.Title == "" {
		return errors.New("title is required")
	}

	if req.Subtitle == "" {
		return errors.New("Subtitle is required")
	}

	refillStr := strings.Replace(req.Subtitle, "Refills: ", "", 1)
	refillNum, numErr := strconv.ParseInt(refillStr, 0, 64)
	if numErr != nil {
		return errors.New("Refills must be a number")
	}
	if refillNum < 0 || refillNum > 20 {
		return errors.New("Refills must be between 0 and 20")
	}

	//build query string
	prescriptionSt, _ := db.Prepare("update dod.`PRESCRIPTIONS` v set v.`NAME` = ?, v.`REFILLS` = ?, v.`INSTRUCTIONS` = ? where v.`PRESCRIPTION_ID` = ? and v.DOCTOR_USER_ID = ?")
	_, err := prescriptionSt.Exec(req.Title, refillNum, req.Details, prescriptionID, userID)
	defer prescriptionSt.Close()
	if err != nil {
		return errors.New("Unable to update prescription")
	}

	return nil
}

func dbDeletePrescription(sessionID string, prescriptionID string) error {
	dbUserClearSessions()

	var err error

	db := getDB()
	if db == nil {
		return errors.New("Unable to connect to db")
	}
	defer db.Close()

	//fetch user_id and role
	userID, role := dbGetUserIDAndRole(sessionID)
	if userID == 0 {
		return errors.New("Bad Session")
	}

	if role != "doctor" {
		return errors.New("Can only be used by doctors")
	}

	examSt, _ := db.Prepare("DELETE FROM `dod`.`PRESCRIPTIONS` WHERE PRESCRIPTION_ID = ? AND DOCTOR_USER_ID = ?")
	_, err = examSt.Exec(prescriptionID, userID)
	defer examSt.Close()
	if err != nil {
		return errors.New("Unable to delete prescription")
	}

	return nil
}

func UpdatePrescription(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	prescriptionID := r.URL.Query().Get("prescriptionID")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}
	if prescriptionID == "" {
		http.Error(w, "Missing required prescriptionID parameter", 400)
		return
	}

	var input UpdatePrescriptionRequest

	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "Unable to understand request", 400)
		return
	}

	if err := dbUpdatePrescription(sessionID, prescriptionID, input); err != nil {
		if err.Error() == "Bad Session" {
			http.Error(w, "Invalid credentials", 401)
			return
		}
		http.Error(w, err.Error(), 400)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func GetPrescriptionDetail(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	prescriptionID := r.URL.Query().Get("prescriptionID")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}
	if prescriptionID == "" {
		http.Error(w, "Missing required prescriptionID parameter", 400)
		return
	}

	output, err := dbGetPrescriptionDetail(sessionID, prescriptionID)

	if err != nil {
		if err.Error() == "Bad Session" {
			http.Error(w, "Invalid credentials", 401)
			return
		}
		http.Error(w, err.Error(), 400)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(output)
}

func DeletePrescription(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	prescriptionID := r.URL.Query().Get("prescriptionID")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}
	if prescriptionID == "" {
		http.Error(w, "Missing required prescriptionID parameter", 400)
		return
	}

	if err := dbDeletePrescription(sessionID, prescriptionID); err != nil {
		if err.Error() == "Bad Session" {
			http.Error(w, "Invalid credentials", 401)
			return
		}
		http.Error(w, err.Error(), 400)
		return
	}

	w.WriteHeader(http.StatusOK)
}

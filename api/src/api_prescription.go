//Prescription code for api_presciption.go
/*
 * Doctors on Demand API prescriptions
*/
package main

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"strings"
)

type UpdatePrescriptionRequest struct {
	Details string `json:"details"`
}

func dbGetPrescriptionDetail(sessionID string, prescriptionIDstr string, title string, subtitle string, subtitleEditable string, label string, labelColor string) (DetailResponse, error) {
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
	getQueryStr := "SELECT u.PHOTO as PHOTO, CREATED_TIME as DATETIME, CONCAT('Prescriptions ', u.NAME) as TITLE,'Prescription' as LABEL, '0xffcef7b7' as LABEL_COLOR, NOTES as `DESC`, PRESCRIPTION_REASON as SUBTITLE FROM dod.PRESCRIPTIONS v LEFT OUTER JOIN dod.USERS u on v.DOCTOR_USER_ID = u.USER_ID WHERE v.PRESCRIPTION_ID = ? AND v.`PATIENT_USER_ID` = ?"
	if role == "doctor" {
		getQueryStr = strings.Replace(getQueryStr, "`PATIENT_USER_ID`", "`DOCTOR_USER_ID`", 1)
	}
	prescriptionSt, _ := db.Prepare(getQueryStr)
	defer prescriptionSt.Close()

	err := prescriptionSt.QueryRow(prescriptionID, userID).Scan(&resp.Photo, &resp.DateTime, &resp.Title, &resp.Label, &resp.LabelColor, &resp.Details, &resp.Subtitle)
	if err != nil {
		return resp, err //errors.New("Unable to find prescription")
	}

	if role == "doctor" {
		resp.title = "Name",
		resp.TitleEditable: true,
		resp.Subtitle = "",
		resp.SubtitleEditable: true,
		resp.Details = &resp.Details,
		resp.DetailsEditable = true,
		resp.Label = "Rx",
		resp.LabelColor = "0xff24d622",
		resp.photo = "",
		resp.dateTime = &resp.DateTime,
		resp.chatURL = "",
		resp.RelatedItemsURL = "",
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

	//build query string
	prescriptionSt, _ := db.Prepare("update dod.`PRESCRIPTIONS` v set v.`NOTES` = ? where v.`PRESCRIPTION_ID` = ? and v.DOCTOR_USER_ID = ?")
	_, err := prescriptionSt.Exec(req.Details, prescriptionID, userID)
	defer prescriptionSt.Close()
	if err != nil {
		return errors.New("Unable to update prescription")
	}

	return nil
}

func UpdatePrescription(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	prescriptionID := r.URL.Query().Get("prescriptionID")
	title := .URL.Query().Get("name") //Using placeholders for now
	subtitle := .URL.Query().Get("refills") //Using placeholders for now
	details := .URL.Query().Get("instructions") //Using placeholders for now

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}
	if prescriptionID == "" {
		http.Error(w, "Missing required prescriptionID parameter", 400)
		return
	}
	if title == "" {
		http.Error(w, "Missing required name parameter", 400)
		return
	}
	if subtitle == "" {
		http.Error(w, "Missing required refills parameter", 400)
		return
	}
	if details == "" {
		http.Error(w, "Missing required instructions parameter", 400)
		return
	}

	var input UpdatePrescriptionRequest

	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "Unable to understand request", 400)
		return
	}

	if err := dbUpdatePrescription(Subtitle, dateTime, input); err != nil {
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

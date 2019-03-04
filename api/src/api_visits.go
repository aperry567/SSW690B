/*
 * Doctors on Demand API visits
 */

package main

import (
	"encoding/json"
	"errors"
	"net/http"
)

type GetVisitsRequest struct {
	SessionID string `json:"sessionID"`
	PatientID int    `json:"patientID"`
}

type VisitsPersonModel struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Photo string `json:"photo"`
}

type GetVisitsResponse struct {
	ID        int               `json:"id"`
	VisitTime string            `json:"visitTime"`
	Reason    string            `json:"reason"`
	Doctor    VisitsPersonModel `json:"doctor"`
	Patient   VisitsPersonModel `json:"patient"`
	Notes     string            `json:"notes"`
}

type UpdateVisitRequest struct {
	SessionID string `json:"sessionID"`
	VisitID   int    `json:"visitID"`
	Notes     string `json:"notes"`
}

func dbGetVisitsPost(req GetVisitsRequest) ([]GetVisitsResponse, error) {
	dbUserClearSessions()

	var resps []GetVisitsResponse

	db := getDB()
	if db == nil {
		return resps, errors.New("Unable to connect to db")
	}
	defer db.Close()

	//fetch profile using session dbGetUserID
	userID, role := dbGetUserIDAndRole(req.SessionID)
	if userID == 0 {
		return resps, errors.New("Bad Session")
	}

	//build query string
	getQueryStr := "SELECT v.`VISIT_ID`, v.`VISIT_REASON`, v.`VISIT_TIME`, v.`NOTES`, p.`USER_ID`, p.`NAME`, p.`PHOTO`, d.`USER_ID`, d.`NAME`, d.`PHOTO` FROM dod.`VISITS` v left outer join dod.`USERS` p on v.`PATIENT_USER_ID` = p.`USER_ID` left outer join dod.`USERS` d on v.`DOCTOR_USER_ID` = d.`USER_ID`"
	if role == "doctor" {
		getQueryStr = getQueryStr + " where v.`DOCTOR_USER_ID` = ?"
	} else {
		getQueryStr = getQueryStr + " where v.`PATIENT_USER_ID` = ?"
	}
	visitSt, _ := db.Prepare(getQueryStr)
	defer visitSt.Close()

	rows, err := visitSt.Query(userID)
	if err != nil {
		return resps, errors.New("You have no visits")
	}
	defer rows.Close()

	for rows.Next() {
		var visit GetVisitsResponse
		if err := rows.Scan(&visit.ID, &visit.Reason, &visit.VisitTime, &visit.Notes, &visit.Patient.ID, &visit.Patient.Name, &visit.Patient.Photo, &visit.Doctor.ID, &visit.Doctor.Name, &visit.Doctor.Photo); err != nil {
			return resps, errors.New("Unable to retrieve visits")
		}
		resps = append(resps, visit)
	}

	return resps, nil
}

func dbUpdateVisitPost(req UpdateVisitRequest) error {
	dbUserClearSessions()

	db := getDB()
	if db == nil {
		return errors.New("Unable to connect to db")
	}
	defer db.Close()

	//fetch user_id and role
	userID, role := dbGetUserIDAndRole(req.SessionID)
	if userID == 0 {
		return errors.New("Bad Session")
	}

	if role != "doctor" {
		return errors.New("Can only be used by doctors")
	}

	//build query string
	visitSt, _ := db.Prepare("update dod.`VISITS` v set v.`NOTES` = ? where v.`VISIT_ID` = ? and v.DOCTOR_USER_ID = ?")
	_, err := visitSt.Exec(req.Notes, req.VisitID, userID)
	defer visitSt.Close()
	if err != nil {
		return errors.New("Unable to update visit")
	}

	return nil
}

func UpdateVisitPost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	var input UpdateVisitRequest

	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "Unable to understand request", 400)
		return
	}

	if err := dbUpdateVisitPost(input); err != nil {
		if err.Error() == "Bad Session" {
			http.Error(w, "Invalid credentials", 401)
			return
		}
		http.Error(w, err.Error(), 400)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func GetVisitsPost(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	var input GetVisitsRequest

	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Unable to understand request", 400)
		return
	}

	output, err := dbGetVisitsPost(input)

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

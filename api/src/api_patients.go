/*
 * Doctors on Demand API visits
 */

package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
)

func dbGetPatientRelatedItems(sessionID string, patientID string, filter string) (ListResponse, error) {
	dbUserClearSessions()

	db := getDB()
	userID, role := dbGetUserIDAndRole(sessionID)

	response := ListResponse{
		Items: []ListItem{},
		Filters: []ListFilter{
			ListFilter{
				Title: "All",
				Value: "",
			},
			ListFilter{
				Title: "Exams",
				Value: "filter=1",
			},
			ListFilter{
				Title: "Prescriptions",
				Value: "filter=2",
			},
			ListFilter{
				Title: "Visits",
				Value: "filter=3",
			},
		},
	}

	if role != "doctor" {
		return response, errors.New("Must be a Doctor to use")
	}

	var examSelect string
	var prescriptSelect string
	var visitSelect string

	examSelect = "SELECT '' as PHOTO, EXAM_TIME as DATETIME, `DESC` as TITLE, 'Exam' as LABEL, '" + LABEL_COLOR_EXAM + "' as LABEL_COLOR, '', LOCATION as SUBTITLE, CONCAT('/api/getExamDetail?sessionID=',?,'&examID=', EXAM_ID) as DETAIL_LINK FROM dod.EXAMS WHERE PATIENT_USER_ID = ? and DOCTOR_USER_ID = ?"
	prescriptSelect = "SELECT '' as PHOTO, CREATED_TIME as DATETIME, NAME as TITLE, 'Rx' as LABEL,'" + LABEL_COLOR_PRESCRIPTION + "' as LABEL_COLOR, INSTRUCTIONS as `DESC`, CONCAT('Refills: ', REFILLS) as SUBTITLE, CONCAT('/api/getPrescriptionDetail?sessionID=',?,'&prescriptionID=',PRESCRIPTION_ID) as DETAIL_LINK FROM dod.PRESCRIPTIONS WHERE PATIENT_USER_ID = ? DOCTOR_USER_ID = ?"
	visitSelect = "SELECT u.PHOTO as PHOTO, VISIT_TIME as DATETIME, u.NAME as TITLE,'Visit' as LABEL, '" + LABEL_COLOR_VISIT + "' as LABEL_COLOR, NOTES as `DESC`, CONCAT('Reason: ', VISIT_REASON) as SUBTITLE, CONCAT('/api/getVisitDetail?sessionID=',?,'&visitID=',VISIT_ID) as `DETAIL_LINK` FROM dod.VISITS v LEFT OUTER JOIN dod.USERS u on v.DOCTOR_USER_ID = u.USER_ID WHERE v.PATIENT_USER_ID = ? and v.DOCTOR_USER_ID = ?"

	var selectSt *sql.Stmt
	var rows *sql.Rows
	var err error

	// all
	if filter == "" {
		selectSt, _ = db.Prepare(examSelect + " UNION ALL " + prescriptSelect + " UNION ALL " + visitSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(patientID, userID, patientID, userID, sessionID, patientID, userID)
	}
	// exam
	if filter == "1" {
		selectSt, _ = db.Prepare(examSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(patientID, userID)
	}
	// prescription
	if filter == "2" {
		selectSt, _ = db.Prepare(prescriptSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(patientID, userID)
	}
	// visit
	if filter == "2" {
		selectSt, _ = db.Prepare(visitSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(patientID, userID)
	}

	defer selectSt.Close()
	defer rows.Close()

	if err != nil {
		return response, errors.New("Unable to fetch home items")
	}

	for rows.Next() {
		var item ListItem
		item.ScreenType = "detail"
		if err := rows.Scan(&item.Photo, &item.DateTime, &item.Title, &item.Label, &item.LabelColor, &item.Details, &item.Subtitle, &item.DetailLink); err != nil {
			return response, errors.New("Unable to fetch home item")
		}
		response.Items = append(response.Items, item)
	}

	return response, nil
}

func dbGetPatientDetail(sessionID string, patientID string) (DetailResponse, error) {
	dbUserClearSessions()

	var resp DetailResponse

	db := getDB()
	if db == nil {
		return resp, errors.New("Unable to connect to db")
	}
	defer db.Close()

	userID, role := dbGetUserIDAndRole(sessionID)
	if userID == 0 {
		return resp, errors.New("Bad Session")
	}

	if role != "doctor" {
		return resp, errors.New("Must be a doctor to use")
	}

	//build query string
	getQueryStr := "select u.PHOTO, u.NAME, u.EMAIL, CONCAT(u.CITY,', ',u.STATE) from dod.VISITS v left outer join dod.USERS u on v.PATIENT_USER_ID = u.USER_ID where v.DOCTOR_USER_ID = ? and v.PATIENT_USER_ID = ?"
	patientSt, _ := db.Prepare(getQueryStr)
	defer patientSt.Close()

	err := patientSt.QueryRow(patientID, userID).Scan(&resp.Photo, &resp.Title, &resp.Details, &resp.Subtitle)
	if err != nil {
		return resp, errors.New("Unable to find Patient")
	}

	resp.Label = "Patient"
	resp.LabelColor = LABEL_COLOR_PATIENT

	resp.RelatedItemsURL = "/api/getVisitRelatedItems?sessionID=" + sessionID + "&patientID=" + patientID

	return resp, nil
}

func dbGetPatients(sessionID string) (ListResponse, error) {
	dbUserClearSessions()

	var resp ListResponse
	resp.Items = []ListItem{}
	resp.Filters = []ListFilter{
		ListFilter{
			Title: "Patient List",
			Value: "",
		},
	}

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

	if role != "doctor" {
		return resp, errors.New("Must be a doctor to use")
	}

	//build query string
	getQueryStr := "select distinct u.USER_ID, u.PHOTO, u.NAME, u.EMAIL, CONCAT(u.CITY,', ',u.STATE), CONCAT('/api/getPatientDetail?sessionID=',?,'&patientID=',u.USER_ID) from dod.VISITS v left outer join dod.USERS u on v.PATIENT_USER_ID = u.USER_ID where v.DOCTOR_USER_ID = ?"
	visitSt, _ := db.Prepare(getQueryStr)
	defer visitSt.Close()

	rows, err := visitSt.Query(sessionID, userID)
	if err != nil {
		return resp, errors.New("Unable to find Patient")
	}

	for rows.Next() {
		var item ListItem
		var id string
		item.DetailLink = "/api/getPatientDetail"
		item.ScreenType = "detail"
		if err := rows.Scan(&id, &item.Photo, &item.Title, &item.Details, &item.Subtitle, &item.DetailLink); err != nil {
			return resp, errors.New("Unable to fetch patient item")
		}
		resp.Items = append(resp.Items, item)
	}
	return resp, nil
}

func GetPatientRelatedItems(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	visitID := r.URL.Query().Get("visitID")
	filter := r.URL.Query().Get("filter")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}
	if visitID == "" {
		http.Error(w, "Missing required visitID parameter", 400)
		return
	}

	output, err := dbGetPatientRelatedItems(sessionID, visitID, filter)

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

func GetPatientDetail(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	patientID := r.URL.Query().Get("patientID")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}
	if patientID == "" {
		http.Error(w, "Missing required patientID parameter", 400)
		return
	}

	output, err := dbGetPatientDetail(sessionID, patientID)

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

func GetPatients(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}

	output, err := dbGetPatients(sessionID)

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

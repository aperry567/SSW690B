/*
 * Doctors on Demand API
 */

package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
)

func dbGetPatientHomeItems(sessionID string, filter string) (ListResponse, error) {
	dbUserClearSessions()

	db := getDB()
	userID, role := dbGetUserIDAndRole(sessionID)

	var response ListResponse
	response.Items = []ListItem{}

	if role != "patient" {
		return response, errors.New("Must be a patient to use")
	}

	var examSelect string
	var visitSelect string
	var prescriptSelect string

	examSelect = "SELECT u.PHOTO as PHOTO, e.EXAM_TIME as DATETIME, e.`DESC` as TITLE, 'Exam' as LABEL, '" + LABEL_COLOR_EXAM + "' as LABEL_COLOR, '' as `DESC`, e.LOCATION as SUBTITLE, CONCAT('/api/getExamDetail?sessionID=',?,'&examID=',e.EXAM_ID) as `DETAIL_LINK` FROM dod.EXAMS e LEFT OUTER JOIN dod.USERS u on u.USER_ID = e.DOCTOR_USER_ID WHERE e.PATIENT_USER_ID = ?"
	visitSelect = "SELECT u.PHOTO as PHOTO, VISIT_TIME as DATETIME, u.NAME as TITLE,'Visit' as LABEL, '" + LABEL_COLOR_VISIT + "' as LABEL_COLOR, NOTES as `DESC`, CONCAT('Reason: ', VISIT_REASON) as SUBTITLE, CONCAT('/api/getVisitDetail?sessionID=',?,'&visitID=',VISIT_ID) as `DETAIL_LINK` FROM dod.VISITS v LEFT OUTER JOIN dod.USERS u on v.DOCTOR_USER_ID = u.USER_ID WHERE v.PATIENT_USER_ID = ?"
	prescriptSelect = "SELECT u.PHOTO as PHOTO, p.CREATED_TIME as DATETIME, p.NAME as TITLE, 'Rx' as LABEL, '" + LABEL_COLOR_PRESCRIPTION + "' as LABEL_COLOR, p.INSTRUCTIONS as `DESC`, CONCAT('Refills: ', p.REFILLS) as SUBTITLE, CONCAT('/api/getPrescriptionDetail?sessionID=',?,'&prescriptionID=', p.PRESCRIPTION_ID) as DETAIL_LINK FROM dod.PRESCRIPTIONS p LEFT OUTER JOIN dod.USERS u on u.USER_ID = p.DOCTOR_USER_ID WHERE p.PATIENT_USER_ID = ?"

	var selectSt *sql.Stmt
	var rows *sql.Rows
	var err error

	// exam
	if filter == "1" {
		selectSt, _ = db.Prepare(examSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(sessionID, userID)
		defer selectSt.Close()
	} else if filter == "2" {
		// visit
		selectSt, _ = db.Prepare(visitSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(sessionID, userID)
		defer selectSt.Close()
	} else if filter == "3" {
		// prescription
		selectSt, _ = db.Prepare(prescriptSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(sessionID, userID)
		defer selectSt.Close()
	} else {
		// all
		selectSt, err = db.Prepare(examSelect + " UNION ALL " + prescriptSelect + " UNION ALL " + visitSelect + " ORDER BY DATETIME DESC")
		if err != nil {
			fmt.Println(err.Error())
		}
		rows, err = selectSt.Query(sessionID, userID, sessionID, userID, sessionID, userID)
		defer selectSt.Close()
	}

	if err != nil {
		fmt.Println(err.Error())
		return response, errors.New("Unable to fetch home items")
	}

	response.Items = append([]ListItem{}, ListItem{
		Title:      "Find a Doctor",
		ScreenType: "questionnaire",
		DetailLink: "/api/getQuestionnaire?sessionID=" + sessionID,
	})
	for rows.Next() {
		var item ListItem
		item.ScreenType = "detail"
		if err := rows.Scan(&item.Photo, &item.DateTime, &item.Title, &item.Label, &item.LabelColor, &item.Details, &item.Subtitle, &item.DetailLink); err != nil {
			return response, errors.New("Unable to fetch home item")
		}
		response.Items = append(response.Items, item)
	}

	response.Filters = append(
		[]ListFilter{},
		ListFilter{
			Title: "All",
			Value: "",
		},
		ListFilter{
			Title: "Exams",
			Value: "filter=1",
		},
		ListFilter{
			Title: "Visits",
			Value: "filter=2",
		},
		ListFilter{
			Title: "Rx",
			Value: "filter=3",
		},
	)

	return response, nil
}

func dbGetDoctorHomeItems(sessionID string) (ListResponse, error) {
	dbUserClearSessions()

	db := getDB()
	userID, role := dbGetUserIDAndRole(sessionID)

	var response ListResponse
	response.Items = []ListItem{}

	if role != "doctor" {
		return response, errors.New("Must be a doctor to use")
	}

	response.Filters = append(
		[]ListFilter{},
		ListFilter{
			Title: "Patient Visits",
			Value: "",
		},
	)

	var visitSelect string

	visitSelect = "SELECT u.PHOTO as PHOTO, VISIT_TIME as DATETIME, u.NAME as TITLE,'Visit' as LABEL, '" + LABEL_COLOR_VISIT + "' as LABEL_COLOR, NOTES as `DESC`, CONCAT('Reason: ', VISIT_REASON) as SUBTITLE, CONCAT('/api/getVisitDetail?sessionID=',?,'&visitID=',VISIT_ID) as `DETAIL_LINK` FROM dod.VISITS v LEFT OUTER JOIN dod.USERS u on v.PATIENT_USER_ID = u.USER_ID WHERE v.DOCTOR_USER_ID = ?"

	var selectSt *sql.Stmt
	var rows *sql.Rows
	var err error

	// visit
	selectSt, _ = db.Prepare(visitSelect + " ORDER BY DATETIME DESC")
	rows, err = selectSt.Query(sessionID, userID)
	defer selectSt.Close()

	if err != nil {
		return response, errors.New("Unable to fetch home items")
	}

	response.Items = []ListItem{}
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

func GetPatientHomeItems(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	defer r.Body.Close()

	sessionID := r.URL.Query().Get("sessionID")
	listFilter := r.URL.Query().Get("filter")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}

	output, err := dbGetPatientHomeItems(sessionID, listFilter)

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

func GetDoctorHomeItems(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	defer r.Body.Close()

	sessionID := r.URL.Query().Get("sessionID")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}

	output, err := dbGetDoctorHomeItems(sessionID)

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

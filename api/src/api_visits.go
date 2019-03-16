/*
 * Doctors on Demand API visits
 */

package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"strings"
	"time"
)

type UpdateVisitRequest struct {
	Details string `json:"details"`
}

func dbGetVisitRelatedItems(sessionID string, visitID string, filter string) (ListResponse, error) {
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
				Title:  "Exams",
				Value:  "filter=1",
				AddURL: "/api/saveVisitRelatedItems?sessionID=" + sessionID + "&visitID=" + visitID + "&filter=1",
				AddDetails: []ListFilterAddDetails{
					ListFilterAddDetails{
						Label:      "Location",
						FieldName:  "subtitle",
						IsDateTime: false,
						Required:   true,
					},
					ListFilterAddDetails{
						Label:      "Exam Time",
						FieldName:  "datetime",
						IsDateTime: false,
						Required:   true,
					},
					ListFilterAddDetails{
						Label:      "Instructions",
						FieldName:  "details",
						IsDateTime: false,
						Required:   true,
					},
				},
			},
			ListFilter{
				Title:  "Prescriptions",
				Value:  "filter=2",
				AddURL: "/api/saveVisitRelatedItems?sessionID=" + sessionID + "&visitID=" + visitID + "&filter=2",
				AddDetails: []ListFilterAddDetails{
					ListFilterAddDetails{
						Label:      "Medication Name",
						FieldName:  "title",
						IsDateTime: false,
						Required:   true,
					},
					ListFilterAddDetails{
						Label:      "Refills",
						FieldName:  "subtitle",
						IsDateTime: false,
						Required:   true,
					},
					ListFilterAddDetails{
						Label:      "Instructions",
						FieldName:  "details",
						IsDateTime: false,
						Required:   true,
					},
				},
			},
		},
	}

	if role != "doctor" {
		response.Filters[1].AddURL = ""
		response.Filters[1].AddDetails = nil
		response.Filters[2].AddURL = ""
		response.Filters[2].AddDetails = nil
	}

	var examSelect string
	var prescriptSelect string

	examSelect = "SELECT '' as PHOTO, EXAM_TIME as DATETIME, 'Exam' as TITLE, 'Exam' as LABEL, '" + LABEL_COLOR_EXAM + "' as LABEL_COLOR, `DESC`, LOCATION as SUBTITLE, EXAM_ID as ID FROM dod.EXAMS WHERE VISIT_ID = ? and PATIENT_USER_ID = ?"
	if role == "doctor" {
		examSelect = strings.Replace(examSelect, "PATIENT_USER_ID", "DOCTOR_USER_ID", 1)
	}
	prescriptSelect = "SELECT '' as PHOTO, CREATED_TIME as DATETIME, NAME as TITLE, 'Rx' as LABEL,'" + LABEL_COLOR_PRESCRIPTION + "' as LABEL_COLOR, INSTRUCTIONS as `DESC`, CONCAT('Refills: ', REFILLS) as SUBTITLE, PRESCRIPTION_ID as ID FROM dod.PRESCRIPTIONS WHERE VISIT_ID = ? and PATIENT_USER_ID = ?"
	if role == "doctor" {
		prescriptSelect = strings.Replace(prescriptSelect, "PATIENT_USER_ID", "DOCTOR_USER_ID", 1)
	}

	var selectSt *sql.Stmt
	var rows *sql.Rows
	var err error

	// all
	if filter == "" {
		selectSt, _ = db.Prepare(examSelect + " UNION ALL " + prescriptSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(visitID, userID, visitID, userID)
	}
	// exam
	if filter == "1" {
		selectSt, _ = db.Prepare(examSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(visitID, userID)
	}
	// prescription
	if filter == "2" {
		selectSt, _ = db.Prepare(prescriptSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(visitID, userID)
	}

	defer selectSt.Close()
	defer rows.Close()

	if err != nil {
		return response, errors.New("Unable to fetch home items")
	}

	for rows.Next() {
		var item ListItem
		var id string
		if err := rows.Scan(&item.Photo, &item.DateTime, &item.Title, &item.Label, &item.LabelColor, &item.Details, &item.Subtitle, &id); err != nil {
			return response, errors.New("Unable to fetch home item")
		}
		response.Items = append(response.Items, item)
	}

	return response, nil
}

func dbAddVisitRelatedItems(sessionID string, visitID string, filter string, req AddRelatedItemsRequest) error {
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
	if role != "doctor" {
		return errors.New("Must be a doctor use this")
	}

	if filter != "" && filter != "1" && filter != "2" {
		return errors.New("Bad filter option")
	}

	patientID := dbGetPatientUserIDForVisitID(userID, visitID)
	if patientID == 0 {
		return errors.New("Visit is not associated to you")
	}

	var err error

	// save new exam item
	if filter == "1" {
		//validate values
		if req.Subtitle == "" {
			return errors.New("Loocation is required")
		}
		if req.Details == "" {
			return errors.New("Instructions are required")
		}
		if req.DateTime == "" {
			return errors.New("Exam Time is required")
		}
		_, err = time.Parse("2006-01-02 15:04:05", req.DateTime)
		if err != nil {
			return errors.New("Invalid Exam Time format YYYY-MM-DD hh:mm:ss")
		}
		relatedItemSt, _ := db.Prepare("insert into `dod`.`EXAMS` (PATIENT_USER_ID, DOCTOR_USER_ID, VISIT_ID, EXAM_TIME, `DESC`, LOCATION) values (?, ?, ?, ?, ?, ?)")
		_, err = relatedItemSt.Exec(patientID, userID, visitID, req.DateTime, req.Details, req.Subtitle)
		defer relatedItemSt.Close()
		if err != nil {
			return errors.New("Unable to save Exam")
		}
	}
	// save new prescription
	if filter == "2" {
		//validate values
		if req.Title == "" {
			return errors.New("Medication Name is required")
		}
		if req.Subtitle == "" {
			return errors.New("Refills are required")
		}
		var refills int64
		refills, err = strconv.ParseInt(req.Subtitle, 0, 64)
		if err != nil {
			return errors.New("Refills must be a number")
		}
		if refills < 0 {
			return errors.New("Refills cannot be negative")
		}
		if refills > 21 {
			return errors.New("Refills cannot be more than 20")
		}
		if req.Details == "" {
			return errors.New("Instructions are required")
		}
		relatedItemSt, _ := db.Prepare("insert into `dod`.`PRESCRIPTIONS` (PATIENT_USER_ID, DOCTOR_USER_ID, VISIT_ID, `NAME`, INSTRUCTIONS, REFILLS, CREATED_TIME) values (?, ?, ?, ?, ?, ?, NOW())")
		_, err = relatedItemSt.Exec(patientID, userID, visitID, req.Title, req.Details, refills)
		defer relatedItemSt.Close()
		if err != nil {
			return errors.New("Unable to save Exam")
		}
	}

	return nil
}

func dbGetVisitDetail(sessionID string, visitIDstr string) (DetailResponse, error) {
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

	visitID, numErr := strconv.ParseInt(visitIDstr, 0, 64)
	if numErr != nil {
		return resp, errors.New("Refills must be a number")
	}

	//build query string
	getQueryStr := "SELECT u.PHOTO as PHOTO, VISIT_TIME as DATETIME, CONCAT('Visited ', u.NAME) as TITLE,'Visit' as LABEL, '" + LABEL_COLOR_VISIT + "' as LABEL_COLOR, NOTES as `DESC`, VISIT_REASON as SUBTITLE FROM dod.VISITS v LEFT OUTER JOIN dod.USERS u on v.DOCTOR_USER_ID = u.USER_ID WHERE v.VISIT_ID = ? AND v.`PATIENT_USER_ID` = ?"
	if role == "doctor" {
		getQueryStr = strings.Replace(getQueryStr, "`PATIENT_USER_ID`", "`DOCTOR_USER_ID`", 1)
	}
	visitSt, _ := db.Prepare(getQueryStr)
	defer visitSt.Close()

	err := visitSt.QueryRow(visitID, userID).Scan(&resp.Photo, &resp.DateTime, &resp.Title, &resp.Label, &resp.LabelColor, &resp.Details, &resp.Subtitle)
	if err != nil {
		return resp, err //errors.New("Unable to find visit")
	}

	resp.RelatedItemsURL = "/api/getVisitRelatedItems?sessionID=" + sessionID + "&visitID=" + visitIDstr

	if role == "doctor" {
		resp.DetailsEditable = true
		resp.UpdateURL = "/api/UpdateVisit"
	}

	return resp, nil
}

func dbUpdateVisit(sessionID string, visitID string, req UpdateVisitRequest) error {
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
	visitSt, _ := db.Prepare("update dod.`VISITS` v set v.`NOTES` = ? where v.`VISIT_ID` = ? and v.DOCTOR_USER_ID = ?")
	_, err := visitSt.Exec(req.Details, visitID, userID)
	defer visitSt.Close()
	if err != nil {
		return errors.New("Unable to update visit")
	}

	return nil
}

func UpdateVisit(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	visitID := r.URL.Query().Get("visitID")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}
	if visitID == "" {
		http.Error(w, "Missing required visitID parameter", 400)
		return
	}

	var input UpdateVisitRequest

	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "Unable to understand request", 400)
		return
	}

	if err := dbUpdateVisit(sessionID, visitID, input); err != nil {
		if err.Error() == "Bad Session" {
			http.Error(w, "Invalid credentials", 401)
			return
		}
		http.Error(w, err.Error(), 400)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func AddVisitRelatedItems(w http.ResponseWriter, r *http.Request) {
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

	var input AddRelatedItemsRequest
	var err error

	err = json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Unable to understand request", 400)
		return
	}

	err = dbAddVisitRelatedItems(sessionID, visitID, filter, input)

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

func GetVisitRelatedItems(w http.ResponseWriter, r *http.Request) {
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

	output, err := dbGetVisitRelatedItems(sessionID, visitID, filter)

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

func GetVisitDetail(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	visitID := r.URL.Query().Get("visitID")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}
	if visitID == "" {
		http.Error(w, "Missing required visitID parameter", 400)
		return
	}

	output, err := dbGetVisitDetail(sessionID, visitID)

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

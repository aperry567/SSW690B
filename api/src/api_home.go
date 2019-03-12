/*
 * Doctors on Demand API
 */

package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
)

type ListFilter struct {
	Title string `json:"title"`
	Value string `json:"value"`
}

type ListItem struct {
	Label      string `json:"label,omitempty"`
	LabelColor string `json:"labelColor,omitempty"`
	Photo      string `json:"photo,omitempty"`
	Title      string `json:"title"`
	Subtitle   string `json:"subtitle,omitempty"`
	DateTime   string `json:"dateTime"`
	Details    string `json:"details,omitempty"`
	DetailLink string `json:"detailLink,omitempty"`
}

type ListResponse struct {
	Filters []ListFilter `json:"filters"`
	Items   []ListItem   `json:"items"`
}

func dbGetPatientHomeItemsGet(sessionID string, filter string) (ListResponse, error) {
	dbUserClearSessions()

	db := getDB()
	userID := dbGetUserID(sessionID)

	var response ListResponse

	var examSelect string
	var visitSelect string
	var prescriptSelect string

	examSelect = "SELECT '' as PHOTO, EXAM_TIME as DATETIME, 'Exam' as TITLE, 'Exam' as LABEL, '0xff227cd6' as LABEL_COLOR, `DESC`, LOCATION as SUBTITLE, EXAM_ID as ID FROM dod.EXAMS WHERE PATIENT_USER_ID = ?"
	visitSelect = "SELECT u.PHOTO as PHOTO, VISIT_TIME as DATETIME, CONCAT('Visited ', u.NAME) as TITLE,'Visit' as LABEL, '0xffcef7b7' as LABEL_COLOR, NOTES as `DESC`, VISIT_REASON as SUBTITLE, VISIT_ID as ID FROM dod.VISITS v LEFT OUTER JOIN dod.USERS u on v.DOCTOR_USER_ID = u.USER_ID WHERE v.PATIENT_USER_ID = ?"
	prescriptSelect = "SELECT '' as PHOTO, CREATED_TIME as DATETIME, NAME as TITLE, 'Rx' as LABEL,'0xff24d622' as LABEL_COLOR, INSTRUCTIONS as `DESC`, CONCAT('Refills: ', REFILLS) as SUBTITLE, PRESCRIPTION_ID as ID FROM dod.PRESCRIPTIONS WHERE PATIENT_USER_ID = ?"

	var selectSt *sql.Stmt
	var rows *sql.Rows
	var err error

	// all
	if filter == "" {
		selectSt, _ = db.Prepare(examSelect + " UNION ALL " + prescriptSelect + " UNION ALL " + visitSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(userID, userID, userID)
		defer selectSt.Close()
	}
	// exam
	if filter == "1" {
		selectSt, _ = db.Prepare(examSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(userID)
		defer selectSt.Close()
	}
	// visit
	if filter == "2" {
		selectSt, _ = db.Prepare(visitSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(userID)
		defer selectSt.Close()
	}
	// prescription
	if filter == "3" {
		selectSt, _ = db.Prepare(prescriptSelect + " ORDER BY DATETIME DESC")
		rows, err = selectSt.Query(userID)
		defer selectSt.Close()
	}

	if err != nil {
		return response, errors.New("Unable to fetch home items")
	}

	response.Items = []ListItem{}
	for rows.Next() {
		var item ListItem
		var id string
		if err := rows.Scan(&item.Photo, &item.DateTime, &item.Title, &item.Label, &item.LabelColor, &item.Details, &item.Subtitle, &id); err != nil {
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
			Title: "Prescriptions",
			Value: "filter=3",
		},
	)

	return response, nil
}

/*GetPatientHomeItemsGet details
Takes in:

sessionID
listFilter
returns:
List response

List will be comprised of exam, visit and prescription items sorted date desc.
List items must have labels and colors (colors must look good with white text)
visit: blue
exams: red
prescription: black

Filters for each type with default to a
*/
func GetPatientHomeItemsGet(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	listFilter := r.URL.Query().Get("listFilter")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}

	output, err := dbGetPatientHomeItemsGet(sessionID, listFilter)

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

/*
 * Doctors on Demand API find a doctor
 */

package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
)

type QuestionnaireResponse struct {
	Question         string `json:"question"`
	MoreQuestionsURL string `json:"moreQuestionsURL"`
	FindDoctorURL    string `json:"findDoctorURL"`
}

func dbGetQuestionnaire(sessionID string, questionID string) ([]QuestionnaireResponse, error) {
	dbUserClearSessions()

	db := getDB()
	_, role := dbGetUserIDAndRole(sessionID)

	var resp []QuestionnaireResponse

	if role != "patient" {
		return resp, errors.New("Only patients can use the questionnaire")
	}

	var selectSt *sql.Stmt
	var rows *sql.Rows
	var err error
	var selectStr string

	if questionID == "" {
		selectStr = "SELECT QUESTION_ID, QUESTION, DOCTOR_SPECIALTY_ID FROM dod.QUESTIONNAIRE where PARENT_ID is null"
	} else {
		selectStr = "SELECT QUESTION_ID, QUESTION, DOCTOR_SPECIALTY_ID FROM dod.QUESTIONNAIRE where PARENT_ID = ?"
	}

	selectSt, err = db.Prepare(selectStr)
	defer selectSt.Close()

	if questionID == "" {
		rows, err = selectSt.Query()
	} else {
		rows, err = selectSt.Query(questionID)
	}
	defer rows.Close()

	if err != nil {
		return resp, errors.New("Unable to fetch questions")
	}

	for rows.Next() {
		var item QuestionnaireResponse
		var id string
		var specialtyID sql.NullString
		if err := rows.Scan(&id, &item.Question, &specialtyID); err != nil {
			fmt.Println(err.Error())
			return resp, errors.New("Unable to fetch specific question")
		}
		if specialtyID.Valid {
			item.FindDoctorURL = "/api/findADoctor?sessionID=" + sessionID + "&questionID=" + id
		} else {
			item.MoreQuestionsURL = "/api/getQuestionnaire?sessionID=" + sessionID + "&questionID=" + id
		}
		resp = append(resp, item)
	}

	return resp, nil
}

func dbFindADoctor(sessionID string, questionID string) (ListResponse, error) {
	dbUserClearSessions()

	var resp ListResponse

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

	if role != "patient" {
		return resp, errors.New("Must be a patient to use")
	}

	//build query string
	getQueryStr := "select d.USER_ID, d.NAME, CONCAT(d.CITY, ', ', d.STATE), d.PHOTO from dod.QUESTIONNAIRE q left outer join dod.USERS_DOCTOR_SPECIALITIES uds ON uds.DOCTOR_SPECIALITIES_ID = q.DOCTOR_SPECIALTY_ID left outer join dod.USERS d ON d.USER_ID = uds.USER_ID left outer join dod.LICENSES l ON l.USER_ID = d.USER_ID left outer join dod.USERS p ON p.STATE = l.STATE where q.QUESTION_ID = ? and p.USER_ID = ? order by d.`NAME`"
	doctorSt, _ := db.Prepare(getQueryStr)
	defer doctorSt.Close()

	rows, err := doctorSt.Query(questionID, userID)
	if err != nil {
		return resp, errors.New("Unable to find a Doctor")
	}

	for rows.Next() {
		var item ListItem
		var id string
		item.Label = "Doctor"
		item.LabelColor = LABEL_COLOR_DOCTOR
		item.ScreenType = "detail"
		if err := rows.Scan(&id, &item.Title, &item.Subtitle, &item.Photo); err != nil {
			return resp, errors.New("Unable to fetch doctor")
		}
		item.DetailLink = "/api/createVisit?questionID=" + questionID + "&sessionID=" + sessionID + "&doctorID=" + id
		resp.Items = append(resp.Items, item)
	}
	return resp, nil
}

func GetQuestionnaire(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	defer r.Body.Close()

	sessionID := r.URL.Query().Get("sessionID")
	questionID := r.URL.Query().Get("questionID")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}

	output, err := dbGetQuestionnaire(sessionID, questionID)

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

func FindADoctor(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	defer r.Body.Close()

	sessionID := r.URL.Query().Get("sessionID")
	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}
	questionID := r.URL.Query().Get("questionID")
	if sessionID == "" {
		http.Error(w, "Missing required questionID parameter", 400)
		return
	}

	output, err := dbFindADoctor(sessionID, questionID)

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

/*
 * Doctors on Demand API questionnaire
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
	MoreQuestionsURL string `json:"moreQuestionsURL,omitempty"`
	FindDoctorURL    string `json:"findDoctorURL,omitempty"`
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

func GetQuestionnaire(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

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

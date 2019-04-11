/*
 * Doctors on Demand API exam
 */

package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"
)

type UpdateExamRequest struct {
	Details  string `json:"details"`
	Subtitle string `json:"subtitle"`
	DateTime string `json:"dateTime"`
}

func dbGetExamDetail(sessionID string, examIDstr string) (DetailResponse, error) {
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

	examID, numErr := strconv.ParseInt(examIDstr, 0, 64)
	if numErr != nil {
		return resp, errors.New("Refills must be a number")
	}

	//build query string
	getQueryStr := "SELECT `EXAM_TIME`, `DESC`, `LOCATION` FROM dod.EXAMS WHERE `EXAM_ID` = ? AND `PATIENT_USER_ID` = ?"
	if role == "doctor" {
		getQueryStr = strings.Replace(getQueryStr, "`PATIENT_USER_ID`", "`DOCTOR_USER_ID`", 1)
	}
	examSt, errSt := db.Prepare(getQueryStr)
	defer examSt.Close()

	if errSt != nil {
		fmt.Println(errSt.Error())
	}

	err := examSt.QueryRow(examID, userID).Scan(&resp.DateTime, &resp.Title, &resp.Subtitle)
	if err != nil {
		return resp, errors.New("Unable to find exam")
	}
	resp.Label = "Exam"
	resp.LabelColor = LABEL_COLOR_EXAM

	if role == "doctor" {
		resp.SubtitleEditable = true
		resp.DateTimeEditable = true
		resp.TitleEditable = true
		resp.UpdateURL = "/api/updateExam?sessionID=" + sessionID + "&examID=" + examIDstr
		resp.DeleteURL = "/api/deleteExam?sessionID=" + sessionID + "&examID=" + examIDstr
	}

	return resp, nil
}

func dbUpdateExam(sessionID string, examID string, req UpdateExamRequest) error {
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

	if req.Details == "" {
		return errors.New("Details cannot be empty")
	}

	if req.DateTime == "" {
		return errors.New("DateTime cannot be empty")
	}

	if req.Subtitle == "" {
		return errors.New("Subtitle cannot be empty")
	}

	_, err = time.Parse("2006-01-02 15:04:05", req.DateTime)
	if err != nil {
		return errors.New("Invalid Exam Time format YYYY-MM-DD hh:mm:ss")
	}

	//build query string
	examSt, _ := db.Prepare("update dod.`EXAMS` set `DESC` = ?, LOCATION = ?, EXAM_TIME = ? where `EXAM_ID` = ? and DOCTOR_USER_ID = ?")
	_, err = examSt.Exec(req.Details, req.Subtitle, req.DateTime, examID, userID)
	defer examSt.Close()
	if err != nil {
		return errors.New("Unable to update exam")
	}

	dbAuditAction(userID, "Exam:Updated")

	return nil
}

func dbDeleteExam(sessionID string, examID string) error {
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

	examSt, _ := db.Prepare("DELETE FROM `dod`.`EXAMS` WHERE EXAM_ID = ? AND DOCTOR_USER_ID = ?")
	_, err = examSt.Exec(examID, userID)
	defer examSt.Close()
	if err != nil {
		return errors.New("Unable to delete exam")
	}

	dbAuditAction(userID, "Exam:Deleted")
	return nil
}

func UpdateExam(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	examID := r.URL.Query().Get("examID")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}
	if examID == "" {
		http.Error(w, "Missing required visitID parameter", 400)
		return
	}

	var input UpdateExamRequest

	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "Unable to understand request", 400)
		return
	}

	if err := dbUpdateExam(sessionID, examID, input); err != nil {
		if err.Error() == "Bad Session" {
			http.Error(w, "Invalid credentials", 401)
			return
		}
		http.Error(w, err.Error(), 400)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func GetExamDetail(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	examID := r.URL.Query().Get("examID")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}
	if examID == "" {
		http.Error(w, "Missing required examID parameter", 400)
		return
	}

	output, err := dbGetExamDetail(sessionID, examID)

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

func DeleteExam(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	examID := r.URL.Query().Get("examID")

	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}
	if examID == "" {
		http.Error(w, "Missing required examID parameter", 400)
		return
	}

	err := dbDeleteExam(sessionID, examID)

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

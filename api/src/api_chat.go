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
	"time"
)

type Chat struct {
	UserID          int    `json:"userID"`
	Msg             string `json:"msg"`
	IsRead          bool   `json:"isRead"`
	CreatedDateTime string `json:"createdDateTime"`
}
type ChatPhoto struct {
	ID            sql.NullInt64  `json:"id"`
	Photo         sql.NullString `json:"photo"`
	Name          sql.NullString `json:"name"`
	IsCurrentUser bool           `json:"isCurrentUser"`
}
type ChatResponse struct {
	Chats  []Chat      `json:"chats"`
	Photos []ChatPhoto `json:"photos,omitempty"`
}

/**dbGetVisitChat
onlyUnread will not return the photos part of the response as it's assumed the ui already has this and just wants any new messages
calling this api will always set the messages to read for the alternate person who sent them
**/
func dbGetVisitChat(sessionID string, visitID string, timeLastRead string) (ChatResponse, error) {
	dbUserClearSessions()

	db := getDB()
	userID := dbGetUserID(sessionID)

	var response ChatResponse

	// get visit user photos and name
	// this ensures the user is a part of the visit for security
	visitSt, errVisit := db.Prepare("SELECT p.USER_ID, p.PHOTO, p.NAME, d.USER_ID, d.PHOTO, d.NAME FROM dod.VISITS v LEFT OUTER JOIN dod.USERS p on v.PATIENT_USER_ID = p.USER_ID LEFT OUTER JOIN dod.USERS d on v.DOCTOR_USER_ID = p.USER_ID WHERE v.VISIT_ID = ? and (PATIENT_USER_ID = ? or DOCTOR_USER_ID = ?)")
	if errVisit != nil {
		fmt.Println(errVisit.Error())
	}
	var patientInfo ChatPhoto
	var doctorInfo ChatPhoto
	visitErr := visitSt.QueryRow(visitID, userID, userID).Scan(&patientInfo.ID, &patientInfo.Photo, &patientInfo.Name, &doctorInfo.ID, &doctorInfo.Photo, &doctorInfo.Name)
	defer visitSt.Close()
	if visitErr != nil {
		fmt.Println(visitErr.Error())
		return response, errors.New("Unable to fetch people in chat")
	}

	// if not onlyUnreadBool then return the photos in the response
	if timeLastRead == "" {
		patientInfo.IsCurrentUser = patientInfo.ID.Int64 == int64(userID)
		doctorInfo.IsCurrentUser = doctorInfo.ID.Int64 == int64(userID)
		response.Photos = []ChatPhoto{patientInfo, doctorInfo}
	}

	// get visit chat
	var rows *sql.Rows
	var chatErr error
	chatQuery := "SELECT USER_ID, MSG, CREATED_DT, IS_READ FROM dod.VISITS_CHAT where VISIT_ID = ?"
	if timeLastRead != "" {
		chatQuery += " and CREATED_DT > ?"
	}
	chatSt, _ := db.Prepare(chatQuery + " ORDER BY CREATED_DT ASC")
	if timeLastRead != "" {
		rows, chatErr = chatSt.Query(visitID, timeLastRead)
	} else {
		rows, chatErr = chatSt.Query(visitID)
	}

	defer chatSt.Close()
	if chatErr != nil {
		return response, errors.New("Unable to fetch chats")
	}
	for rows.Next() {
		var chat Chat
		if err := rows.Scan(&chat.UserID, &chat.Msg, &chat.CreatedDateTime, &chat.IsRead); err != nil {
			fmt.Println(err.Error())
			return response, errors.New("Unable to fetch chat message")
		}
		if chat.UserID != userID {
			chat.IsRead = true
		}
		response.Chats = append(response.Chats, chat)
	}

	//update is reads not from the current user to read
	updateSt, _ := db.Prepare("UPDATE dod.VISITS_CHAT set IS_READ = 1 where VISIT_ID = ? and USER_ID != ?")
	_, updateErr := updateSt.Exec(visitID, userID)
	defer updateSt.Close()
	if updateErr != nil {
		return response, errors.New("Unable to mark chats as read")
	}

	return response, nil
}

func GetVisitChat(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	sessionID := r.URL.Query().Get("sessionID")
	if sessionID == "" {
		http.Error(w, "Missing required sessionID parameter", 400)
		return
	}

	visitID := r.URL.Query().Get("visitID")
	if visitID == "" {
		http.Error(w, "Missing required visitID parameter", 400)
		return
	}

	timeLastRead := r.URL.Query().Get("timeLastRead")
	if timeLastRead != "" {
		_, err := time.Parse("2006-01-02 15:04:05", timeLastRead)
		if err != nil {
			http.Error(w, "Invalid timeLastRead format YYYY-MM-DD hh:mm:ss", 400)
		}
	}

	output, err := dbGetVisitChat(sessionID, visitID, timeLastRead)

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
/*
 * Doctors on Demand API
 */

package main

import (
	"encoding/json"
	"net/http"
)

type ListFilter struct {
	Title string `json:"title"`
	Value string `json:"value"`
}

type ListItem struct {
	Label      string `json:"label"`
	LabelColor string `json:"labelColor"`
	Photo      string `json:"photo"`
	Title      string `json:"title"`
	Subtitle   string `json:"subtitle"`
	DateTime   string `json:"dateTime"`
	Details    string `json:"details"`
	DetailLink string `json:"detailLink"`
}

type ListResponse struct {
	Filters []ListFilter `json:"filters"`
	Items   []ListItem   `json:"items"`
}

func dbGetPatientHomeItemsGet(sessionID string, filter string) (ListResponse, error) {
	return ListResponse{}, nil
}

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

/*
 * Doctors on Demand API
 */

package main

type ListFilterAddDetails struct {
	Label      string `json:"label"`
	FieldName  string `json:"fieldName"`
	Required   bool   `json:"required"`
	IsDateTime bool   `json:"isDateTime"`
}

type ListFilter struct {
	Title      string                 `json:"title"`
	Value      string                 `json:"value"`
	AddURL     string                 `json:"addURL"`
	AddDetails []ListFilterAddDetails `json:"addDetails"`
}

type ListItem struct {
	Label      string `json:"label"`
	LabelColor string `json:"labelColor"`
	Title      string `json:"title"`
	Subtitle   string `json:"subtitle"`
	DateTime   string `json:"dateTime"`
	Details    string `json:"details"`
	ScreenType string `json:"screenType"`
	DetailLink string `json:"detailLink"`
	Photo      string `json:"photo"`
}

type ListResponse struct {
	Filters []ListFilter `json:"filters"`
	Items   []ListItem   `json:"items"`
}

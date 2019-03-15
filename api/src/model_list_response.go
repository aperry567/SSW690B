/*
 * Doctors on Demand API
 */

package main

type ListFilterAddDetails struct {
	Label      string `json:"label"`
	FieldName  string `json:"fieldName"`
	Required   bool   `json:"required"`
	IsDateTime bool   `json:"isDateTime`
}

type ListFilter struct {
	Title      string                 `json:"title"`
	Value      string                 `json:"value"`
	AddURL     string                 `json:"addURL"`
	AddDetails []ListFilterAddDetails `json:"addDetails,omitempty"`
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
	Filters []ListFilter `json:"filters,omitempty"`
	Items   []ListItem   `json:"items"`
}

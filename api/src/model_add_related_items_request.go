package main

type AddRelatedItemsRequest struct {
	Title    string `json:"title"`
	Subtitle string `json:"subtitle"`
	DateTime string `json:"dateTime"`
	Details  string `json:"details"`
}

package main

type DetailResponse struct {
	Title            string `json:"title"`
	TitleEditable    bool   `json:"titleEditable"`
	Subtitle         string `json:"subtitle"`
	SubtitleEditable bool   `json:"subtitleEditable"`
	Label            string `json:"label"`
	LabelEditable    bool   `json:"labelEditable"`
	LabelColor       string `json:"labelColor"`
	DateTime         string `json:"datetime"`
	DateTimeEditable bool   `json:"datetimeEditable"`
	Photo            string `json:"photo"`
	Details          string `json:"details"`
	DetailsEditable  bool   `json:"detailsEditable"`
	ChatURL          string `json:"chatURL,omitempty"`
	RelatedItemsURL  string `json:"relatedItemsURL,omitempty"`
	UpdateURL        string `json:"updateURL,omitempty"`
	DeleteURL        string `json:"deleteURL,omitempty"`
}

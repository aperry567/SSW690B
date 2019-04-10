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
	Details          string `json:"details"`
	DetailsEditable  bool   `json:"detailsEditable"`
	ChatURL          string `json:"chatURL"`
	RelatedItemsURL  string `json:"relatedItemsURL"`
	UpdateURL        string `json:"updateURL"`
	DeleteURL        string `json:"deleteURL"`
	Photo            string `json:"photo"`
}

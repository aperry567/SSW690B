/*
 * Navigation for Doctors and Patients API
 */

//Only return the nav code only

package main

func getNav(s string, r string) []AuthNav {
	if r == "doctor" {
		return doctorNav(s)
	}
	return patientNav(s)
}

func patientNav(s string) []AuthNav {
	var nav []AuthNav

	nav = append(nav, AuthNav{
		Title:      "My Items",
		Icon:       "home",
		APIURL:     "/api/getPatientHomeItems?sessionID=" + s,
		ScreenType: "list",
	}, AuthNav{
		Title:      "Unread Chats",
		Icon:       "chat",
		APIURL:     "/api/getUnreadChats?sessionID=" + s,
		ScreenType: "list",
	}, AuthNav{
		Title:      "Profile",
		Icon:       "person",
		APIURL:     "/api/getProfile?sessionID=" + s,
		ScreenType: "profile",
	})
	return nav
}

func doctorNav(s string) []AuthNav {
	var nav []AuthNav

	nav = append(nav, AuthNav{
		Title:      "Visits",
		Icon:       "home",
		APIURL:     "/api/getDoctorHomeItems?sessionID=" + s,
		ScreenType: "list",
	}, AuthNav{
		Title:      "Unread Chats",
		Icon:       "chat",
		APIURL:     "/api/getUnreadChats?sessionID=" + s,
		ScreenType: "list",
	}, AuthNav{
		Title:      "Patients",
		Icon:       "people",
		APIURL:     "/api//getPatients?sessionID=" + s,
		ScreenType: "list",
	}, AuthNav{
		Title:      "Profile",
		Icon:       "person",
		APIURL:     "/api/getProfile?sessionID=" + s,
		ScreenType: "profile",
	})
	return nav
}

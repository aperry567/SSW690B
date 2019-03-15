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
		Title:      "All",
		Icon:       "home",
		APIURL:     "/api/getPatientHomeItems?sessionID=" + s,
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
		Title:      "All",
		Icon:       "home",
		APIURL:     "/api/getDoctorHomeItems?sessionID=" + s,
		ScreenType: "list",
	}, AuthNav{
		Title:      "Profile",
		Icon:       "person",
		APIURL:     "/api/getProfile?sessionID=" + s,
		ScreenType: "profile",
	})
	return nav
}

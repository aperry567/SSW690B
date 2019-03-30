/*
 * Doctors on Demand API
 */

package main

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/gorilla/mux"
)

type Route struct {
	Name        string
	Method      string
	Pattern     string
	HandlerFunc http.HandlerFunc
}

type Routes []Route

func NewRouter() *mux.Router {
	router := mux.NewRouter().StrictSlash(true)
	router.Path("/swagger.yaml").Handler(http.FileServer(http.Dir(dodAPIRootDir + "/api")))
	router.Path("/").Handler(http.RedirectHandler("https://editor.swagger.io/#?import=http://35.207.6.9:8080/swagger.yaml", 301))
	for _, route := range routes {
		var handler http.Handler
		handler = route.HandlerFunc
		handler = Logger(handler, route.Name)

		router.
			Methods(route.Method).
			Path(route.Pattern).
			Name(route.Name).
			Handler(handler)
	}

	return router
}

func Index(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	fmt.Fprintf(w, "Doctors On Demand API!")
}

var routes = Routes{
	Route{
		"Index",
		"GET",
		"/api/",
		Index,
	},

	Route{
		"LoginPost",
		strings.ToUpper("Post"),
		"/api/login",
		LoginPost,
	},

	Route{
		"LogoutPost",
		strings.ToUpper("Get"),
		"/api/logout",
		LogoutPost,
	},

	Route{
		"PasswordResetPost",
		strings.ToUpper("Post"),
		"/api/passwordRest",
		PasswordResetPost,
	},

	Route{
		"SignupPost",
		strings.ToUpper("Post"),
		"/api/signup",
		SignupPost,
	},

	Route{
		"GetPatientHomeItems",
		strings.ToUpper("Get"),
		"/api/getPatientHomeItems",
		GetPatientHomeItems,
	},

	Route{
		"GetDoctorHomeItems",
		strings.ToUpper("Get"),
		"/api/getDoctorHomeItems",
		GetDoctorHomeItems,
	},

	Route{
		"GetPatients",
		strings.ToUpper("Get"),
		"/api/getPatients",
		GetPatients,
	},

	Route{
		"GetPatientDetail",
		strings.ToUpper("Get"),
		"/api/getPatientDetail",
		GetPatientDetail,
	},

	Route{
		"GetPatientRelatedItems",
		strings.ToUpper("Get"),
		"/api/getPatientRelatedItems",
		GetPatientRelatedItems,
	},

	Route{
		"GetVisitDetail",
		strings.ToUpper("Get"),
		"/api/getVisitDetail",
		GetVisitDetail,
	},

	Route{
		"GetVisitRelatedItems",
		strings.ToUpper("Get"),
		"/api/getVisitRelatedItems",
		GetVisitRelatedItems,
	},

	Route{
		"AddVisitRelatedItems",
		strings.ToUpper("Post"),
		"/api/addVisitRelatedItems",
		AddVisitRelatedItems,
	},

	Route{
		"GetDoctorSpecialities",
		strings.ToUpper("Get"),
		"/api/getDoctorSpecialities",
		GetDoctorSpecialities,
	},

	Route{
		"UpdateVisit",
		strings.ToUpper("Post"),
		"/api/updateVisit",
		UpdateVisit,
	},

	Route{
		"GetProfileGet",
		strings.ToUpper("Get"),
		"/api/getProfile",
		GetProfileGet,
	},

	Route{
		"UpdateProfilePost",
		strings.ToUpper("Post"),
		"/api/updateProfile",
		UpdateProfilePost,
	},

	Route{
		"GetPrescriptionDetail",
		strings.ToUpper("Get"),
		"/api/getPrescriptionDetail",
		GetPrescriptionDetail,
	},

	Route{
		"UpdatePrescription",
		strings.ToUpper("Post"),
		"/api/updatePrescription",
		UpdatePrescription,
	},

	Route{
		"DeletePrescription",
		strings.ToUpper("Get"),
		"/api/deletePrescription",
		DeletePrescription,
	},

	Route{
		"GetExamDetail",
		strings.ToUpper("Get"),
		"/api/getExamDetail",
		GetExamDetail,
	},

	Route{
		"UpdateExam",
		strings.ToUpper("Post"),
		"/api/updateExam",
		UpdateExam,
	},

	Route{
		"DeleteExam",
		strings.ToUpper("Get"),
		"/api/deleteExam",
		DeleteExam,
	},

	Route{
		"GetQuestionnaire",
		strings.ToUpper("Get"),
		"/api/getQuestionnaire",
		GetQuestionnaire,
	},
}

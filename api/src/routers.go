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
	router.Path("/swagger.yaml").Handler(http.FileServer(http.Dir("../api")))
	router.Path("/").Handler(http.RedirectHandler("https://editor.swagger.io/#?import=http://localhost:8080/swagger.yaml", 301))
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
	fmt.Fprintf(w, "Doctors On Demand API")
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
		strings.ToUpper("Post"),
		"/api/logout",
		LogoutPost,
	},

	Route{
		"SignupPost",
		strings.ToUpper("Post"),
		"/api/signup",
		SignupPost,
	},
}

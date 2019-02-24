/*
 * Doctors on Demand API
 */

package main

import (
	"log"
	"net/http"
	"os"

	"github.com/rs/cors"
)

//dodDB database connection string from environment variable DOD_DB
var dodDB string

//dodAPIRootDir root directory for the api source code folder from environment variable DOD_API_ROOT_DIR
var dodAPIRootDir string

func main() {
	log.Printf("Doctors on Demand API Server started")

	dodDB = os.Getenv("DOD_DB")
	if dodDB == "" {
		panic("environment variable DOD_DB must be set")
	}
	dodAPIRootDir = os.Getenv("DOD_API_ROOT_DIR")
	if dodAPIRootDir == "" {
		panic("environment variable DOD_API_ROOT_DIR must be set")
	}

	router := NewRouter()
	log.Fatal(http.ListenAndServe(":8080", cors.Default().Handler(router)))
}

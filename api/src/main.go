/*
 * Doctors on Demand API
 */

package main

import (
	"log"
	"net/http"

	"github.com/rs/cors"
)

func main() {
	log.Printf("Doctors on Demand API Server started")

	router := NewRouter()
	log.Fatal(http.ListenAndServe(":8080", cors.Default().Handler(router)))
}

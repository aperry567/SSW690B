package main

import (
	"fmt"

	"golang.org/x/crypto/bcrypt"
)

func hashPassword(pw string) string {
	pass := []byte(pw)
	hash, err := bcrypt.GenerateFromPassword(pass, bcrypt.MinCost)
	if err != nil {
		fmt.Println(err)
	}
	return string(hash)
}

func checkPassword(pw string, phash string) bool {
	if err := bcrypt.CompareHashAndPassword([]byte(phash), []byte(pw)); err != nil {
		return false
	}
	return true
}

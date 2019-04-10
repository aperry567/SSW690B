package main

import (
	"fmt"
	"strings"

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

/**
 * validatePassword
 *
 * Rules:
 * - min 6 characters
 * - max 16 characters
 * - at least 1 upper case
 * - at least 1 lower case
 * - at least 1 number
 **/
func validatePassword(pw string) bool {
	return len(pw) > 5 && len(pw) < 17 && strings.ContainsAny(pw, "ABCDEFGHIJKLMNOPQRSTUVWXYZ") && strings.ContainsAny(pw, "abcdefghijklmnopqrstuvwxyz") && strings.ContainsAny(pw, "0123456789")
}

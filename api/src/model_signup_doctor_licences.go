/*
 * Doctors on Demand API
 */

package main

type SignupDoctorLicences struct {
	State   *States `json:"state"`
	License string  `json:"license"`
}

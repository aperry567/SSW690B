/*
 * db
 */

package main

import "fmt"
import "database/sql"
import _ "github.com/go-sql-driver/mysql"

func getDB() *sql.DB {
	db, err := sql.Open("mysql", dodDB)
	if err != nil {
		fmt.Println(err.Error())
		return nil
	}

	return db
}

func dbUserClearSessions() {
	db := getDB()
	if db == nil {
		return
	}
	defer db.Close()

	st, err := db.Prepare("delete from `dod`.`SESSIONS` where EXP_DT < current_timestamp()")
	if err != nil {
		fmt.Println(err.Error())
	}
	defer st.Close()

	_, stErr := st.Exec()
	if stErr != nil {
		fmt.Println(stErr.Error())
	}
	defer st.Close()
}

func dbAuditAction(id int, action string) {
	db := getDB()
	if db == nil {
		return
	}
	defer db.Close()

	st, err := db.Prepare("INSERT INTO `dod`.`AUDIT_LOG` (USER_ID, TIMESTAMP, ACTION) VALUES (?, NOW(), ?)")
	if err != nil {
		fmt.Println(err.Error())
	}
	defer st.Close()

	st.Exec(id, action)
}

func dbGetUserID(session string) int {
	db := getDB()
	if db == nil {
		return 0
	}
	defer db.Close()

	st, err := db.Prepare("select USER_ID from `dod`.`SESSIONS` where `SESSION_ID` = ?")
	if err != nil {
		fmt.Println(err.Error())
	}
	defer st.Close()

	var userID int
	st.QueryRow(session).Scan(&userID)

	return userID
}

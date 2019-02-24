# Overview

Uses swagger (https://swagger.io) yaml file for interface but not for generating code.


Built in golang https://golang.org

## Environment Setup

- Install golang https://golang.org/dl/
- IDE Visual Studios Code
  - Add Go extension
- Get go extensions (from the api directory)
  - ```go get github.com/gorilla/mux```
  - ```go get github.com/rs/cors```
  - ```go get github.com/go-sql-driver/mysql```
  - ```go get github.com/google/uuid```
  - ```go get golang.org/x/crypto/bcrypt```
- Set environment variables
  - ```DOD_DB = "db_user:db_password@tcp(address:3306)/dod"```
  - ```DOD_API_ROOT_DIR = "/path/to/api/folder"```
- Setup GCP SDK for command line
  - Download and install GCP (https://cloud.google.com/sdk/docs/#install_the_latest_cloud_tools_version_cloudsdk_current_version)
  - Add in sql proxy component ```gcloud components install cloud_sql_proxy```
  - Login ```gcloud auth login <account_email>```

## Running the API

Get temporary db connection working (expires every 5 min or so)
```gcloud sql connect dod-mysql-db```

Go allows you the ability to run+compile on the the fly which is great for development.
```go run api/src/*.go```

## Documentation

Go here to use the swagger ui (http://editor.swagger.io) then go to the menu File -> Import URL and enter (http://35.207.6.9:8080/swagger.yaml)
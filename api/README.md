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

## Running Code
Go allows you the ability to run+compile on the the fly which is great for development.
```go run api/src/*.go```

## Documentation
Go here to use the swagger ui (http://editor.swagger.io) then go to the menu File -> Import URL and enter (http://35.207.6.9:8080/swagger.yaml)
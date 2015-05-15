package main

import (
	"github.com/julienschmidt/httprouter"
	"log"
	"net/http"
)

func restGetTest(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	http.Error(w, "This is an error, but is seems works.", http.StatusBadRequest)
	return
}

func main() {
	router := httprouter.New()

	router.GET("/test", restGetTest)

	log.Fatal(http.ListenAndServe(":8080", router))
}

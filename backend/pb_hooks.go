package main

import (
	"net/http"

	"github.com/pocketbase/pocketbase/core"
)

func addCORSHeaders(e *core.RequestEvent) error {
	e.Response.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
	e.Response.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
	e.Response.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

	if e.Request.Method == "OPTIONS" {
		return e.NoContent(http.StatusNoContent)
	}

	return e.Next()
}

func init() {
	// This will be called automatically by PocketBase
}

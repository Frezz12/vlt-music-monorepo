package main

type User struct {
	ID           string  `json:"id"`
	Email        string  `json:"email"`
	Name         string  `json:"name"`
	Role         *string `json:"role"`
	Balance      string  `json:"balance"`
	SubAccountID *string `json:"subAccountId"`
}

type LoginResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

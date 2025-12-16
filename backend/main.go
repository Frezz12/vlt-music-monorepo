package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"

	_ "main/migrations"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/plugins/migratecmd"
)

func main() {
	app := pocketbase.New()

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		se.Router.GET("/{path...}", apis.Static(os.DirFS("./pb_public"), false))

		se.Router.GET("/get/token", func(e *core.RequestEvent) error {
			resp, err := http.PostForm("https://studio.mediadice.ru/api/login", url.Values{
				"email":    {"grishanyalinov@gmail.com"},
				"password": {"krokodiladekvatno007"},
			})

			if err != nil {
				return err
			}
			defer resp.Body.Close()
			body, err := io.ReadAll(resp.Body)
			if err != nil {
				return err
			}

			var loginResp LoginResponse
			if err := json.Unmarshal(body, &loginResp); err != nil {
				return err
			}
			collection, err := app.FindCollectionByNameOrId("mediadice_token")
			if err != nil {
				return err
			}

			record := core.NewRecord(collection)
			record.Set("token", loginResp.Token)
			record.Set("mediadice_email", loginResp.User.Email)
			err = app.Save(record)
			if err != nil {
				return nil
			}

			println(loginResp.Token)

			return e.JSON(http.StatusOK, loginResp)
		})

		return se.Next()
	})

	migratecmd.MustRegister(app, app.RootCmd, migratecmd.Config{
		Dir:         "./migrations",
		Automigrate: true,
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}

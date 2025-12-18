package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"
)

func init() {
	m.Register(func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("pbc_2369398911")
		if err != nil {
			return err
		}

		// add field
		if err := collection.Fields.AddMarshaledJSONAt(11, []byte(`{
			"cascadeDelete": false,
			"collectionId": "pbc_497370701",
			"hidden": false,
			"id": "relation611133998",
			"maxSelect": 999,
			"minSelect": 0,
			"name": "tracks",
			"presentable": false,
			"required": false,
			"system": false,
			"type": "relation"
		}`)); err != nil {
			return err
		}

		return app.Save(collection)
	}, func(app core.App) error {
		collection, err := app.FindCollectionByNameOrId("pbc_2369398911")
		if err != nil {
			return err
		}

		// remove field
		collection.Fields.RemoveById("relation611133998")

		return app.Save(collection)
	})
}

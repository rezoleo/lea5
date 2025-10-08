# API Authentication

It is possible to authenticate using an API Key. To do so, an admin must generate an API key for a given entity.
A GET request must be made to the /api endpoint and the api key must be given in the *Authorization* header.

## Example using curl

```
curl http://lea5.fr/api/users -H 'Authorization: Bearer EnterApiKeyHere'
```

You will get the related json

## List of endpoints

- GET /api/users : Get users index
- GET /api/users/_id_ : Get user with the given id
- GET /api/machines : Get machines index
- GET /api/machines/_id_ : Get machine with the given id
- GET /api/machines/_mac_ : Get machine with the given mac address
- GET /api/machines/_mac_?has_connection=1 : Return the corresponding machine if the owner has a valid subscription else it returns a forbidden response
- GET /api/machines/_id_?has_connection=1 : Same as above
- GET /api/machines?has_connection=1 : Filter only machines own by a user with a valid subscription
- GET /api/api_keys : Get api keys index
- POST /api/machines data={"user_id": <user_id>, "machine": {"mac":<mac>,"name":<name>}}: Create a machine with given mac and name for user with the given user_id
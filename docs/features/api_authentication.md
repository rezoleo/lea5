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
- GET /api/users/_n_ : Get user with id _n_
- GET /api/machines : Get machines index
- GET /api/machines/_n_ : Get machine with id _n_
- GET /api/machines?mac=_<mac>_ : Get machine with according to mac address
- GET /api/machines?has_connection=_<whatever>_ : Filter only machines own by a user with a valid subscription (can be combined with other params)
- GET /api/api_keys : Get api keys index
- POST /api/machines data={"user_id": <user_id>, "machine": {"mac":<mac>,"name":<name>}}: Create a machine with given mac and name for user with the given user_id
# API Authentication

It is possible to authenticate using an API Key. To do so, an admin must generate an API key for a given entity.
A GET request must be made to the /api endpoint and the api key must be given in the *Authorization* header.

## Example using curl

```
curl http://lea5.fr/api/users -H 'Authorization: Bearer EnterApiKeyHere'
```

You will get the related json

## List of endpoints

- /api/users : Get users index
- /api/users/_n_ : Get user with id _n_
- /api/machines/_n_ : Get machine with id _n_
- /api/api_keys : Get api keys index
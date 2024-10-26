# API Authentication

It is possible to authenticate using an API Key. To do so, an admin must generate an API key for a given entity.
A GET request must be made to the /api endpoint and the api key must be given in the *Authorization* header.

## Example using curl

```
curl GET http://lea5.fr/api/users.json -H 'Authorization: Bearer EnterApiKeyHere'
```

You will get the related json
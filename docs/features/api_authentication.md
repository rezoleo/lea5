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
- GET /api/users/_id_ : Get user with the given id or username
- GET /api/machines : Get machines index
- GET /api/machines?with_internet_access=true : Filter only machines own by a user with a valid subscription
- GET /api/machines/_id_ : Get machine with the given id or mac address
- GET /api/api_keys : Get api keys index
- POST /api/machines data={"user_id": <user_id>, "machine": {"mac":<mac>,"name":<name>}}: Create a machine with given mac and name for user with the given user_id

## Pagination (on users and machines index endpoints)

Without any pagination parameter, index endpoints return the whole collection.
Pagination is enabled as soon as a request carries `page` and/or `limit`.

`limit` is capped at 200. Filters are applied before paginating, so `GET /api/machines?with_internet_access=true&limit=50`
counts and pages only the machines that match the filter.

Paginated responses carry the page metadata in the headers (see [Pagy docs](https://ddnexus.github.io/pagy/)):

```
Link: <http://lea5.fr/api/users?limit=50>; rel="first", <http://lea5.fr/api/users?limit=50&page=3>; rel="next", <http://lea5.fr/api/users?limit=50&page=9>; rel="last"
Current-Page: 2
Page-Limit: 50
Total-Pages: 9
Total-Count: 419
```

A page number past the end returns `200` with an empty array rather than an error.

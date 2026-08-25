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
- GET /api/machines?with_internet_access=1 : Filter only machines own by a user with a valid subscription
- GET /api/machines/_id_ : Get machine with the given id or mac address
- GET /api/api_keys : Get api keys index
- POST /api/machines data={"user_id": <user_id>, "machine": {"mac":<mac>,"name":<name>}}: Create a machine with given mac and name for user with the given user_id

## Pagination

Index endpoints are **not** paginated by default: without any pagination parameter they return the
whole collection, as they always have.

Pagination is enabled as soon as a request carries `page` or `limit`:

- `?page=2` : Get the second page, using the server-side default page size
- `?limit=50` : Get the first 50 records
- `?page=2&limit=50` : Combine both

`limit` is capped at 200; a larger value is silently reduced to that. Filters are applied before
paginating, so `GET /api/machines?with_internet_access=1&limit=50` counts and pages only the machines that
match the filter.

Paginated responses carry the page metadata in the headers:

```
Link: <http://lea5.fr/api/users?limit=50>; rel="first", <http://lea5.fr/api/users?limit=50&page=3>; rel="next", <http://lea5.fr/api/users?limit=50&page=9>; rel="last"
Current-Page: 2
Page-Limit: 50
Total-Pages: 9
Total-Count: 419
```

The backward link uses `rel="previous"` (not `rel="prev"`).

A page number past the end returns `200` with an empty array rather than an error.
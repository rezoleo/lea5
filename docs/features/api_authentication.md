# API Authentication

It is possible to authenticate using an API Key. To do so, an admin must generate an API key for a given entity and then the authentication is made via the following route : `auth/api`
A GET request must be made to this route and the api key must be given in the *Authorization* header.
If the key is correct, a message is sent by lea5 saying you logged in successfully.
**Important** : The session ID must be saved in order to have full access to the website

## Example using curl


#### To log in
```
curl -v -X GET -c cookies.txt http://lea5.fr/auth/api   -H 'Authorization: Bearer EnterApiKeyHere'
```
The `-c cookies.txt` saves all cookies in a text file in order to obtain the session ID

#### Visit the website
```
curl -v -X GET -b cookies.txt http://lea5.fr/users.json
```
If the session is still active you just have to fetch the session ID via the previously saved cookies using the `-b cookies.txt` parameter and then you can read every page of the website.
# Authentication

The authentication is done via a SSO system.

The general flow for the authentication is described below:
````mermaid
sequenceDiagram
    Lea5 ->>+ SSO: Authenticate user [POST]
    SSO -->>- Lea5: Return authenticated user [GET]
    Lea5 ->>+ DB: Upsert user data
    DB -->>- Lea5: Return user id
    Lea5 ->> Lea5: Create temporary session
````

Configuration for the sso can be found in [`config/initializers/omniauth.rb`](../../config/initializers/omniauth.rb).

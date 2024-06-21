# Subscription

## Add a new subscription to a user
The new user's subscription expiration is determined as follow:
```mermaid
graph TD
    A((Start)) --> B{User's subscription end > now?}
    B --> |Yes| C[Extend user's subscription by subscription duration]
    B --> |No| D[User's subscription ends now + subscription duration]
```

> **Warning**
> If a user has a free access when a subscription is added, the starting date
> of the subscription is based on the subscription expiration status, *not* the internet
> expiration status.

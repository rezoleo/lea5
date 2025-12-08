# Sync Accounts

We use an SSO system to [authenticate our users](./authentication.md). That implies that our users' data are not stored only
on lea5 database. To ensure the consistency of the data, we use a task to synchronize the data from the SSO
to lea5.

## How it works

The synchronization task performs the following operations:

1. **Fetches all users from SSO**: Retrieves all users from the Zitadel SSO server (https://sso.rezoleo.fr/v2/users) using pagination (500 users per page)
2. **Updates existing users**: For each user in the lea5 database, if they exist in the SSO:
   - Updates their `firstname`, `lastname`, `email`, and `username` fields with the latest data from SSO
3. **Removes deleted users**: If a user exists in lea5 but not in the SSO, they are deleted from the database

This ensures that the lea5 database stays in sync with the SSO as the single source of truth for user information.

## Configuration

The task is defined in [`sync_accounts.rake`](../../lib/tasks/sync_accounts.rake), and runs every 3 hours.
The timer is done with service/timer of systemd, the configuration can be found in [systemd folder](../../lib/support/systemd).

The task requires a Personal Access Token (PAT) configured in Rails credentials as `sso_lea5_pat` to authenticate with the SSO API.

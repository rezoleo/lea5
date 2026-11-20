# Sync Accounts

We use an SSO system to [authenticate our users](./authentication.md). That implies that our users' data are not stored only
on lea5 database. To ensure the consistency of the data, we use a task to synchronize the data from the SSO
to lea5.

## How it works

[`SyncAccountsJob`](../../app/jobs/sync_accounts_job.rb) performs the following operations:

1. **Fetches all users from SSO**: Retrieves all users from the Zitadel SSO server (https://sso.rezoleo.fr/v2/users) through `SsoUsersService#all`, using pagination (500 users per page).
2. **Updates existing users**: For each user in the lea5 database linked to the SSO (`oidc_id` set), if they exist in the SSO:
   - Updates their `firstname`, `lastname`, `email`, and `username` fields with the latest data from SSO.
3. **Deactivates deleted users**: If a linked user exists in lea5 but not in the SSO, their `oidc_id` is cleared. The account itself is kept.

This ensures that the lea5 database stays in sync with the SSO as the single source of truth for user information.

## Configuration

The job is scheduled every 3 hours by [GoodJob](https://github.com/bensheldon/good_job)'s cron, configured in [`good_job.rb`](../../config/initializers/good_job.rb)
(production only). GoodJob runs inside the web process and stores its jobs in PostgreSQL.
If the SSO is unreachable, the run fails and the next scheduled run picks up.

To run it manually: `bin/rails runner 'SyncAccountsJob.perform_now'`.

The job requires a Personal Access Token (PAT) configured in Rails credentials as `sso_lea5_pat` to authenticate with the SSO API.

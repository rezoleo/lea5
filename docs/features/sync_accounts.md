# Sync Accounts

We use an SSO system to [authenticate our users](./authentication.md). That implies that our users' data are not stored only
on lea5 database. To ensure the consistency of the data, we use a task to synchronize the data from the SSO
to lea5.

The task is defined in [`sync_accounts.rake`](../../lib/tasks/sync_accounts.rake), and runs every 3 hours.
The timer is done with service/timer of systemd, the configuration can be found in [systemd folder](../../lib/support/systemd).

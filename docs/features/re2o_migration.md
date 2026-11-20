# re2o migration

Users move their own account from re2o to lea5 on the `/migration` page. They keep the internet time they already
paid for, their room and their devices. Sales and invoices stay in re2o and are not imported.

## How it works

1. re2o stops selling. Remaining access dates no longer change, so a single snapshot is enough.
2. The snapshot of re2o accounts with remaining access is exported from re2o and loaded into the `re2o_accounts` table.
3. Each user logs into lea5 with the SSO, proves they own a re2o account, and claims it.

A claim attaches the re2o account to the logged-in lea5 user. It never creates a user and never changes the lea5
name, email, username or wifi password. Each re2o account can be claimed once, and each lea5 user can claim only
one re2o account (unique index on `re2o_accounts.claimed_by_user_id`).

## Proving ownership

In this order, on `/migration`:

- **Email match**: the re2o email is the same as the SSO email. The SSO verifies emails, so this is enough, and the
  user gets a one-click import. Few people match: re2o did not require the school email.
- **re2o password**: checked against the NTLM hash re2o stored (`pwd_ntlm`).
- **Email link**: once the typed username matches an account, the page shows "or send an email to j\*\*\*@g\*\*\*.com".
  The link goes to the email from the snapshot, never to a typed address. It is valid 24 hours and stops working
  once the account is claimed. Opening it only shows a confirmation button, because mail scanners open links.
- **Helpdesk**: an admin links the account by hand from the user's profile ("Link a re2o account").

Attempts are rate-limited per user and per re2o account. The masked email lookup tells a logged-in user whether a re2o
username exists, which is accepted.

## What is imported

Nothing existing is overwritten. Everything that is skipped is listed on the report shown after the claim, and saved in
`re2o_accounts.claim_report`.

| Item     | Rule                                                                                                                            |
|----------|---------------------------------------------------------------------------------------------------------------------------------|
| Access   | The remaining re2o time becomes a `FreeAccess` with reason `Migration re2o`, starting when the user's current access ends.      |
| Room     | Kept if the user already has one. Otherwise the re2o room (uppercased) is assigned, unless it is unknown or occupied.            |
| Machines | Added only. A MAC already on the user's account or on another account is skipped. A failing machine does not cancel the claim. |

Buying a subscription in lea5 also starts after the current access, including the migration free access
(`User#extend_subscription`), so claiming before or after paying gives the same result.

## Running the migration

Export the snapshot on the re2o server, after sales are frozen:

```
python3 manage.py shell < export_snapshot.py > re2o_snapshot.json
```

The script is [`lib/re2o/export_snapshot.py`](../../lib/re2o/export_snapshot.py). It keeps active members with access
ending in the future and no ban. The end date follows re2o's rule: the earliest of membership and connection end,
or the whitelist end if later.

Load it into lea5:

```
bin/rails "lea5:import_re2o_snapshot[re2o_snapshot.json]"
```

The task can be run again: it updates the snapshot columns and keeps claims and reports.

Before opening the page in production:

- configure SMTP and the mailer sender (`ApplicationMailer` still sends from `from@example.com`);
- set `config.action_mailer.default_url_options` in production, or the emailed links cannot be built.

# Internet expiration mail

To avoid last minute renewal of subscriptions, we send an email to users 7 days and 1 day before their Internet access expires.
The task is defined in [`internet_expiration_mail.rake`](../../lib/tasks/internet_expiration_mail.rake), and runs every day.

> **Warning**
> The task does not currently handle running more than once a day, to prevent sending multiple emails.
> This means it also cannot "catch up" if an email was not sent.

The timer is done with service/timer of systemd, the configuration can be found in [systemd folder](../../lib/support/systemd).

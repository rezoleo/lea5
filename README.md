# README

## Requirements

- Ruby version 2.7.1
- Node v12.18.3
- PostgreSQL 12.4+

It is recommended to use [rbenv][rbenv] and [nvm][nvm] to install both language runtimes.

[rbenv]: https://github.com/rbenv/rbenv
[nvm]: https://github.com/nvm-sh/nvm

## Development

1. Install PostgreSQL
2. Create a `lea5` user: `sudo --user postgres createuser lea5 --createdb --pwprompt`, and enter `lea5` as a password
3. Create a development database: `sudo --user postgres createdb lea5_development --owner=lea5`
4. Create a test database: `sudo --user postgres createdb lea5_test --owner=lea5`
5. Clone the project
6. Edit [`config/database.yml`](config/database.yml) if you chose a different password

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Inspirations

- Our original project [Lea4][lea4]. We had to move to Re2o when we became independant and needed to manage subscriptions.
- [Re2o][re2o], which we used for 4 years. Unfortunately it does too much, and is too complex to configure, use and maintain.

[lea4]: https://github.com/rezoleo/le4/
[re2o]: https://gitlab.federez.net/re2o/re2o

## License

[MIT](./LICENSE)

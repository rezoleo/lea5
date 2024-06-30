# README

[![codecov](https://codecov.io/github/rezoleo/lea5/graph/badge.svg?token=3WJ4FUMWIF)](https://codecov.io/github/rezoleo/lea5)
[![Lint & test](https://github.com/rezoleo/lea5/actions/workflows/test.yml/badge.svg)](https://github.com/rezoleo/lea5/actions/workflows/test.yml)

## Requirements

- Ruby version 3.1.2 (see [.ruby-version](.ruby-version))
- PostgreSQL 12.4+

It is recommended to use [rbenv][rbenv] to install a specific Ruby version.

[rbenv]: https://github.com/rbenv/rbenv

## Development

1. Install Ruby with the correct version (run `rbenv version` to check)
2. Install PostgreSQL
3. Clone the project
4. Install dependencies with `bundle install`
5. Initialize the database (users, databases) by running [`init_db.sql`](.github/workflows/init_db.sql): `sudo --user postgres psql < ./.github/workflows/init_db.sql`
6. (Optional) Edit [`config/database.yml`](config/database.yml) if you chose a different password
7. Install [Overcommit](https://github.com/sds/overcommit): `bundle exec overcommit --install`
8. Add a `master.key` file in the `config` folder and add the key from vault

## Tests

The basic command to run tests is `rails test`.

By default, "system" tests (end-to-end tests with a real browser) are not run with `rails test`. You need to
run `rails test:system` to run them specifically, or `rails test:all`. System tests execute in a headless Chrome/Chromium
browser (meaning the browser window will not appear), but you can select your browser of choice (Chrome, Firefox or
Firefox Nightly) and configure the headless behaviour with the following commands:
- `rails test:system:chrome`
- `rails 'test:system:chrome[headless]'`
- `rails test:system:firefox`
- `rails 'test:system:firefox[headless]'`
- `rails 'test:system:firefox[nightly]'`
- `rails 'test:system:firefox[nightly,headless]'`

Note that if you pass arguments to the rails tasks (using square brackets), you need to quote the entire task name or
else your shell will probably try to expand the brackets (see the examples above).

We use a bit of tooling around tests to help us and increase our confidence in our code:
- [Minitest][minitest] and [minitest-reporters][minitest-reporters] are used to polish test outputs
- [Guard][guard] is set up to run tests automatically on changes. You can start it with `bundle exec guard`
- Test coverage is done with [Simplecov][simplecov]. After running your tests, open `coverage/index.html` in the browser of your choice.
  For the tests to pass, there must be a minimum global coverage of 90% and 80% per branch and file.

[minitest]: https://guides.rubyonrails.org/testing.html
[minitest-reporters]: https://rubygems.org/gems/minitest-reporters
[guard]: https://github.com/guard/guard
[simplecov]: https://github.com/simplecov-ruby/simplecov

## Secrets

We are using the secrets management provided by rails. The secrets are encrypted by a master key, and are stored in
`config/credentials.yml.enc`.
To edit the secrets, use the command `EDITOR="nano" rails credentials:edit` (if you don't have nano, use another editor).

## Documentation

See the [docs](docs) folder for the documentation.

For now only the results of a [brainstorming session about our requirements][definition-des-besoins] is available.

[<img alt="Requirements" src="docs/definition-des-besoins/Lea5-Definition-des-besoins.png" width="230" height="130">][definition-des-besoins]

[definition-des-besoins]: docs/definition-des-besoins/README.md

## Inspirations

- Our original project [Lea4][lea4]. We had to move to Re2o when we became independent and needed to manage subscriptions.
- [Re2o][re2o], which we used for 4 years. Unfortunately it does too much, and is too complex to configure, use and maintain.

[lea4]: https://github.com/rezoleo/le4
[re2o]: https://gitlab.federez.net/re2o/re2o

## License

[MIT](LICENSE)

---

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

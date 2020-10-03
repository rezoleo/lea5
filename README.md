# README

## Requirements

- Ruby version 2.7.1 (see [.ruby-version](.ruby-version))
- Node v12.18.4 (see [.nvmrc](.nvmrc))
- PostgreSQL 12.4+

It is recommended to use [rbenv][rbenv] and [nvm][nvm] to install both language runtimes.

[rbenv]: https://github.com/rbenv/rbenv
[nvm]: https://github.com/nvm-sh/nvm

## Development

1. Install NodeJS and Ruby in the correct versions (run `rbenv version` and `nvm use` to check)
2. Install PostgreSQL
3. Clone the project
4. Install dependencies:
   1. `bundle install`
   2. `npm install`
5. Initialize the database (users, databases) by running [`init_db.sql`](.github/workflows/init_db.sql): `sudo --user postgres psql < ./.github/workflows/init_db.sql`
6. (Optional) Edit [`config/database.yml`](config/database.yml) if you chose a different password

## Tests

- [Minitest][minitest] and [minitest-reporters][minitest-reporters] are used to polish test outputs
- [Guard][guard] is setup to run tests automatically on changes. You can start it with `bundle exec guard`
- Test coverage is done with [Simplecov][simplecov]. After running your tests, open `coverage/index.html` in the browser of your choice.
  For the tests to pass, there must be a minimum global coverage of 90% and 80% per branch and file.

[minitest]: https://guides.rubyonrails.org/testing.html
[minitest-reporters]: https://rubygems.org/gems/minitest-reporters/versions/1.1.11
[guard]: https://github.com/guard/guard
[simplecov]: https://github.com/simplecov-ruby/simplecov

## Documentation

See the [docs](docs/) folder for the documentation.

For now only the results of a [brainstorming session about our requirements][definition-des-besoins] is available.

[<img alt="Requirements" src="docs/definition-des-besoins/Lea5-Definition-des-besoins.png" width="230" height="130">][definition-des-besoins]

[definition-des-besoins]: docs/definition-des-besoins/README.md

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

- Ruby version

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

- ...

## Inspirations

- Our original project [Lea4][lea4]. We had to move to Re2o when we became independant and needed to manage subscriptions.
- [Re2o][re2o], which we used for 4 years. Unfortunately it does too much, and is too complex to configure, use and maintain.

[lea4]: https://github.com/rezoleo/le4/
[re2o]: https://gitlab.federez.net/re2o/re2o

## License

[MIT](./LICENSE)

# Payroll Salary Management

Minimal salary management tool for an HR manager operating over a 10,000 employee organization.

## Stack

- Backend: Rails 8 API, PostgreSQL
- Frontend: React, TypeScript, Vite
- Tests: RSpec, FactoryBot, request specs, model specs

## Product Scope

The app supports:

- Add, view, update, and delete employees
- Capture employee code, full name, email, department, job title, country, address, salary, pay frequency, employment type, and status
- View salary metrics by country: employee count, minimum salary, average salary, maximum salary
- View average salary for a selected job title in a selected country
- View salary-band distribution and top roles by headcount
- Seed 10,000 employees from `db/seed_data/first_names.txt` and `db/seed_data/last_names.txt`

## Running Locally

Backend:

```sh
bin/rails db:create db:migrate db:seed
bin/rails server
```

Frontend:

```sh
cd payroll-web
nvm use
npm install
VITE_API_BASE_URL=http://localhost:3000 npm run dev
```

Open the Vite URL, usually `http://localhost:5173`.

## Verification

```sh
bundle exec rspec
bin/rubocop --no-server
bin/rails zeitwerk:check
cd payroll-web && nvm use && npm run lint && npm run build
```

## Seeding

The seed script is designed for repeated engineering use. It truncates generated employee data and loads 10,000 employees in batches using `insert_all`.

On the local machine used during development, `bin/rails db:seed` completed 10,000 employees in about 4.8 seconds.

## Assessment Notes

See [docs/assessment-notes.md](docs/assessment-notes.md) for product framing, architecture, trade-offs, AI usage, and deployment/demo notes.

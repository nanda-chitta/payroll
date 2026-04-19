# Payroll Salary Management

Minimal salary management tool for an HR manager operating over a 10,000 employee organization.

## Assessment Checklist

- Employee CRUD through the UI: add, view, update, and delete employees.
- Employee data model: full name, employee code, email, department, job title, country, address, salary, pay frequency, employment type, and status.
- Salary insights through the UI: country headcount, minimum salary, average salary, maximum salary, average salary for a selected job title in a selected country, salary bands, and top roles.
- Seed script: deterministic 10,000 employee load using `db/seed_data/first_names.txt` and `db/seed_data/last_names.txt`.
- Backend and frontend are fully wired end to end.
- Tests cover the core API, model, salary insight, and seed behavior.
- Product, architecture, trade-off, AI usage, and demo notes are documented in [docs/assessment-notes.md](docs/assessment-notes.md).
- Commit history is incremental and shows the implementation evolution.

## Stack

- Backend: Rails 8 API, PostgreSQL
- Frontend: React, TypeScript, Vite, MUI Data Grid
- API client: Axios with response camel-casing
- Cache/search: Redis-backed Rails cache and Elasticsearch search with SQL fallback
- Tests: RSpec, FactoryBot, request specs, model specs

## Product Scope

The app supports:

- Add, view, update, and delete employees
- Capture employee code, full name, email, department, job title, country, address, salary, pay frequency, employment type, and status
- View salary metrics by country: employee count, minimum salary, average salary, maximum salary
- View average salary for a selected job title in a selected country
- View salary-band distribution and top roles by headcount
- Seed 10,000 employees from `db/seed_data/first_names.txt` and `db/seed_data/last_names.txt`

## Step-by-Step Local Setup

### 1. Install prerequisites

Required:

- Ruby `3.4.1`
- PostgreSQL
- Node `>=20.19` or `>=22.22`
- npm

Optional for faster production-like behavior:

- Redis at `redis://localhost:6379/1`
- Elasticsearch at `http://localhost:9200`

The app still works without Elasticsearch because employee search falls back to SQL.

### 2. Install backend dependencies

```sh
bundle install
```

### 3. Configure environment

The repo includes local config files for development. If starting fresh, copy the samples and update values as needed:

```sh
cp config/database.yml.sample config/database.yml
cp config/application.yml.sample config/application.yml
```

Useful environment variables:

```sh
REDIS_URL=redis://localhost:6379/1
ELASTICSEARCH_URL=http://localhost:9200
```

### 4. Create, migrate, and seed the database

Backend:

```sh
bin/rails db:create db:migrate db:seed
```

The seed command creates:

- 8 departments
- 10 job titles
- 10,000 employees
- 10,000 primary addresses
- 10,000 current salary records

### 5. Start the backend API

```sh
bin/rails server
```

The API runs at `http://localhost:3000`.

### 6. Install frontend dependencies

```sh
cd payroll-web
nvm use
npm install
```

If `nvm use` selects an older Node version, use a compatible Node manually. During development this worked:

```sh
PATH="$HOME/.nvm/versions/node/v22.21.0/bin:$PATH" npm run build
```

### 7. Start the frontend

```sh
VITE_API_BASE_URL=http://localhost:3000 npm run dev
```

Open the Vite URL, usually `http://localhost:5173`.

## Step-by-Step Product Demo

1. Open the app in the browser.
2. Confirm the seeded employee count is visible in the Employees table.
3. Select a country, for example `India`.
4. Select a job title, for example `HR Manager`.
5. Enter a search term and click `Search`.
6. Confirm the table, country salary metrics, selected-role average, salary bands, and top roles all update.
7. Hover the row action icons to see `View`, `Edit`, and `Delete` tooltips.
8. Click the view icon and confirm the read-only employee details dialog opens.
9. Click `Add employee`, complete the form, and save.
10. Click the edit icon, change salary or country, and save.
11. Click the delete icon and confirm the employee is removed.

## Step-by-Step Verification

Run backend tests:

```sh
bundle exec rspec
```

Run the focused API request specs:

```sh
bundle exec rspec spec/requests/api/v1/employees_spec.rb spec/requests/api/v1/lookups_spec.rb spec/requests/api/v1/salary_insights_spec.rb
```

Run backend quality checks:

```sh
bin/rubocop --no-server
bin/rails zeitwerk:check
```

Run frontend quality checks:

```sh
cd payroll-web
nvm use
npm run lint
npm run build
```

## Seeding

The seed script is designed for repeated engineering use. It truncates generated employee data and loads 10,000 employees in batches using `insert_all`.

On the local machine used during development, `bin/rails db:seed` completed 10,000 employees in about 4.8 seconds.

## Architecture Summary

Backend:

- `Api::V1::EmployeesController` exposes employee CRUD.
- `EmployeeManagement::AppServices::EmployeeService` coordinates validation and repository access.
- `EmployeeManagement::Infrastructures::Repos::EmployeeRepository` owns filtering, caching, persistence, and Elasticsearch-backed text search with SQL fallback.
- `EmployeeManagement::AppServices::Validators::EmployeeParam` validates employee create/update attributes.
- `Payroll::SalaryInsights::CountryReport` computes aggregate salary metrics and uses cache for repeated reads.

Frontend:

- `payroll-web/src/api` centralizes axios configuration, error normalization, and response camel-casing.
- `payroll-web/src/hooks` contains API-backed hooks for employees, lookups, and salary insights.
- `payroll-web/src/components/ui` contains reusable UI primitives, including action icon buttons.
- `SalaryManagementPage` composes filters, metrics, insights, table, and employee form into the HR workflow.

## Deployment Readiness

A deployment-ready path:

1. Provision PostgreSQL.
2. Provision Redis for Rails cache.
3. Provision Elasticsearch if full-text search is required beyond SQL fallback.
4. Set production environment variables:

```sh
DATABASE_URL=...
REDIS_URL=...
ELASTICSEARCH_URL=...
RAILS_MASTER_KEY=...
VITE_API_BASE_URL=https://your-api.example.com
```

5. Run Rails migrations:

```sh
bin/rails db:migrate
```

6. Seed demo data if needed:

```sh
bin/rails db:seed
```

7. Build the frontend:

```sh
cd payroll-web
VITE_API_BASE_URL=https://your-api.example.com npm run build
```

8. Serve `payroll-web/dist` via static hosting or a web server.

## Known Out-of-Scope Items

- Authentication and role-based authorization.
- Audit logs for salary changes.
- A dedicated salary-adjustment workflow in the UI.
- A checked-in video demo file.
- A live deployment URL.

The schema and service boundaries leave room for these next steps without changing the core CRUD and insights workflow.

## Assessment Notes

See [docs/assessment-notes.md](docs/assessment-notes.md) for product framing, architecture, trade-offs, AI usage, and deployment/demo notes.

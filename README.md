# Payroll Salary Management

Minimal salary management tool for an HR manager operating over a 10,000 employee organization.

## Product Framing

The primary user is an HR manager who needs two things quickly:

- operational control over employee records
- immediate salary visibility by country and role

The app is intentionally optimized for that workflow instead of a landing page. The first screen goes straight to filters, salary metrics, employee records, and employee create/update actions.

## Assessment Checklist

- Employee CRUD through the UI: add, view, update, and delete employees.
- Employee data model: full name, employee code, email, department, job title, country, address, salary, pay frequency, employment type, and status.
- Salary insights through the UI: country headcount, minimum salary, average salary, maximum salary, average salary for a selected job title in a selected country, salary bands, and top roles.
- Seed script: deterministic 10,000 employee load using `db/seed_data/first_names.txt` and `db/seed_data/last_names.txt`.
- Backend and frontend are fully wired end to end.
- Tests cover the core API, model, salary insight, seed behavior, and key frontend hooks/components.
- Product, architecture, trade-off, AI usage, and demo notes are documented in [docs/assessment-notes.md](docs/assessment-notes.md).

## Requirement Coverage

### Product Requirements

| Requirement | Status | Notes |
| --- | --- | --- |
| Add, view, update, and delete employees via UI | Implemented | React UI supports create, details view, edit, and delete actions |
| Employee fields must include full name, job title, country, salary, plus meaningful additional data | Implemented | Includes employee code, email, department, address, employment type, status, hire date, salary currency, and pay frequency |
| Minimum, maximum, average salary in a country | Implemented | Available in the salary metric cards |
| Average salary for a given job title in a country | Implemented | Available in the salary insights panel |
| Additional useful metrics for HR manager | Implemented | Country employee count, salary band distribution, and top roles by headcount |
| Seed 10,000 employees from `first_names.txt` and `last_names.txt` | Implemented | `db/seeds.rb` uses deterministic batched inserts |
| Fast, deterministic tests for core behavior | Implemented | Request specs, model specs, seed data specs, and frontend Vitest coverage are included |
| Deployed software | In progress | Render serves the built React frontend from the Rails web service on the same domain; add the live URL after the deploy is stable |
| Video demo | Not included | Suggested demo flow is documented in [docs/assessment-notes.md](docs/assessment-notes.md) |

## ER Diagram

See [docs/er-diagram.md](docs/er-diagram.md) for the dedicated model diagram.

## Stack

- Backend: Rails 8 API, PostgreSQL
- Frontend: React, TypeScript, Vite, MUI Data Grid
- API client: Axios with response camel-casing
- Cache/search: Redis-backed Rails cache and Elasticsearch search with SQL fallback
- Tests: RSpec, FactoryBot, request specs, model specs, Vitest, React Testing Library

## Product Scope

The app supports:

- Add, view, update, and delete employees
- Capture employee code, full name, email, department, job title, country, address, salary, pay frequency, employment type, and status
- View salary metrics by country: employee count, minimum salary, average salary, maximum salary
- View average salary for a selected job title in a selected country
- View salary-band distribution and top roles by headcount
- Seed 10,000 employees from `db/seed_data/first_names.txt` and `db/seed_data/last_names.txt`

## Run With Docker

### 1. Prerequisites

Required:

- Docker Desktop or Docker Engine with Docker Compose

### 2. Start the full stack

From the repo root:

```sh
docker compose up --build
```

This starts:

- PostgreSQL on `localhost:5432`
- Redis on `localhost:6379`
- Elasticsearch on `localhost:9200`
- Rails API on `http://localhost:3000`
- Vite frontend on `http://localhost:4000`

The Rails container runs `db:prepare` on boot, so the database is created and migrated automatically.

### 3. Seed demo data

In a separate terminal:

```sh
docker compose exec web bin/rails db:seed
```

This loads the 10,000 employee dataset used by the UI.

### 4. Open the app

Open:

```text
http://localhost:4000
```

The frontend proxies API requests to the Rails container, so no extra frontend environment variable is required.

### 5. Stop the stack

```sh
docker compose down
```

To also remove the Postgres and Redis volumes:

```sh
docker compose down -v
```

## Run Without Docker

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

### 2. Bootstrap the app with `bin/setup`

From the repo root:

```sh
bin/setup
```

`bin/setup` will:

- install Ruby gems
- install frontend npm packages
- copy `config/database.yml.sample` to `config/database.yml` when needed
- copy `config/application.yml.sample` to `config/application.yml` when needed
- run `bin/rails db:prepare`
- clear logs and temp files
- start `bin/dev`

If you only want the dependencies and database setup without starting the servers:

```sh
bin/setup --skip-server
```

If you want to reset the database during setup:

```sh
bin/setup --reset
```

### 3. Open the app

When `bin/dev` is running, use:

```text
http://localhost:4000
```

`bin/dev` starts Redis, Rails, and the frontend. The frontend now waits for Redis and Rails before opening the browser.

## Manual Local Setup
### 1. Install backend dependencies

```sh
bundle install
```

### 2. Configure environment

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

### 3. Create, migrate, and seed the database

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

### 4. Start the backend API

```sh
bin/rails server
```

The API runs at `http://localhost:3000`.

### 5. Install frontend dependencies

```sh
cd payroll-web
nvm use
npm install
```

If `nvm use` selects an older Node version, use a compatible Node manually. During development this worked:

```sh
PATH="$HOME/.nvm/versions/node/v22.21.0/bin:$PATH" npm run build
```

### 6. Start the frontend

```sh
npm run dev -- --host --port 4000
```

Open `http://localhost:4000`.

### 7. Run the test suites

Backend:

```sh
bundle exec rspec
```

Frontend:

```sh
cd payroll-web
npm test -- --run
```

## Render Deployment

The repo includes a Render blueprint in [render.yaml](render.yaml) that provisions:

- the Rails web service
- a Render Key Value instance for Redis-compatible caching and Sidekiq
- a private Elasticsearch service

Render setup notes:

- Set `DATABASE_URL` on the `payroll` web service to your Render Postgres connection string, or wire it from an existing Postgres database in the dashboard.
- `REDIS_URL` is injected automatically from the `payroll-redis` Key Value service.
- `ELASTICSEARCH_HOSTPORT` is injected automatically from the `payroll-elasticsearch` private service, and the Rails app converts it into `ELASTICSEARCH_URL`.
- `SECRET_KEY_BASE` is generated by the blueprint, but you can replace it with your own fixed secret in the Render dashboard if preferred.
- The Docker image builds the React app from `payroll-web/` and copies it into `public/`, so the same Render web service serves both the UI and the API.
- The expected frontend route is `https://your-service.onrender.com/salary-management`.

After the service is healthy, add the live Render URL to this README.

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

## Artifacts

The repo includes supporting artifacts for assessment review:

- [docs/assessment-notes.md](docs/assessment-notes.md): product framing, architecture, trade-offs, AI usage, deployment path, and demo outline
- [docs/er-diagram.md](docs/er-diagram.md): dedicated entity-relationship diagram for the payroll domain
- [README.md](README.md): setup instructions, Docker workflow, requirement coverage, and schema overview
- incremental git history: implementation evolution across the solution

## Remaining Gaps

These items are the main assessment asks not fully delivered as checked-in artifacts:

- no live deployed URL
- no checked-in video demo

Everything else in the core build brief is represented in the codebase or documentation.

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

# Assessment Notes

## Product Framing

The primary user is an HR manager who needs a fast operational view of employees and salary distribution. I optimized the first screen for the actual daily workflow instead of a landing page: filters, salary insights, employee list, and employee create/update are all available immediately.

The minimum usable product is:

- Maintain employee records with job title, country, and salary.
- Compare salary ranges by country.
- Compare a specific job title against the selected country.
- Seed enough data to make aggregate views meaningful at 10,000 employees.

## Architecture

The Rails backend keeps the domain normalized:

- `employees` stores identity, employment status, department, and job title.
- `employee_addresses` stores country and address data. A unique partial index enforces one primary address per employee.
- `employee_salaries` stores salary history. The UI works with the current salary while preserving room for historical salary changes.
- `salary_adjustments` stores explicit adjustment events and validates that the change amount matches previous and new salary.

The API exposes a small product-facing surface:

- `GET /api/v1/employees`
- `GET /api/v1/employees/:id`
- `POST /api/v1/employees`
- `PATCH /api/v1/employees/:id`
- `DELETE /api/v1/employees/:id`
- `GET /api/v1/lookups`
- `GET /api/v1/salary_insights`

The React app calls those endpoints directly and keeps state local. This is enough for the assessment scope and avoids unnecessary client architecture.

## Performance Considerations

Salary insights are calculated in SQL with aggregate functions rather than in Ruby or the browser:

- `COUNT(DISTINCT employees.id)`
- `MIN(employee_salaries.amount)`
- `MAX(employee_salaries.amount)`
- `AVG(employee_salaries.amount)`

The seed script uses batched `insert_all` calls with deterministic employee codes and emails. It avoids per-record Active Record object creation for the 10,000 employee load path.

Useful next indexes for larger data:

- Composite index on primary address country: `employee_addresses(country, primary_address, employee_id)`
- Composite current salary index: `employee_salaries(employee_id, effective_from, effective_to)`
- Search indexes for employee name/email/code if the dataset grows beyond simple `ILIKE`.

## Testing Strategy

Tests cover the core behavior instead of generated placeholders:

- Model validation and normalization for the payroll domain.
- Request specs for employee CRUD.
- Request specs for lookup data.
- Request specs for salary insight calculations.
- Seed data source coverage.

The test suite is deterministic and runs quickly.

## AI Usage

I used the AI agent for acceleration in these areas:

- Inspecting migration drift and reconciling local database state.
- Creating a normalized API surface around the existing schema.
- Generating focused tests for the main product workflows.
- Building the React UI and iterating with lint/build feedback.
- Capturing design and trade-off notes.

I kept correctness checks explicit by running migrations, request/model specs, RuboCop, Rails autoload checks, frontend lint, and frontend production build.

## Trade-Offs

I kept authentication and authorization out of scope. In production, HR access should be protected with role-based authorization and audit logs for salary changes.

The frontend uses local state and direct API calls. That is pragmatic for this scope. If the UI grows, React Query is already installed and would be a good next step for caching, retries, and optimistic updates.

The employee form writes the current salary row directly. The schema supports salary history and salary adjustments, but a richer product would add an adjustment workflow that records every salary change as a separate business event.

## Deployment and Demo

The repository includes Kamal configuration scaffolding from the Rails app. A deployment-ready path would be:

- Configure production database and environment variables.
- Build the React app with `VITE_API_BASE_URL` set to the production Rails API URL.
- Serve the frontend via static hosting or through a web server alongside the Rails API.
- Run `bin/rails db:migrate db:seed` for a demo environment.

For a video demo, show:

1. Seeded 10,000 employee dataset.
2. Country salary metrics.
3. Job-title average salary within a country.
4. Add employee.
5. Edit salary/country.
6. Delete employee.

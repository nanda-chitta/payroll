import { useCallback, useEffect, useMemo, useState } from 'react'
import type { FormEvent } from 'react'
import './App.css'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:3000'

type Lookup = {
  id: number
  name: string
  code: string
}

type Employee = {
  id: number
  employee_code: string
  first_name: string
  middle_name: string | null
  last_name: string
  full_name: string
  email: string
  hire_date: string
  employment_type: string
  status: string
  department: Lookup | null
  job_title: Lookup | null
  country: string | null
  address: {
    line1: string
    line2: string | null
    city: string
    state: string | null
    postal_code: string
    country: string
  } | null
  salary: {
    amount: string
    currency: string
    pay_frequency: string
  } | null
}

type Lookups = {
  departments: Lookup[]
  job_titles: Lookup[]
  countries: string[]
  employment_types: string[]
  statuses: string[]
  pay_frequencies: string[]
}

type InsightSummary = {
  employee_count: number
  minimum_salary: string | null
  maximum_salary: string | null
  average_salary: string | null
}

type SalaryInsights = {
  country_salary: InsightSummary
  job_title_salary: InsightSummary
  headcount_by_job_title: Array<{ job_title_id: number; name: string; employee_count: number }>
  salary_distribution: Array<{ label: string; employee_count: number }>
}

type EmployeeForm = {
  id?: number
  employee_code: string
  first_name: string
  middle_name: string
  last_name: string
  email: string
  hire_date: string
  employment_type: string
  status: string
  department_id: string
  job_title_id: string
  line1: string
  line2: string
  city: string
  state: string
  postal_code: string
  country: string
  salary_amount: string
  currency: string
  pay_frequency: string
}

const emptyLookups: Lookups = {
  departments: [],
  job_titles: [],
  countries: [],
  employment_types: [],
  statuses: [],
  pay_frequencies: [],
}

const newEmployeeForm = (lookups: Lookups): EmployeeForm => ({
  employee_code: '',
  first_name: '',
  middle_name: '',
  last_name: '',
  email: '',
  hire_date: new Date().toISOString().slice(0, 10),
  employment_type: lookups.employment_types[0] ?? 'full_time',
  status: lookups.statuses[0] ?? 'active',
  department_id: lookups.departments[0]?.id.toString() ?? '',
  job_title_id: lookups.job_titles[0]?.id.toString() ?? '',
  line1: '',
  line2: '',
  city: '',
  state: '',
  postal_code: '',
  country: lookups.countries[0] ?? 'India',
  salary_amount: '',
  currency: 'USD',
  pay_frequency: lookups.pay_frequencies[0] ?? 'yearly',
})

function App() {
  const [lookups, setLookups] = useState<Lookups>(emptyLookups)
  const [employees, setEmployees] = useState<Employee[]>([])
  const [insights, setInsights] = useState<SalaryInsights | null>(null)
  const [query, setQuery] = useState('')
  const [country, setCountry] = useState('')
  const [jobTitleId, setJobTitleId] = useState('')
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [error, setError] = useState('')
  const [form, setForm] = useState<EmployeeForm | null>(null)

  const selectedJobTitle = useMemo(
    () => lookups.job_titles.find((jobTitle) => jobTitle.id.toString() === jobTitleId),
    [jobTitleId, lookups.job_titles],
  )

  const loadEmployees = useCallback(async () => {
    setError('')

    try {
      const params = new URLSearchParams({ limit: '25' })
      if (country) params.set('country', country)
      if (jobTitleId) params.set('job_title_id', jobTitleId)
      if (query.trim()) params.set('query', query.trim())

      const data = await apiGet<{ employees: Employee[] }>(`/api/v1/employees?${params}`)
      setEmployees(data.employees)
    } catch (requestError) {
      setError(errorMessage(requestError))
    }
  }, [country, jobTitleId, query])

  const loadInsights = useCallback(async () => {
    setError('')

    try {
      const params = new URLSearchParams()
      if (country) params.set('country', country)
      if (jobTitleId) params.set('job_title_id', jobTitleId)

      setInsights(await apiGet<SalaryInsights>(`/api/v1/salary_insights?${params}`))
    } catch (requestError) {
      setError(errorMessage(requestError))
    }
  }, [country, jobTitleId])

  const loadInitialData = useCallback(async () => {
    setIsLoading(true)
    setError('')

    try {
      const lookupData = await apiGet<Lookups>('/api/v1/lookups')
      setLookups(lookupData)
      setCountry(lookupData.countries[0] ?? '')
      setJobTitleId(lookupData.job_titles[0]?.id.toString() ?? '')
    } catch (requestError) {
      setError(errorMessage(requestError))
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    loadInitialData()
  }, [loadInitialData])

  useEffect(() => {
    loadEmployees()
    loadInsights()
  }, [loadEmployees, loadInsights])

  async function handleSearch(event: FormEvent) {
    event.preventDefault()
    await loadEmployees()
  }

  async function handleSave(event: FormEvent) {
    event.preventDefault()
    if (!form) return

    setIsSaving(true)
    setError('')

    try {
      const payload = { employee: formPayload(form) }
      const path = form.id ? `/api/v1/employees/${form.id}` : '/api/v1/employees'
      const method = form.id ? 'PATCH' : 'POST'

      await apiRequest(path, {
        method,
        body: JSON.stringify(payload),
      })

      setForm(null)
      await Promise.all([loadEmployees(), loadInsights(), loadInitialData()])
    } catch (requestError) {
      setError(errorMessage(requestError))
    } finally {
      setIsSaving(false)
    }
  }

  async function handleDelete(employee: Employee) {
    if (!window.confirm(`Delete ${employee.full_name}?`)) return

    setError('')

    try {
      await apiRequest(`/api/v1/employees/${employee.id}`, { method: 'DELETE' })
      await Promise.all([loadEmployees(), loadInsights()])
    } catch (requestError) {
      setError(errorMessage(requestError))
    }
  }

  function openCreateForm() {
    setForm(newEmployeeForm(lookups))
  }

  function openEditForm(employee: Employee) {
    setForm({
      id: employee.id,
      employee_code: employee.employee_code,
      first_name: employee.first_name,
      middle_name: employee.middle_name ?? '',
      last_name: employee.last_name,
      email: employee.email,
      hire_date: employee.hire_date,
      employment_type: employee.employment_type,
      status: employee.status,
      department_id: employee.department?.id.toString() ?? '',
      job_title_id: employee.job_title?.id.toString() ?? '',
      line1: employee.address?.line1 ?? '',
      line2: employee.address?.line2 ?? '',
      city: employee.address?.city ?? '',
      state: employee.address?.state ?? '',
      postal_code: employee.address?.postal_code ?? '',
      country: employee.country ?? '',
      salary_amount: employee.salary?.amount ?? '',
      currency: employee.salary?.currency ?? 'USD',
      pay_frequency: employee.salary?.pay_frequency ?? 'yearly',
    })
  }

  return (
    <main className="app-shell">
      <header className="topbar">
        <div>
          <p className="eyebrow">Payroll workspace</p>
          <h1>Salary management</h1>
        </div>
        <button className="primary-action" type="button" onClick={openCreateForm}>
          Add employee
        </button>
      </header>

      {error && <div className="alert">{error}</div>}

      <section className="toolbar" aria-label="Employee filters">
        <form className="search-form" onSubmit={handleSearch}>
          <label>
            Search employees
            <input
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Name, code, or email"
            />
          </label>
          <button type="submit">Search</button>
        </form>

        <label>
          Country
          <select value={country} onChange={(event) => setCountry(event.target.value)}>
            <option value="">All countries</option>
            {lookups.countries.map((lookupCountry) => (
              <option key={lookupCountry} value={lookupCountry}>
                {lookupCountry}
              </option>
            ))}
          </select>
        </label>

        <label>
          Job title
          <select value={jobTitleId} onChange={(event) => setJobTitleId(event.target.value)}>
            <option value="">All job titles</option>
            {lookups.job_titles.map((jobTitle) => (
              <option key={jobTitle.id} value={jobTitle.id}>
                {jobTitle.name}
              </option>
            ))}
          </select>
        </label>
      </section>

      <section className="insights-grid" aria-label="Salary insights">
        <MetricPanel title="Country employees" value={insights?.country_salary.employee_count ?? 0} />
        <MetricPanel title="Minimum salary" value={money(insights?.country_salary.minimum_salary)} />
        <MetricPanel title="Average salary" value={money(insights?.country_salary.average_salary)} />
        <MetricPanel title="Maximum salary" value={money(insights?.country_salary.maximum_salary)} />
      </section>

      <section className="detail-grid">
        <div className="metric-list">
          <h2>{selectedJobTitle ? selectedJobTitle.name : 'Selected role'}</h2>
          <p>Average salary in {country || 'all countries'}</p>
          <strong>{money(insights?.job_title_salary.average_salary)}</strong>
        </div>

        <div className="bars">
          <h2>Salary bands</h2>
          {(insights?.salary_distribution ?? []).map((bucket) => (
            <div className="bar-row" key={bucket.label}>
              <span>{bucket.label}</span>
              <div>
                <i style={{ width: `${barWidth(bucket.employee_count, insights?.country_salary.employee_count)}%` }} />
              </div>
              <b>{bucket.employee_count}</b>
            </div>
          ))}
        </div>

        <div className="bars">
          <h2>Top roles</h2>
          {(insights?.headcount_by_job_title ?? []).map((jobTitle) => (
            <div className="bar-row" key={jobTitle.job_title_id}>
              <span>{jobTitle.name}</span>
              <div>
                <i style={{ width: `${barWidth(jobTitle.employee_count, insights?.country_salary.employee_count)}%` }} />
              </div>
              <b>{jobTitle.employee_count}</b>
            </div>
          ))}
        </div>
      </section>

      <section className="employee-section">
        <div className="section-heading">
          <div>
            <h2>Employees</h2>
            <p>{isLoading ? 'Loading payroll data' : `${employees.length} records shown`}</p>
          </div>
        </div>

        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Employee</th>
                <th>Job title</th>
                <th>Country</th>
                <th>Salary</th>
                <th>Status</th>
                <th aria-label="Actions"></th>
              </tr>
            </thead>
            <tbody>
              {employees.map((employee) => (
                <tr key={employee.id}>
                  <td>
                    <strong>{employee.full_name}</strong>
                    <span>{employee.employee_code} | {employee.email}</span>
                  </td>
                  <td>{employee.job_title?.name}</td>
                  <td>{employee.country}</td>
                  <td>{money(employee.salary?.amount)} {employee.salary?.currency}</td>
                  <td><span className="status-pill">{employee.status.replace('_', ' ')}</span></td>
                  <td>
                    <div className="row-actions">
                      <button type="button" onClick={() => openEditForm(employee)}>Edit</button>
                      <button className="danger" type="button" onClick={() => handleDelete(employee)}>Delete</button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      {form && (
        <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="employee-form-title">
          <form className="employee-form" onSubmit={handleSave}>
            <div className="form-heading">
              <div>
                <p className="eyebrow">{form.id ? 'Update employee' : 'New employee'}</p>
                <h2 id="employee-form-title">Employee profile</h2>
              </div>
              <button type="button" onClick={() => setForm(null)}>Close</button>
            </div>

            <div className="form-grid">
              <Field label="Employee code" value={form.employee_code} onChange={(value) => updateForm('employee_code', value)} />
              <Field label="First name" value={form.first_name} onChange={(value) => updateForm('first_name', value)} />
              <Field label="Middle name" value={form.middle_name} onChange={(value) => updateForm('middle_name', value)} />
              <Field label="Last name" value={form.last_name} onChange={(value) => updateForm('last_name', value)} />
              <Field label="Email" type="email" value={form.email} onChange={(value) => updateForm('email', value)} />
              <Field label="Hire date" type="date" value={form.hire_date} onChange={(value) => updateForm('hire_date', value)} />
              <SelectField label="Department" value={form.department_id} onChange={(value) => updateForm('department_id', value)} options={lookups.departments} />
              <SelectField label="Job title" value={form.job_title_id} onChange={(value) => updateForm('job_title_id', value)} options={lookups.job_titles} />
              <SelectText label="Employment type" value={form.employment_type} onChange={(value) => updateForm('employment_type', value)} options={lookups.employment_types} />
              <SelectText label="Status" value={form.status} onChange={(value) => updateForm('status', value)} options={lookups.statuses} />
              <Field label="Country" value={form.country} onChange={(value) => updateForm('country', value)} />
              <Field label="City" value={form.city} onChange={(value) => updateForm('city', value)} />
              <Field label="Address line 1" value={form.line1} onChange={(value) => updateForm('line1', value)} />
              <Field label="Address line 2" value={form.line2} onChange={(value) => updateForm('line2', value)} />
              <Field label="State" value={form.state} onChange={(value) => updateForm('state', value)} />
              <Field label="Postal code" value={form.postal_code} onChange={(value) => updateForm('postal_code', value)} />
              <Field label="Salary" type="number" value={form.salary_amount} onChange={(value) => updateForm('salary_amount', value)} />
              <Field label="Currency" value={form.currency} onChange={(value) => updateForm('currency', value)} />
              <SelectText label="Pay frequency" value={form.pay_frequency} onChange={(value) => updateForm('pay_frequency', value)} options={lookups.pay_frequencies} />
            </div>

            <div className="form-actions">
              <button type="button" onClick={() => setForm(null)}>Cancel</button>
              <button className="primary-action" type="submit" disabled={isSaving}>
                {isSaving ? 'Saving' : 'Save employee'}
              </button>
            </div>
          </form>
        </div>
      )}
    </main>
  )

  function updateForm(key: keyof EmployeeForm, value: string) {
    setForm((currentForm) => currentForm ? { ...currentForm, [key]: value } : currentForm)
  }
}

function MetricPanel({ title, value }: { title: string; value: string | number }) {
  return (
    <div className="metric-panel">
      <span>{title}</span>
      <strong>{value}</strong>
    </div>
  )
}

function Field({
  label,
  value,
  onChange,
  type = 'text',
}: {
  label: string
  value: string
  onChange: (value: string) => void
  type?: string
}) {
  return (
    <label>
      {label}
      <input type={type} value={value} onChange={(event) => onChange(event.target.value)} required={requiredLabel(label)} />
    </label>
  )
}

function SelectField({
  label,
  value,
  onChange,
  options,
}: {
  label: string
  value: string
  onChange: (value: string) => void
  options: Lookup[]
}) {
  return (
    <label>
      {label}
      <select value={value} onChange={(event) => onChange(event.target.value)} required>
        {options.map((option) => (
          <option key={option.id} value={option.id}>
            {option.name}
          </option>
        ))}
      </select>
    </label>
  )
}

function SelectText({
  label,
  value,
  onChange,
  options,
}: {
  label: string
  value: string
  onChange: (value: string) => void
  options: string[]
}) {
  return (
    <label>
      {label}
      <select value={value} onChange={(event) => onChange(event.target.value)} required>
        {options.map((option) => (
          <option key={option} value={option}>
            {option.replace('_', ' ')}
          </option>
        ))}
      </select>
    </label>
  )
}

async function apiGet<T>(path: string): Promise<T> {
  const response = await apiRequest(path)
  return response.json()
}

async function apiRequest(path: string, options: RequestInit = {}) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
      ...options.headers,
    },
    ...options,
  })

  if (!response.ok) {
    const body = await response.json().catch(() => null)
    throw new Error(body?.error ?? formatErrors(body?.errors) ?? 'Request failed')
  }

  return response
}

function formPayload(form: EmployeeForm) {
  return {
    ...form,
    department_id: Number(form.department_id),
    job_title_id: Number(form.job_title_id),
    salary_amount: Number(form.salary_amount),
  }
}

function formatErrors(errors: Record<string, string[]> | undefined) {
  if (!errors) return null

  return Object.entries(errors)
    .map(([field, messages]) => `${field} ${messages.join(', ')}`)
    .join('; ')
}

function errorMessage(error: unknown) {
  return error instanceof Error ? error.message : 'Something went wrong'
}

function money(value: string | null | undefined) {
  if (!value) return '$0'

  return Number(value).toLocaleString('en-US', {
    style: 'currency',
    currency: 'USD',
    maximumFractionDigits: 0,
  })
}

function barWidth(value: number, total: number | undefined) {
  if (!total) return 0

  return Math.max(6, Math.round((value / total) * 100))
}

function requiredLabel(label: string) {
  return !['Middle name', 'Address line 2', 'State'].includes(label)
}

export default App

export type Lookup = {
  id: number
  name: string
  code: string
}

export type Employee = {
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

export type Lookups = {
  departments: Lookup[]
  job_titles: Lookup[]
  countries: string[]
  employment_types: string[]
  statuses: string[]
  pay_frequencies: string[]
}

export type InsightSummary = {
  employee_count: number
  minimum_salary: string | null
  maximum_salary: string | null
  average_salary: string | null
}

export type SalaryInsights = {
  country_salary: InsightSummary
  job_title_salary: InsightSummary
  headcount_by_job_title: Array<{ job_title_id: number; name: string; employee_count: number }>
  salary_distribution: Array<{ label: string; employee_count: number }>
}

export type EmployeeFilters = {
  country: string
  jobTitleId: string
  query: string
}

export type EmployeeFormValues = {
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

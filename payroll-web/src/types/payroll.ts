export type Lookup = {
  id: number
  name: string
  code: string
}

export type Employee = {
  id: number
  employeeCode: string
  firstName: string
  middleName: string | null
  lastName: string
  fullName: string
  email: string
  hireDate: string
  employmentType: string
  status: string
  department: Lookup | null
  jobTitle: Lookup | null
  country: string | null
  address: {
    line1: string
    line2: string | null
    city: string
    state: string | null
    postalCode: string
    country: string
  } | null
  salary: {
    amount: string
    currency: string
    payFrequency: string
  } | null
}

export type Lookups = {
  departments: Lookup[]
  jobTitles: Lookup[]
  countries: string[]
  employmentTypes: string[]
  statuses: string[]
  payFrequencies: string[]
}

export type InsightSummary = {
  employeeCount: number
  minimumSalary: string | null
  maximumSalary: string | null
  averageSalary: string | null
}

export type SalaryInsights = {
  countrySalary: InsightSummary
  jobTitleSalary: InsightSummary
  headcountByJobTitle: Array<{ jobTitleId: number; name: string; employeeCount: number }>
  salaryDistribution: Array<{ label: string; employeeCount: number }>
}

export type EmployeeFilters = {
  activeOnly: boolean
  country: string
  jobTitleId: string
  query: string
}

export type PaginationMeta = {
  page: number
  perPage: number
  total: number
}

export type EmployeeFormValues = {
  id?: number
  employeeCode: string
  firstName: string
  middleName: string
  lastName: string
  email: string
  hireDate: string
  employmentType: string
  status: string
  departmentId: string
  jobTitleId: string
  line1: string
  line2: string
  city: string
  state: string
  postalCode: string
  country: string
  salaryAmount: string
  currency: string
  payFrequency: string
}

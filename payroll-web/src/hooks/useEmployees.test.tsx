import { act, renderHook, waitFor } from '@testing-library/react'
import { describe, expect, it, beforeEach, vi } from 'vitest'
import { useEmployees } from './useEmployees'
import { apiDelete, apiGet, apiPatch, apiPost } from '../api'
import type { Employee, EmployeeFilters, EmployeeFormValues } from '../types/payroll'

vi.mock('../api', () => ({
  apiDelete: vi.fn(),
  apiGet: vi.fn(),
  apiPatch: vi.fn(),
  apiPost: vi.fn(),
}))

const employee: Employee = {
  id: 7,
  employeeCode: 'EMP00007',
  firstName: 'Priya',
  middleName: null,
  lastName: 'Sharma',
  fullName: 'Priya Sharma',
  email: 'priya@example.com',
  hireDate: '2024-01-01',
  employmentType: 'full_time',
  status: 'active',
  department: { id: 2, name: 'People Operations', code: 'PEOPLE' },
  jobTitle: { id: 3, name: 'HR Manager', code: 'HRM' },
  country: 'India',
  address: {
    line1: '100 Market Street',
    line2: null,
    city: 'Bengaluru',
    state: null,
    postalCode: '560001',
    country: 'India',
  },
  salary: {
    amount: '90000',
    currency: 'USD',
    payFrequency: 'yearly',
  },
}

const filters: EmployeeFilters = {
  activeOnly: true,
  country: 'India',
  jobTitleId: '3',
  query: ' Priya ',
}

const formValues: EmployeeFormValues = {
  id: 7,
  employeeCode: 'EMP00007',
  firstName: 'Priya',
  middleName: '',
  lastName: 'Sharma',
  email: 'priya@example.com',
  hireDate: '2024-01-01',
  employmentType: 'full_time',
  status: 'active',
  departmentId: '2',
  jobTitleId: '3',
  line1: '100 Market Street',
  line2: '',
  city: 'Bengaluru',
  state: '',
  postalCode: '560001',
  country: 'India',
  salaryAmount: '90000',
  currency: 'USD',
  payFrequency: 'yearly',
}

describe('useEmployees', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('loads employees with the expected query parameters', async () => {
    vi.mocked(apiGet).mockResolvedValue({
      employees: [employee],
      meta: { page: 2, perPage: 50, total: 1 },
    })

    const { result } = renderHook(() => useEmployees(filters, { page: 1, pageSize: 50 }))

    await waitFor(() => expect(result.current.isLoading).toBe(false))

    expect(apiGet).toHaveBeenCalledWith('/employees?limit=50&page=2&country=India&jobTitleId=3&query=Priya&status=active')
    expect(result.current.employees).toEqual([employee])
    expect(result.current.meta.total).toBe(1)
    expect(result.current.error).toBe('')
  })

  it('casts form fields before updating an employee and deletes by id', async () => {
    vi.mocked(apiGet).mockResolvedValue({
      employees: [employee],
      meta: { page: 1, perPage: 25, total: 1 },
    })
    vi.mocked(apiPatch).mockResolvedValue({})
    vi.mocked(apiDelete).mockResolvedValue({})

    const { result } = renderHook(() => useEmployees(filters, { page: 0, pageSize: 25 }))

    await waitFor(() => expect(result.current.isLoading).toBe(false))

    await act(async () => {
      await result.current.saveEmployee(formValues)
    })

    await act(async () => {
      await result.current.deleteEmployee(employee)
    })

    expect(apiPatch).toHaveBeenCalledWith('/employees/7', {
      employee: {
        ...formValues,
        departmentId: 2,
        jobTitleId: 3,
        salaryAmount: 90000,
      },
    })
    expect(apiDelete).toHaveBeenCalledWith('/employees/7')
    expect(apiPost).not.toHaveBeenCalled()
  })
})

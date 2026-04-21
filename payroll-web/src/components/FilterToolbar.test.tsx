import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'
import { FilterToolbar } from './FilterToolbar'
import type { EmployeeFilters, Lookups } from '../types/payroll'

const lookups: Lookups = {
  departments: [],
  jobTitles: [
    { id: 1, name: 'HR Manager', code: 'HRM' },
    { id: 2, name: 'Software Engineer', code: 'SWE' },
  ],
  countries: ['India', 'United States'],
  employmentTypes: [],
  statuses: [],
  payFrequencies: [],
}

const filters: EmployeeFilters = {
  activeOnly: false,
  country: '',
  jobTitleId: '',
  query: '',
}

describe('FilterToolbar', () => {
  it('updates the query draft, toggles active-only, and submits search', () => {
    const onQueryDraftChange = vi.fn()
    const onFiltersChange = vi.fn()
    const onSearch = vi.fn()

    render(
      <FilterToolbar
        filters={filters}
        lookups={lookups}
        onFiltersChange={onFiltersChange}
        onQueryDraftChange={onQueryDraftChange}
        onSearch={onSearch}
        queryDraft=""
      />,
    )

    fireEvent.change(screen.getByLabelText(/search employees/i), { target: { value: '  Priya  ' } })
    fireEvent.click(screen.getByLabelText(/active employees/i))
    fireEvent.click(screen.getByRole('button', { name: /search/i }))

    expect(onQueryDraftChange).toHaveBeenCalledWith('  Priya  ')
    expect(onFiltersChange).toHaveBeenCalledWith({ ...filters, activeOnly: true })
    expect(onSearch).toHaveBeenCalledTimes(1)
  })
})

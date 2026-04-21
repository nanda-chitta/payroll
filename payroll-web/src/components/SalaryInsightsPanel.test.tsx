import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { SalaryInsightsPanel } from './SalaryInsightsPanel'
import type { SalaryInsights } from '../types/payroll'

const insights: SalaryInsights = {
  countrySalary: {
    employeeCount: 20,
    minimumSalary: '60000',
    averageSalary: '82000',
    maximumSalary: '120000',
  },
  jobTitleSalary: {
    employeeCount: 8,
    minimumSalary: '70000',
    averageSalary: '90000',
    maximumSalary: '110000',
  },
  headcountByJobTitle: [
    { jobTitleId: 1, name: 'HR Manager', employeeCount: 8 },
    { jobTitleId: 2, name: 'Software Engineer', employeeCount: 12 },
  ],
  salaryDistribution: [
    { label: '$60k-$80k', employeeCount: 9 },
    { label: '$80k-$100k', employeeCount: 11 },
  ],
}

describe('SalaryInsightsPanel', () => {
  it('renders the selected role average and insight buckets', () => {
    render(
      <SalaryInsightsPanel
        country="India"
        insights={insights}
        selectedJobTitle={{ id: 1, name: 'HR Manager', code: 'HRM' }}
      />,
    )

    expect(screen.getByRole('heading', { name: 'HR Manager' })).toBeInTheDocument()
    expect(screen.getByText('Average salary in India')).toBeInTheDocument()
    expect(screen.getByText('$90,000')).toBeInTheDocument()
    expect(screen.getByText('Salary bands')).toBeInTheDocument()
    expect(screen.getByText('$60k-$80k')).toBeInTheDocument()
    expect(screen.getByText('Top roles')).toBeInTheDocument()
    expect(screen.getByText('Software Engineer')).toBeInTheDocument()
  })
})

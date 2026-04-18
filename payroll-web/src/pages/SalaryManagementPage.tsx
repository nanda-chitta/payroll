import { Alert, Box, Button, Container, Typography } from '@mui/material'
import { useMemo, useState } from 'react'
import { EmployeeFormDialog } from '../components/EmployeeFormDialog'
import { EmployeeTable } from '../components/EmployeeTable'
import { FilterToolbar } from '../components/FilterToolbar'
import { MetricCard } from '../components/MetricCard'
import { SalaryInsightsPanel } from '../components/SalaryInsightsPanel'
import { useEmployees } from '../hooks/useEmployees'
import { useLookups } from '../hooks/useLookups'
import { useSalaryInsights } from '../hooks/useSalaryInsights'
import { money } from '../utils/formatters'
import type { Employee, EmployeeFilters, EmployeeFormValues } from '../types/payroll'

export function SalaryManagementPage() {
  const { lookups, error: lookupsError, reload: reloadLookups } = useLookups()
  const [filters, setFilters] = useState<EmployeeFilters>({ country: '', jobTitleId: '', query: '' })
  const [queryDraft, setQueryDraft] = useState('')
  const [editingEmployee, setEditingEmployee] = useState<Employee | null>(null)
  const [isFormOpen, setIsFormOpen] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  const [pageError, setPageError] = useState('')

  const {
    employees,
    error: employeesError,
    isLoading: employeesLoading,
    reload: reloadEmployees,
    saveEmployee,
    deleteEmployee,
  } = useEmployees(filters)

  const {
    insights,
    error: insightsError,
    isLoading: insightsLoading,
    reload: reloadInsights,
  } = useSalaryInsights(filters)

  const selectedJobTitle = useMemo(
    () => lookups.job_titles.find((jobTitle) => jobTitle.id.toString() === filters.jobTitleId),
    [filters.jobTitleId, lookups.job_titles],
  )

  const visibleError = pageError || lookupsError || employeesError || insightsError

  function handleCreate() {
    setEditingEmployee(null)
    setIsFormOpen(true)
  }

  function handleEdit(employee: Employee) {
    setEditingEmployee(employee)
    setIsFormOpen(true)
  }

  async function handleSave(values: EmployeeFormValues) {
    setIsSaving(true)
    setPageError('')

    try {
      await saveEmployee(values)
      setIsFormOpen(false)
      setEditingEmployee(null)
      await Promise.all([reloadEmployees(), reloadInsights(), reloadLookups()])
    } catch (error) {
      setPageError(error instanceof Error ? error.message : 'Unable to save employee')
    } finally {
      setIsSaving(false)
    }
  }

  async function handleDelete(employee: Employee) {
    if (!window.confirm(`Delete ${employee.full_name}?`)) return

    setPageError('')

    try {
      await deleteEmployee(employee)
      await Promise.all([reloadEmployees(), reloadInsights(), reloadLookups()])
    } catch (error) {
      setPageError(error instanceof Error ? error.message : 'Unable to delete employee')
    }
  }

  return (
    <Box component="main" sx={{ bgcolor: 'background.default', minHeight: '100vh', py: 3 }}>
      <Container maxWidth="xl">
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
          <Box
            sx={{
              alignItems: { md: 'center', xs: 'stretch' },
              display: 'flex',
              flexDirection: { md: 'row', xs: 'column' },
              justifyContent: 'space-between',
            }}
          >
            <Box>
              <Typography color="primary" sx={{ fontWeight: 800 }} variant="body2">
                Payroll workspace
              </Typography>
              <Typography component="h1" variant="h1">
                Salary management
              </Typography>
            </Box>
            <Button onClick={handleCreate} variant="contained">
              Add employee
            </Button>
          </Box>

          {visibleError && <Alert severity="error">{visibleError}</Alert>}

          <FilterToolbar
            filters={filters}
            lookups={lookups}
            onFiltersChange={setFilters}
            onQueryDraftChange={setQueryDraft}
            onSearch={() => setFilters((currentFilters) => ({ ...currentFilters, query: queryDraft }))}
            queryDraft={queryDraft}
          />

          <Box
            sx={{
              display: 'grid',
              gap: 2,
              gridTemplateColumns: { lg: 'repeat(4, minmax(0, 1fr))', sm: 'repeat(2, minmax(0, 1fr))', xs: '1fr' },
            }}
          >
            <MetricCard isLoading={insightsLoading} title="Country employees" value={insights?.country_salary.employee_count ?? 0} />
            <MetricCard isLoading={insightsLoading} title="Minimum salary" value={money(insights?.country_salary.minimum_salary)} />
            <MetricCard isLoading={insightsLoading} title="Average salary" value={money(insights?.country_salary.average_salary)} />
            <MetricCard isLoading={insightsLoading} title="Maximum salary" value={money(insights?.country_salary.maximum_salary)} />
          </Box>

          <SalaryInsightsPanel country={filters.country} insights={insights} selectedJobTitle={selectedJobTitle} />

          <EmployeeTable employees={employees} isLoading={employeesLoading} onDelete={handleDelete} onEdit={handleEdit} />
        </Box>
      </Container>

      <EmployeeFormDialog
        employee={editingEmployee}
        isSaving={isSaving}
        lookups={lookups}
        onClose={() => setIsFormOpen(false)}
        onSubmit={handleSave}
        open={isFormOpen}
      />
    </Box>
  )
}

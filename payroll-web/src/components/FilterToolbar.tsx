import { Box, MenuItem, Paper } from '@mui/material'
import type { FormEvent } from 'react'
import { Button, CheckBox, TextBox } from './ui'
import type { EmployeeFilters, Lookups } from '../types/payroll'

type FilterToolbarProps = {
  filters: EmployeeFilters
  lookups: Lookups
  queryDraft: string
  onQueryDraftChange: (value: string) => void
  onFiltersChange: (filters: EmployeeFilters) => void
  onSearch: () => void
}

export function FilterToolbar({
  filters,
  lookups,
  queryDraft,
  onQueryDraftChange,
  onFiltersChange,
  onSearch,
}: FilterToolbarProps) {
  function handleSearch(event: FormEvent) {
    event.preventDefault()
    onSearch()
  }

  return (
    <Paper component="section" sx={{ border: '1px solid', borderColor: 'divider', p: 2 }} variant="outlined">
      <Box
        component="form"
        onSubmit={handleSearch}
        sx={{
          alignItems: { md: 'flex-end', xs: 'stretch' },
          display: 'flex',
          flexDirection: { md: 'row', xs: 'column' },
          gap: 2,
        }}
      >
        <TextBox
          fullWidth
          label="Search employees"
          onChange={(event) => onQueryDraftChange(event.target.value)}
          placeholder="Name, code, or email"
          value={queryDraft}
        />
        <TextBox
          label="Country"
          onChange={(event) => onFiltersChange({ ...filters, country: event.target.value })}
          select
          sx={{ minWidth: 220 }}
          value={filters.country}
        >
          <MenuItem value="">All countries</MenuItem>
          {lookups.countries.map((country) => (
            <MenuItem key={country} value={country}>
              {country}
            </MenuItem>
          ))}
        </TextBox>
        <TextBox
          label="Job title"
          onChange={(event) => onFiltersChange({ ...filters, jobTitleId: event.target.value })}
          select
          sx={{ minWidth: 260 }}
          value={filters.jobTitleId}
        >
          <MenuItem value="">All job titles</MenuItem>
          {lookups.jobTitles.map((jobTitle) => (
            <MenuItem key={jobTitle.id} value={jobTitle.id}>
              {jobTitle.name}
            </MenuItem>
          ))}
        </TextBox>
        <CheckBox
          checked={filters.activeOnly}
          label="Active employees"
          onChange={(activeOnly) => onFiltersChange({ ...filters, activeOnly })}
        />
        <Box>
          <Button type="submit" variant="contained">
            Search
          </Button>
        </Box>
      </Box>
    </Paper>
  )
}

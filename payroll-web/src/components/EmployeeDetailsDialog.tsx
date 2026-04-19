import { Box, Dialog, DialogActions, DialogContent, DialogTitle, Typography } from '@mui/material'
import { Button } from './ui'
import { money } from '../utils/formatters'
import type { Employee } from '../types/payroll'

type EmployeeDetailsDialogProps = {
  employee: Employee | null
  open: boolean
  onClose: () => void
  onEdit: (employee: Employee) => void
}

export function EmployeeDetailsDialog({ employee, open, onClose, onEdit }: EmployeeDetailsDialogProps) {
  if (!employee) return null

  return (
    <Dialog fullWidth maxWidth="md" onClose={onClose} open={open}>
      <DialogTitle>
        <Typography color="text.secondary" sx={{ fontWeight: 700 }} variant="body2">
          Employee details
        </Typography>
        {employee.fullName}
      </DialogTitle>
      <DialogContent dividers>
        <Box
          sx={{
            display: 'grid',
            gap: 2,
            gridTemplateColumns: { md: 'repeat(3, minmax(0, 1fr))', xs: '1fr' },
          }}
        >
          <Detail label="Employee code" value={employee.employeeCode} />
          <Detail label="Email" value={employee.email} />
          <Detail label="Status" value={formatValue(employee.status)} />
          <Detail label="Department" value={employee.department?.name} />
          <Detail label="Job title" value={employee.jobTitle?.name} />
          <Detail label="Employment type" value={formatValue(employee.employmentType)} />
          <Detail label="Country" value={employee.country} />
          <Detail label="City" value={employee.address?.city} />
          <Detail label="Hire date" value={employee.hireDate} />
          <Detail label="Salary" value={`${money(employee.salary?.amount)} ${employee.salary?.currency ?? ''}`.trim()} />
          <Detail label="Pay frequency" value={formatValue(employee.salary?.payFrequency)} />
          <Detail label="Postal code" value={employee.address?.postalCode} />
          <Box sx={{ gridColumn: { md: '1 / -1' } }}>
            <Detail label="Address" value={addressLine(employee)} />
          </Box>
        </Box>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Close</Button>
        <Button
          onClick={() => {
            onClose()
            onEdit(employee)
          }}
          variant="contained"
        >
          Edit employee
        </Button>
      </DialogActions>
    </Dialog>
  )
}

function Detail({ label, value }: { label: string; value: string | null | undefined }) {
  return (
    <Box>
      <Typography color="text.secondary" variant="body2">
        {label}
      </Typography>
      <Typography sx={{ fontWeight: 700, overflowWrap: 'anywhere' }}>
        {value || 'Not provided'}
      </Typography>
    </Box>
  )
}

function addressLine(employee: Employee) {
  const address = employee.address
  if (!address) return null

  return [address.line1, address.line2, address.city, address.state, address.country].filter(Boolean).join(', ')
}

function formatValue(value: string | null | undefined) {
  return value?.replace('_', ' ')
}

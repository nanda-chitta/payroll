import {
  Box,
  Button,
  Chip,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
} from '@mui/material'
import { money } from '../utils/formatters'
import type { Employee } from '../types/payroll'

type EmployeeTableProps = {
  employees: Employee[]
  isLoading: boolean
  onEdit: (employee: Employee) => void
  onDelete: (employee: Employee) => void
}

export function EmployeeTable({ employees, isLoading, onEdit, onDelete }: EmployeeTableProps) {
  return (
    <Paper sx={{ border: '1px solid', borderColor: 'divider', overflow: 'hidden' }} variant="outlined">
      <Box sx={{ alignItems: 'center', borderBottom: '1px solid', borderColor: 'divider', display: 'flex', justifyContent: 'space-between', p: 2 }}>
        <Box>
          <Typography variant="h2">Employees</Typography>
          <Typography color="text.secondary">
            {isLoading ? 'Loading payroll data' : `${employees.length} records shown`}
          </Typography>
        </Box>
      </Box>
      <TableContainer>
        <Table sx={{ minWidth: 960 }}>
          <TableHead>
            <TableRow>
              <TableCell>Employee</TableCell>
              <TableCell>Job title</TableCell>
              <TableCell>Country</TableCell>
              <TableCell>Salary</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {employees.map((employee) => (
              <TableRow hover key={employee.id}>
                <TableCell>
                  <Typography sx={{ fontWeight: 700 }}>{employee.full_name}</Typography>
                  <Typography color="text.secondary" variant="body2">
                    {employee.employee_code} | {employee.email}
                  </Typography>
                </TableCell>
                <TableCell>{employee.job_title?.name}</TableCell>
                <TableCell>{employee.country}</TableCell>
                <TableCell>
                  {money(employee.salary?.amount)} {employee.salary?.currency}
                </TableCell>
                <TableCell>
                  <Chip color="primary" label={employee.status.replace('_', ' ')} size="small" variant="outlined" />
                </TableCell>
                <TableCell align="right">
                  <Box sx={{ display: 'flex', gap: 1, justifyContent: 'flex-end' }}>
                    <Button onClick={() => onEdit(employee)} size="small">
                      Edit
                    </Button>
                    <Button
                      color="error"
                      onClick={() => onDelete(employee)}
                      size="small"
                    >
                      Delete
                    </Button>
                  </Box>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Paper>
  )
}

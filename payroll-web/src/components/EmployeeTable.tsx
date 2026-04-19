import { Box, Chip, Paper, Typography } from '@mui/material'
import type { GridColDef, GridPaginationModel } from '@mui/x-data-grid'
import { useMemo } from 'react'
import { ActionIconButton, DataGrid, DeleteIcon, EditIcon, ViewIcon } from './ui'
import { money } from '../utils/formatters'
import type { Employee } from '../types/payroll'

type EmployeeTableProps = {
  employees: Employee[]
  isLoading: boolean
  paginationModel: GridPaginationModel
  rowCount: number
  onView: (employee: Employee) => void
  onEdit: (employee: Employee) => void
  onDelete: (employee: Employee) => void
  onPaginationModelChange: (model: GridPaginationModel) => void
}

export function EmployeeTable({
  employees,
  isLoading,
  paginationModel,
  rowCount,
  onView,
  onEdit,
  onDelete,
  onPaginationModelChange,
}: EmployeeTableProps) {
  const columns = useMemo<GridColDef<Employee>[]>(
    () => [
      {
        field: 'employee',
        flex: 1.4,
        headerName: 'Employee',
        minWidth: 280,
        renderCell: ({ row }) => (
          <Box>
            <Typography sx={{ fontWeight: 700 }}>{row.fullName}</Typography>
            <Typography color="text.secondary" variant="body2">
              {row.employeeCode} | {row.email}
            </Typography>
          </Box>
        ),
        sortable: false,
      },
      {
        field: 'jobTitle',
        flex: 1,
        headerName: 'Job title',
        minWidth: 190,
        sortable: false,
        valueGetter: (_value, row) => row.jobTitle?.name ?? '',
      },
      {
        field: 'country',
        flex: 0.8,
        headerName: 'Country',
        minWidth: 150,
        sortable: false,
      },
      {
        field: 'salary',
        flex: 0.8,
        headerName: 'Salary',
        minWidth: 150,
        renderCell: ({ row }) => `${money(row.salary?.amount)} ${row.salary?.currency ?? ''}`,
        sortable: false,
        valueGetter: (_value, row) => Number(row.salary?.amount ?? 0),
      },
      {
        field: 'status',
        flex: 0.7,
        headerName: 'Status',
        minWidth: 140,
        renderCell: ({ row }) => (
          <Chip color="primary" label={row.status.replace('_', ' ')} size="small" variant="outlined" />
        ),
        sortable: false,
      },
      {
        align: 'right',
        field: 'actions',
        headerAlign: 'right',
        headerName: 'Actions',
        minWidth: 150,
        renderCell: ({ row }) => (
          <Box sx={{ display: 'flex', gap: 0.5, justifyContent: 'flex-end', width: '100%' }}>
            <ActionIconButton
              ariaLabel={`View ${row.fullName}`}
              color="primary"
              icon={<ViewIcon fontSize="small" />}
              label="View"
              onClick={() => onView(row)}
            />
            <ActionIconButton
              ariaLabel={`Edit ${row.fullName}`}
              color="primary"
              icon={<EditIcon fontSize="small" />}
              label="Edit"
              onClick={() => onEdit(row)}
            />
            <ActionIconButton
              ariaLabel={`Delete ${row.fullName}`}
              color="error"
              icon={<DeleteIcon fontSize="small" />}
              label="Delete"
              onClick={() => onDelete(row)}
            />
          </Box>
        ),
        sortable: false,
      },
    ],
    [onDelete, onEdit, onView],
  )

  return (
    <Paper sx={{ border: '1px solid', borderColor: 'divider', overflow: 'hidden' }} variant="outlined">
      <Box
        sx={{
          alignItems: 'center',
          borderBottom: '1px solid',
          borderColor: 'divider',
          display: 'flex',
          justifyContent: 'space-between',
          p: 2,
        }}
      >
        <Box>
          <Typography variant="h2">Employees</Typography>
          <Typography color="text.secondary">
            {isLoading ? 'Loading payroll data' : `${rowCount.toLocaleString()} records available`}
          </Typography>
        </Box>
      </Box>
      <Box sx={{ height: 650, width: '100%' }}>
        <DataGrid
          columns={columns}
          disableColumnMenu
          disableRowSelectionOnClick
          getRowHeight={() => 72}
          loading={isLoading}
          onPaginationModelChange={onPaginationModelChange}
          pageSizeOptions={[10, 25, 50, 100]}
          paginationMode="server"
          paginationModel={paginationModel}
          rowCount={rowCount}
          rows={employees}
          sx={{
            border: 0,
            '& .MuiDataGrid-cell': {
              alignItems: 'center',
              display: 'flex',
            },
            '& .MuiDataGrid-columnHeaders': {
              bgcolor: 'background.default',
            },
          }}
        />
      </Box>
    </Paper>
  )
}

import { zodResolver } from '@hookform/resolvers/zod'
import {
  Box,
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  MenuItem,
  TextField,
  Typography,
} from '@mui/material'
import { Controller, useForm } from 'react-hook-form'
import { useEffect } from 'react'
import { employeeSchema } from '../schemas/employeeSchema'
import type { Employee, EmployeeFormValues, Lookups } from '../types/payroll'
import type { Control, Resolver } from 'react-hook-form'

type EmployeeFormDialogProps = {
  employee: Employee | null
  lookups: Lookups
  open: boolean
  isSaving: boolean
  onClose: () => void
  onSubmit: (values: EmployeeFormValues) => Promise<void>
}

export function EmployeeFormDialog({
  employee,
  lookups,
  open,
  isSaving,
  onClose,
  onSubmit,
}: EmployeeFormDialogProps) {
  const { control, handleSubmit, reset } = useForm<EmployeeFormValues>({
    defaultValues: defaultValues(employee, lookups),
    resolver: zodResolver(employeeSchema) as Resolver<EmployeeFormValues>,
  })

  useEffect(() => {
    reset(defaultValues(employee, lookups))
  }, [employee, lookups, reset, open])

  return (
    <Dialog fullWidth maxWidth="md" onClose={onClose} open={open}>
      <DialogTitle>
        <Typography color="text.secondary" sx={{ fontWeight: 700 }} variant="body2">
          {employee ? 'Update employee' : 'New employee'}
        </Typography>
        Employee profile
      </DialogTitle>
      <DialogContent dividers>
        <Box
          component="form"
          id="employee-form"
          onSubmit={handleSubmit(onSubmit)}
          sx={{
            display: 'grid',
            gap: 2,
            gridTemplateColumns: { md: 'repeat(3, minmax(0, 1fr))', xs: '1fr' },
          }}
        >
          <FormText control={control} label="Employee code" name="employee_code" />
          <FormText control={control} label="First name" name="first_name" />
          <FormText control={control} label="Middle name" name="middle_name" />
          <FormText control={control} label="Last name" name="last_name" />
          <FormText control={control} label="Email" name="email" type="email" />
          <FormText control={control} label="Hire date" name="hire_date" type="date" />
          <FormSelect control={control} label="Department" name="department_id" options={lookups.departments} />
          <FormSelect control={control} label="Job title" name="job_title_id" options={lookups.job_titles} />
          <FormTextSelect control={control} label="Employment type" name="employment_type" options={lookups.employment_types} />
          <FormTextSelect control={control} label="Status" name="status" options={lookups.statuses} />
          <FormText control={control} label="Country" name="country" />
          <FormText control={control} label="City" name="city" />
          <FormText control={control} label="Address line 1" name="line1" />
          <FormText control={control} label="Address line 2" name="line2" />
          <FormText control={control} label="State" name="state" />
          <FormText control={control} label="Postal code" name="postal_code" />
          <FormText control={control} label="Salary" name="salary_amount" type="number" />
          <FormText control={control} label="Currency" name="currency" />
          <FormTextSelect control={control} label="Pay frequency" name="pay_frequency" options={lookups.pay_frequencies} />
        </Box>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Cancel</Button>
        <Button disabled={isSaving} form="employee-form" type="submit" variant="contained">
          {isSaving ? 'Saving' : 'Save employee'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

function FormText({
  control,
  label,
  name,
  type = 'text',
}: {
  control: Control<EmployeeFormValues>
  label: string
  name: keyof EmployeeFormValues
  type?: string
}) {
  return (
    <Controller
      control={control}
      name={name}
      render={({ field, fieldState }) => (
        <TextField
          {...field}
          error={Boolean(fieldState.error)}
          helperText={fieldState.error?.message}
          label={label}
          slotProps={type === 'date' ? { inputLabel: { shrink: true } } : undefined}
          type={type}
        />
      )}
    />
  )
}

function FormSelect({
  control,
  label,
  name,
  options,
}: {
  control: Control<EmployeeFormValues>
  label: string
  name: keyof EmployeeFormValues
  options: Array<{ id: number; name: string }>
}) {
  return (
    <Controller
      control={control}
      name={name}
      render={({ field, fieldState }) => (
        <TextField {...field} error={Boolean(fieldState.error)} helperText={fieldState.error?.message} label={label} select>
          {options.map((option) => (
            <MenuItem key={option.id} value={option.id.toString()}>
              {option.name}
            </MenuItem>
          ))}
        </TextField>
      )}
    />
  )
}

function FormTextSelect({
  control,
  label,
  name,
  options,
}: {
  control: Control<EmployeeFormValues>
  label: string
  name: keyof EmployeeFormValues
  options: string[]
}) {
  return (
    <Controller
      control={control}
      name={name}
      render={({ field, fieldState }) => (
        <TextField {...field} error={Boolean(fieldState.error)} helperText={fieldState.error?.message} label={label} select>
          {options.map((option) => (
            <MenuItem key={option} value={option}>
              {option.replace('_', ' ')}
            </MenuItem>
          ))}
        </TextField>
      )}
    />
  )
}

function defaultValues(employee: Employee | null, lookups: Lookups): EmployeeFormValues {
  if (!employee) {
    return {
      employee_code: '',
      first_name: '',
      middle_name: '',
      last_name: '',
      email: '',
      hire_date: new Date().toISOString().slice(0, 10),
      employment_type: lookups.employment_types[0] ?? 'full_time',
      status: lookups.statuses[0] ?? 'active',
      department_id: lookups.departments[0]?.id.toString() ?? '',
      job_title_id: lookups.job_titles[0]?.id.toString() ?? '',
      line1: '',
      line2: '',
      city: '',
      state: '',
      postal_code: '',
      country: lookups.countries[0] ?? 'India',
      salary_amount: '',
      currency: 'USD',
      pay_frequency: lookups.pay_frequencies[0] ?? 'yearly',
    }
  }

  return {
    id: employee.id,
    employee_code: employee.employee_code,
    first_name: employee.first_name,
    middle_name: employee.middle_name ?? '',
    last_name: employee.last_name,
    email: employee.email,
    hire_date: employee.hire_date,
    employment_type: employee.employment_type,
    status: employee.status,
    department_id: employee.department?.id.toString() ?? '',
    job_title_id: employee.job_title?.id.toString() ?? '',
    line1: employee.address?.line1 ?? '',
    line2: employee.address?.line2 ?? '',
    city: employee.address?.city ?? '',
    state: employee.address?.state ?? '',
    postal_code: employee.address?.postal_code ?? '',
    country: employee.country ?? '',
    salary_amount: employee.salary?.amount ?? '',
    currency: employee.salary?.currency ?? 'USD',
    pay_frequency: employee.salary?.pay_frequency ?? 'yearly',
  }
}

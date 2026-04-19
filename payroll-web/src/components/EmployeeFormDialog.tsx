import { zodResolver } from '@hookform/resolvers/zod'
import {
  Box,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  MenuItem,
  Typography,
} from '@mui/material'
import { Controller, useForm } from 'react-hook-form'
import { useEffect } from 'react'
import { Button, DatePicker, RadioButtonGroup, TextBox } from './ui'
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
          <FormText control={control} label="Employee code" name="employeeCode" />
          <FormText control={control} label="First name" name="firstName" />
          <FormText control={control} label="Middle name" name="middleName" />
          <FormText control={control} label="Last name" name="lastName" />
          <FormText control={control} label="Email" name="email" type="email" />
          <FormDate control={control} label="Hire date" name="hireDate" />
          <FormSelect control={control} label="Department" name="departmentId" options={lookups.departments} />
          <FormSelect control={control} label="Job title" name="jobTitleId" options={lookups.jobTitles} />
          <FormRadioGroup control={control} label="Employment type" name="employmentType" options={lookups.employmentTypes} />
          <FormRadioGroup control={control} label="Status" name="status" options={lookups.statuses} />
          <FormText control={control} label="Country" name="country" />
          <FormText control={control} label="City" name="city" />
          <FormText control={control} label="Address line 1" name="line1" />
          <FormText control={control} label="Address line 2" name="line2" />
          <FormText control={control} label="State" name="state" />
          <FormText control={control} label="Postal code" name="postalCode" />
          <FormText control={control} label="Salary" name="salaryAmount" type="number" />
          <FormText control={control} label="Currency" name="currency" />
          <FormRadioGroup control={control} label="Pay frequency" name="payFrequency" options={lookups.payFrequencies} />
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
        <TextBox
          {...field}
          error={Boolean(fieldState.error)}
          helperText={fieldState.error?.message}
          label={label}
          type={type}
        />
      )}
    />
  )
}

function FormDate({
  control,
  label,
  name,
}: {
  control: Control<EmployeeFormValues>
  label: string
  name: keyof EmployeeFormValues
}) {
  return (
    <Controller
      control={control}
      name={name}
      render={({ field, fieldState }) => (
        <DatePicker
          {...field}
          error={Boolean(fieldState.error)}
          helperText={fieldState.error?.message}
          label={label}
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
        <TextBox {...field} error={Boolean(fieldState.error)} helperText={fieldState.error?.message} label={label} select>
          {options.map((option) => (
            <MenuItem key={option.id} value={option.id.toString()}>
              {option.name}
            </MenuItem>
          ))}
        </TextBox>
      )}
    />
  )
}

function FormRadioGroup({
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
        <RadioButtonGroup
          error={Boolean(fieldState.error)}
          helperText={fieldState.error?.message}
          label={label}
          onChange={field.onChange}
          options={options.map((option) => ({ label: option.replace('_', ' '), value: option }))}
          value={field.value?.toString() ?? ''}
        />
      )}
    />
  )
}

function defaultValues(employee: Employee | null, lookups: Lookups): EmployeeFormValues {
  if (!employee) {
    return {
      employeeCode: '',
      firstName: '',
      middleName: '',
      lastName: '',
      email: '',
      hireDate: new Date().toISOString().slice(0, 10),
      employmentType: lookups.employmentTypes[0] ?? 'full_time',
      status: lookups.statuses[0] ?? 'active',
      departmentId: lookups.departments[0]?.id.toString() ?? '',
      jobTitleId: lookups.jobTitles[0]?.id.toString() ?? '',
      line1: '',
      line2: '',
      city: '',
      state: '',
      postalCode: '',
      country: lookups.countries[0] ?? 'India',
      salaryAmount: '',
      currency: 'USD',
      payFrequency: lookups.payFrequencies[0] ?? 'yearly',
    }
  }

  return {
    id: employee.id,
    employeeCode: employee.employeeCode,
    firstName: employee.firstName,
    middleName: employee.middleName ?? '',
    lastName: employee.lastName,
    email: employee.email,
    hireDate: employee.hireDate,
    employmentType: employee.employmentType,
    status: employee.status,
    departmentId: employee.department?.id.toString() ?? '',
    jobTitleId: employee.jobTitle?.id.toString() ?? '',
    line1: employee.address?.line1 ?? '',
    line2: employee.address?.line2 ?? '',
    city: employee.address?.city ?? '',
    state: employee.address?.state ?? '',
    postalCode: employee.address?.postalCode ?? '',
    country: employee.country ?? '',
    salaryAmount: employee.salary?.amount ?? '',
    currency: employee.salary?.currency ?? 'USD',
    payFrequency: employee.salary?.payFrequency ?? 'yearly',
  }
}

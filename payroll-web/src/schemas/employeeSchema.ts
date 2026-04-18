import { z } from 'zod'

export const employeeSchema = z.object({
  id: z.number().optional(),
  employee_code: z.string().trim().min(1, 'Employee code is required').max(30),
  first_name: z.string().trim().min(1, 'First name is required').max(100),
  middle_name: z.string().trim().max(100),
  last_name: z.string().trim().min(1, 'Last name is required').max(100),
  email: z.string().trim().min(1, 'Email is required').email('Enter a valid email'),
  hire_date: z.string().min(1, 'Hire date is required'),
  employment_type: z.string().min(1, 'Employment type is required'),
  status: z.string().min(1, 'Status is required'),
  department_id: z.string().min(1, 'Department is required'),
  job_title_id: z.string().min(1, 'Job title is required'),
  line1: z.string().trim().min(1, 'Address line 1 is required'),
  line2: z.string().trim(),
  city: z.string().trim().min(1, 'City is required'),
  state: z.string().trim(),
  postal_code: z.string().trim().min(1, 'Postal code is required'),
  country: z.string().trim().min(1, 'Country is required'),
  salary_amount: z.string().min(1, 'Salary is required').refine((value) => Number(value) >= 0, 'Salary must be zero or greater'),
  currency: z.string().trim().length(3, 'Currency must be 3 letters'),
  pay_frequency: z.string().min(1, 'Pay frequency is required'),
})

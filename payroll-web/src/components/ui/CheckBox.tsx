import { Checkbox, FormControlLabel } from '@mui/material'
import type { CheckboxProps } from '@mui/material'

type CheckBoxProps = Omit<CheckboxProps, 'checked' | 'onChange'> & {
  checked: boolean
  label: string
  onChange: (checked: boolean) => void
}

export function CheckBox({ checked, label, onChange, ...props }: CheckBoxProps) {
  return (
    <FormControlLabel
      control={<Checkbox checked={checked} onChange={(event) => onChange(event.target.checked)} {...props} />}
      label={label}
    />
  )
}

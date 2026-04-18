import { FormControl, FormControlLabel, FormHelperText, FormLabel, Radio, RadioGroup } from '@mui/material'

type RadioOption = {
  label: string
  value: string
}

type RadioButtonGroupProps = {
  error?: boolean
  helperText?: string
  label: string
  onChange: (value: string) => void
  options: RadioOption[]
  value: string
}

export function RadioButtonGroup({
  error = false,
  helperText,
  label,
  onChange,
  options,
  value,
}: RadioButtonGroupProps) {
  return (
    <FormControl error={error}>
      <FormLabel>{label}</FormLabel>
      <RadioGroup row value={value} onChange={(event) => onChange(event.target.value)}>
        {options.map((option) => (
          <FormControlLabel control={<Radio />} key={option.value} label={option.label} value={option.value} />
        ))}
      </RadioGroup>
      {helperText && <FormHelperText>{helperText}</FormHelperText>}
    </FormControl>
  )
}

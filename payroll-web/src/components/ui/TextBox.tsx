import { TextField } from '@mui/material'
import type { TextFieldProps } from '@mui/material'

export type TextBoxProps = TextFieldProps

export function TextBox(props: TextBoxProps) {
  return <TextField fullWidth {...props} />
}

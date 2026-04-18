import { Button as MuiButton } from '@mui/material'
import type { ButtonProps as MuiButtonProps } from '@mui/material'

export type ButtonProps = MuiButtonProps

export function Button(props: ButtonProps) {
  return <MuiButton {...props} />
}

import { IconButton, Tooltip } from '@mui/material'
import type { IconButtonProps } from '@mui/material'
import type { ReactNode } from 'react'

type ActionIconButtonProps = Omit<IconButtonProps, 'aria-label' | 'title'> & {
  ariaLabel?: string
  label: string
  icon: ReactNode
}

export function ActionIconButton({ ariaLabel, icon, label, sx, ...props }: ActionIconButtonProps) {
  return (
    <Tooltip title={label}>
      <IconButton
        aria-label={ariaLabel ?? label}
        size="small"
        sx={{ borderRadius: 1, ...sx }}
        {...props}
      >
        {icon}
      </IconButton>
    </Tooltip>
  )
}

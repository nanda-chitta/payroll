import { SvgIcon } from '@mui/material'
import type { SvgIconProps } from '@mui/material'

export function EditIcon(props: SvgIconProps) {
  return (
    <SvgIcon {...props} viewBox="0 0 24 24">
      <path d="M4 17.25V20h2.75L17.81 8.94l-2.75-2.75L4 17.25Zm15.71-10.04a1 1 0 0 0 0-1.42l-1.5-1.5a1 1 0 0 0-1.42 0l-1.02 1.02 2.75 2.75 1.19-.85Z" />
    </SvgIcon>
  )
}

export function ViewIcon(props: SvgIconProps) {
  return (
    <SvgIcon {...props} viewBox="0 0 24 24">
      <path d="M12 5c5 0 8.5 4.5 9.8 6.5.3.4.3.7 0 1.1C20.5 14.5 17 19 12 19s-8.5-4.5-9.8-6.5a1 1 0 0 1 0-1.1C3.5 9.5 7 5 12 5Zm0 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm0-2.2a1.8 1.8 0 1 1 0-3.6 1.8 1.8 0 0 1 0 3.6Z" />
    </SvgIcon>
  )
}

export function DeleteIcon(props: SvgIconProps) {
  return (
    <SvgIcon {...props} viewBox="0 0 24 24">
      <path d="M7 21c-1.1 0-2-.9-2-2V8h14v11c0 1.1-.9 2-2 2H7ZM9 4h6l1 1h4v2H4V5h4l1-1Zm0 6v8h2v-8H9Zm4 0v8h2v-8h-2Z" />
    </SvgIcon>
  )
}

export function BellIcon(props: SvgIconProps) {
  return (
    <SvgIcon {...props} viewBox="0 0 24 24">
      <path d="M12 22a2.5 2.5 0 0 0 2.4-1.8H9.6A2.5 2.5 0 0 0 12 22Zm7-6.4-1.4-1.9V10a5.6 5.6 0 0 0-4.4-5.5V3a1.2 1.2 0 0 0-2.4 0v1.5A5.6 5.6 0 0 0 6.4 10v3.7L5 15.6V18h14v-2.4Z" />
    </SvgIcon>
  )
}

export function UserIcon(props: SvgIconProps) {
  return (
    <SvgIcon {...props} viewBox="0 0 24 24">
      <path d="M12 12a4.2 4.2 0 1 0 0-8.4 4.2 4.2 0 0 0 0 8.4Zm0 2c-4.4 0-8 2.2-8 5v1.4h16V19c0-2.8-3.6-5-8-5Z" />
    </SvgIcon>
  )
}

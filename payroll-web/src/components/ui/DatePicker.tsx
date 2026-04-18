import { TextBox } from './TextBox'
import type { TextBoxProps } from './TextBox'

export type DatePickerProps = Omit<TextBoxProps, 'type'>

export function DatePicker(props: DatePickerProps) {
  return <TextBox slotProps={{ inputLabel: { shrink: true }, ...props.slotProps }} type="date" {...props} />
}

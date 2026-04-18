import { DataGrid as MuiDataGrid } from '@mui/x-data-grid'
import type { DataGridProps } from '@mui/x-data-grid'

export function DataGrid(props: DataGridProps) {
  return (
    <MuiDataGrid
      disableColumnMenu
      disableRowSelectionOnClick
      pageSizeOptions={[10, 25, 50, 100]}
      {...props}
      sx={{
        border: 0,
        '& .MuiDataGrid-cell': {
          alignItems: 'center',
          display: 'flex',
        },
        '& .MuiDataGrid-columnHeaders': {
          bgcolor: 'background.default',
        },
        ...props.sx,
      }}
    />
  )
}

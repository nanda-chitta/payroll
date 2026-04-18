import { Card, CardContent, Skeleton, Typography } from '@mui/material'

type MetricCardProps = {
  title: string
  value: string | number
  isLoading?: boolean
}

export function MetricCard({ title, value, isLoading = false }: MetricCardProps) {
  return (
    <Card>
      <CardContent>
        <Typography color="text.secondary" variant="body2">
          {title}
        </Typography>
        <Typography component="strong" sx={{ display: 'block', mt: 1.5 }} variant="h4">
          {isLoading ? <Skeleton width={120} /> : value}
        </Typography>
      </CardContent>
    </Card>
  )
}

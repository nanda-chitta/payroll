import { Box, Card, CardContent, LinearProgress, Typography } from '@mui/material'
import { money } from '../utils/formatters'
import type { Lookup, SalaryInsights } from '../types/payroll'

type SalaryInsightsPanelProps = {
  country: string
  selectedJobTitle?: Lookup
  insights: SalaryInsights | null
}

export function SalaryInsightsPanel({ country, selectedJobTitle, insights }: SalaryInsightsPanelProps) {
  const total = insights?.countrySalary.employeeCount ?? 0

  return (
    <Box
      sx={{
        display: 'grid',
        gap: 2,
        gridTemplateColumns: { lg: '1fr 1.5fr 1.5fr', xs: '1fr' },
      }}
    >
      <Card>
        <CardContent>
          <Typography variant="h2">{selectedJobTitle?.name ?? 'Selected role'}</Typography>
          <Typography color="text.secondary">
            Average salary in {country || 'all countries'}
          </Typography>
          <Typography component="strong" sx={{ display: 'block', mt: 2 }} variant="h4">
            {money(insights?.jobTitleSalary.averageSalary)}
          </Typography>
        </CardContent>
      </Card>
      <InsightBars
        rows={(insights?.salaryDistribution ?? []).map((bucket) => ({
          label: bucket.label,
          value: bucket.employeeCount,
        }))}
        title="Salary bands"
        total={total}
      />
      <InsightBars
        rows={(insights?.headcountByJobTitle ?? []).map((jobTitle) => ({
          label: jobTitle.name,
          value: jobTitle.employeeCount,
        }))}
        title="Top roles"
        total={total}
      />
    </Box>
  )
}

function InsightBars({
  title,
  rows,
  total,
}: {
  title: string
  rows: Array<{ label: string; value: number }>
  total: number
}) {
  return (
    <Card>
      <CardContent>
        <Typography variant="h2">{title}</Typography>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1.5, mt: 2 }}>
          {rows.map((row) => (
            <Box key={row.label}>
              <Box sx={{ alignItems: 'center', display: 'flex', justifyContent: 'space-between' }}>
                <Typography color="text.secondary" variant="body2">
                  {row.label}
                </Typography>
                <Typography sx={{ fontWeight: 700 }} variant="body2">
                  {row.value}
                </Typography>
              </Box>
              <LinearProgress
                sx={{ borderRadius: 8, height: 10, mt: 0.75 }}
                value={barValue(row.value, total)}
                variant="determinate"
              />
            </Box>
          ))}
        </Box>
      </CardContent>
    </Card>
  )
}

function barValue(value: number, total: number) {
  if (!total) return 0

  return Math.max(6, Math.round((value / total) * 100))
}

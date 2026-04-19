import { Navigate, Route, Routes } from 'react-router'
import { SalaryManagementPage } from '../pages/SalaryManagementPage'
import { HomeLayout } from '../layouts'

export function AppRoutes() {
  return (
    <Routes>
      <Route element={<HomeLayout />}>
        <Route element={<Navigate replace to="/salary-management" />} path="/" />
        <Route element={<SalaryManagementPage />} path="/salary-management" />
        <Route element={<Navigate replace to="/salary-management" />} path="*" />
      </Route>
    </Routes>
  )
}

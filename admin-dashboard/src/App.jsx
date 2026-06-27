import { Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import JobModeration from './pages/JobModeration';
import ClinicVerification from './pages/ClinicVerification';
import UserManagement from './pages/UserManagement';
import Analytics from './pages/Analytics';
import Reports from './pages/Reports';

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<Navigate to="/dashboard" replace />} />
        <Route path="dashboard" element={<Dashboard />} />
        <Route path="jobs" element={<JobModeration />} />
        <Route path="clinics" element={<ClinicVerification />} />
        <Route path="users" element={<UserManagement />} />
        <Route path="analytics" element={<Analytics />} />
        <Route path="reports" element={<Reports />} />
      </Route>
    </Routes>
  );
}

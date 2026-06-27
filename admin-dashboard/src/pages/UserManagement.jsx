import { Typography, Box, Chip } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';

const columns = [
  { field: 'name', headerName: 'Name', flex: 1 },
  { field: 'email', headerName: 'Email', flex: 1 },
  { field: 'role', headerName: 'Role', width: 150 },
  {
    field: 'status', headerName: 'Status', width: 120,
    renderCell: (params) => (
      <Chip label={params.value} size="small"
        color={params.value === 'ACTIVE' ? 'success' : 'error'} />
    ),
  },
  { field: 'joinedAt', headerName: 'Joined', width: 120 },
];

const rows = [
  { id: 1, name: 'Dr. Priya Kumar', email: 'priya@email.com', role: 'DENTIST', status: 'ACTIVE', joinedAt: '2024-06-01' },
  { id: 2, name: 'Dr. Raj Sharma', email: 'raj@email.com', role: 'CLINIC_OWNER', status: 'ACTIVE', joinedAt: '2024-05-15' },
  { id: 3, name: 'Admin Mumbai', email: 'mumbai@dentconnect.in', role: 'REGIONAL_ADMIN', status: 'ACTIVE', joinedAt: '2024-04-01' },
];

export default function UserManagement() {
  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>User Management</Typography>
      <Box sx={{ height: 500, bgcolor: 'white', borderRadius: 2 }}>
        <DataGrid rows={rows} columns={columns} pageSize={10} disableRowSelectionOnClick />
      </Box>
    </Box>
  );
}

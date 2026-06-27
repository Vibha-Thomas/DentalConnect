import { Typography, Box, Chip } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';

const columns = [
  { field: 'name', headerName: 'Clinic Name', flex: 1 },
  { field: 'city', headerName: 'City', width: 130 },
  { field: 'owner', headerName: 'Owner', width: 150 },
  { field: 'chairs', headerName: 'Chairs', width: 80 },
  {
    field: 'status', headerName: 'Verification', width: 140,
    renderCell: (params) => (
      <Chip
        label={params.value}
        size="small"
        color={params.value === 'PENDING' ? 'warning' : params.value === 'VERIFIED' ? 'success' : 'error'}
      />
    ),
  },
  { field: 'submittedAt', headerName: 'Submitted', width: 120 },
];

const rows = [
  { id: 1, name: 'Smile Dental Clinic', city: 'Bangalore', owner: 'Dr. Sharma', chairs: 5, status: 'PENDING', submittedAt: '2024-06-20' },
  { id: 2, name: 'Bright Teeth', city: 'Chennai', owner: 'Dr. Patel', chairs: 3, status: 'PENDING', submittedAt: '2024-06-19' },
  { id: 3, name: 'City Dental Care', city: 'Mumbai', owner: 'Dr. Mehta', chairs: 8, status: 'VERIFIED', submittedAt: '2024-06-15' },
];

export default function ClinicVerification() {
  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>Clinic Verification</Typography>
      <Box sx={{ height: 500, bgcolor: 'white', borderRadius: 2 }}>
        <DataGrid rows={rows} columns={columns} pageSize={10} disableRowSelectionOnClick />
      </Box>
    </Box>
  );
}

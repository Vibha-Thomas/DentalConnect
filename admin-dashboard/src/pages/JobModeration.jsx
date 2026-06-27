import { Typography, Box, Chip } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';

const columns = [
  { field: 'title', headerName: 'Job Title', flex: 1 },
  { field: 'clinic', headerName: 'Clinic', flex: 1 },
  { field: 'location', headerName: 'Location', width: 130 },
  { field: 'type', headerName: 'Type', width: 120 },
  {
    field: 'status', headerName: 'Status', width: 150,
    renderCell: (params) => (
      <Chip
        label={params.value}
        size="small"
        color={params.value === 'PENDING_APPROVAL' ? 'warning' : params.value === 'PUBLISHED' ? 'success' : 'default'}
      />
    ),
  },
  { field: 'postedAt', headerName: 'Posted', width: 120 },
];

const rows = [
  { id: 1, title: 'Associate Dentist', clinic: 'Smile Dental', location: 'Bangalore', type: 'Full-Time', status: 'PENDING_APPROVAL', postedAt: '2024-06-20' },
  { id: 2, title: 'Orthodontist', clinic: 'Bright Teeth', location: 'Chennai', type: 'Full-Time', status: 'PENDING_APPROVAL', postedAt: '2024-06-19' },
  { id: 3, title: 'Dental Intern', clinic: 'City Dental', location: 'Mumbai', type: 'Internship', status: 'PUBLISHED', postedAt: '2024-06-18' },
  { id: 4, title: 'Locum Dentist', clinic: 'CareDent', location: 'Hyderabad', type: 'Locum', status: 'PENDING_APPROVAL', postedAt: '2024-06-17' },
];

export default function JobModeration() {
  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>Job Moderation</Typography>
      <Box sx={{ height: 500, bgcolor: 'white', borderRadius: 2 }}>
        <DataGrid rows={rows} columns={columns} pageSize={10} disableRowSelectionOnClick />
      </Box>
    </Box>
  );
}

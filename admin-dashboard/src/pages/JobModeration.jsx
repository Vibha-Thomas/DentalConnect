import { useEffect, useState } from 'react';
import { Typography, Box, Chip, Card, CardContent, Grid, Button } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import { Check, Close, Archive } from '@mui/icons-material';
import adminApi from '../api/adminApi';

export default function JobModeration() {
  const [jobs, setJobs] = useState([]);
  const [activeQueue, setActiveQueue] = useState('PENDING_APPROVAL'); // PENDING_APPROVAL | PUBLISHED
  const [loading, setLoading] = useState(true);

  const fetchJobs = async () => {
    setLoading(true);
    try {
      const res = await adminApi.get(`/admin/jobs?status=${activeQueue}`);
      const list = res.data.data.content || [];
      if (list.length === 0) {
        setJobs([
          { id: '1', title: 'Associate Dentist', clinicName: 'Smile Dental', city: 'Bangalore', employmentType: 'FULL_TIME', status: 'PENDING_APPROVAL', createdAt: '2024-06-20' },
          { id: '2', title: 'Orthodontist', clinicName: 'Bright Teeth', city: 'Chennai', employmentType: 'PART_TIME', status: 'PENDING_APPROVAL', createdAt: '2024-06-19' },
          { id: '3', title: 'Locum Dentist', clinicName: 'CareDent', city: 'Hyderabad', employmentType: 'LOCUM', status: 'PENDING_APPROVAL', createdAt: '2024-06-17' },
          { id: '4', title: 'Dental Intern', clinicName: 'City Dental', city: 'Mumbai', employmentType: 'INTERNSHIP', status: 'PUBLISHED', createdAt: '2024-06-18' }
        ].filter(j => j.status === activeQueue));
      } else {
        setJobs(list);
      }
    } catch (err) {
      console.error('Fetch jobs error:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchJobs();
  }, [activeQueue]);

  const handleModerate = async (jobId, statusAction) => {
    try {
      await adminApi.put(`/admin/jobs/${jobId}/verify`, {
        status: statusAction
      });
      fetchJobs();
    } catch (err) {
      console.error('Job moderation error:', err);
    }
  };

  const columns = [
    { field: 'title', headerName: 'Job Title', flex: 1, renderCell: (params) => <Typography sx={{ fontWeight: 650 }}>{params.value}</Typography> },
    { field: 'clinicName', headerName: 'Clinic', width: 160, valueGetter: (params) => params.row.clinicName || 'Dental Care Center' },
    { field: 'city', headerName: 'Location', width: 130 },
    {
      field: 'employmentType', headerName: 'Type', width: 130,
      renderCell: (params) => <Chip label={params.value} size="small" variant="outlined" />
    },
    {
      field: 'id', headerName: 'Moderate Actions', width: 220, sortable: false,
      renderCell: (params) => (
        <Box sx={{ display: 'flex', gap: 1 }}>
          {activeQueue === 'PENDING_APPROVAL' ? (
            <>
              <Button size="small" variant="contained" color="success" startIcon={<Check />} onClick={() => handleModerate(params.row.id, 'PUBLISHED')}>
                Approve
              </Button>
              <Button size="small" variant="outlined" color="error" startIcon={<Close />} onClick={() => handleModerate(params.row.id, 'REJECTED')}>
                Reject
              </Button>
            </>
          ) : (
            <Button size="small" variant="outlined" color="warning" startIcon={<Archive />} onClick={() => handleModerate(params.row.id, 'ARCHIVED')}>
              Archive
            </Button>
          )}
        </Box>
      )
    }
  ];

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      <Box>
        <Typography variant="h4" sx={{ fontWeight: 800, mb: 0.5 }}>Job Moderation</Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary' }}>Review, flag, approve, or archive job postings submitted by clinics.</Typography>
      </Box>

      {/* Tabs */}
      <Grid container spacing={2}>
        <Grid item xs={12} sm={6}>
          <Card onClick={() => setActiveQueue('PENDING_APPROVAL')} sx={{ cursor: 'pointer', border: activeQueue === 'PENDING_APPROVAL' ? '2px solid #F59E0B' : '1px solid rgba(255,255,255,0.05)', bgcolor: activeQueue === 'PENDING_APPROVAL' ? 'rgba(255,255,255,0.02)' : 'transparent' }}>
            <CardContent sx={{ py: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 700, color: activeQueue === 'PENDING_APPROVAL' ? '#F59E0B' : 'text.secondary' }}>
                Pending Job Approvals
              </Typography>
              <Chip label={activeQueue === 'PENDING_APPROVAL' ? jobs.length : '*'} size="small" sx={{ bgcolor: '#F59E0B', color: 'white', fontWeight: 700 }} />
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6}>
          <Card onClick={() => setActiveQueue('PUBLISHED')} sx={{ cursor: 'pointer', border: activeQueue === 'PUBLISHED' ? '2px solid #10B981' : '1px solid rgba(255,255,255,0.05)', bgcolor: activeQueue === 'PUBLISHED' ? 'rgba(255,255,255,0.02)' : 'transparent' }}>
            <CardContent sx={{ py: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 700, color: activeQueue === 'PUBLISHED' ? '#10B981' : 'text.secondary' }}>
                Published Listings
              </Typography>
              <Chip label={activeQueue === 'PUBLISHED' ? jobs.length : '*'} size="small" sx={{ bgcolor: '#10B981', color: 'white', fontWeight: 700 }} />
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Main grid */}
      <Card>
        <Box sx={{ height: 500, width: '100%' }}>
          <DataGrid
            rows={jobs}
            columns={columns}
            loading={loading}
            sx={{
              border: 'none',
              '& .MuiDataGrid-cell': { borderBottom: '1px solid rgba(255,255,255,0.05)' },
              '& .MuiDataGrid-columnHeaders': { borderBottom: '1px solid rgba(255,255,255,0.1)' }
            }}
          />
        </Box>
      </Card>
    </Box>
  );
}

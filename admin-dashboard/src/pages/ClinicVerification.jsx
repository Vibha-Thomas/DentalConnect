import { useEffect, useState } from 'react';
import { Typography, Box, Chip, Card, CardContent, Grid, Button, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, TextField, List, ListItem, ListItemText } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import { Check, Close, Info } from '@mui/icons-material';
import adminApi from '../api/adminApi';

export default function ClinicVerification() {
  const [clinics, setClinics] = useState([]);
  const [activeTab, setActiveTab] = useState('PENDING'); // PENDING | VERIFIED
  const [selectedClinic, setSelectedClinic] = useState(null);
  const [notes, setNotes] = useState('');
  const [openVerifyDialog, setOpenVerifyDialog] = useState(false);
  const [loading, setLoading] = useState(true);

  const fetchClinics = async () => {
    setLoading(true);
    try {
      const res = await adminApi.get(`/admin/clinics?verified=${activeTab}`);
      const list = res.data.data.content || [];
      if (list.length === 0) {
        setClinics([
          { id: '1', name: 'Smile Dental Clinic', city: 'Bangalore', phone: '9876543210', chairsCount: 5, verificationStatus: 'PENDING', ownerId: 'owner-1', specialties: ['Orthodontics', 'Implants'] },
          { id: '2', name: 'Bright Teeth', city: 'Chennai', phone: '9123456789', chairsCount: 3, verificationStatus: 'PENDING', ownerId: 'owner-2', specialties: ['General'] },
          { id: '3', name: 'City Dental Care', city: 'Mumbai', phone: '8123456780', chairsCount: 8, verificationStatus: 'VERIFIED', ownerId: 'owner-3', specialties: ['Cosmetics'] }
        ].filter(c => c.verificationStatus === activeTab));
      } else {
        setClinics(list);
      }
    } catch (err) {
      console.error('Fetch clinics error:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchClinics();
  }, [activeTab]);

  const handleVerifyOpen = (clinic, statusAction) => {
    setSelectedClinic({ clinic, action: statusAction });
    setOpenVerifyDialog(true);
  };

  const handleVerifySubmit = async () => {
    if (!selectedClinic) return;
    try {
      await adminApi.put(`/admin/clinics/${selectedClinic.clinic.id}/verify`, {
        status: selectedClinic.action === 'APPROVED' ? 'VERIFIED' : 'REJECTED',
        notes: notes
      });
      setOpenVerifyDialog(false);
      setNotes('');
      fetchClinics();
    } catch (err) {
      console.error('Verify clinic error:', err);
    }
  };

  const columns = [
    { field: 'name', headerName: 'Clinic Name', flex: 1, renderCell: (params) => <Typography sx={{ fontWeight: 650 }}>{params.value}</Typography> },
    { field: 'city', headerName: 'City', width: 140 },
    { field: 'chairsCount', headerName: 'Dental Chairs', width: 120 },
    {
      field: 'specialties', headerName: 'Specialties', flex: 1,
      renderCell: (params) => (
        <Box sx={{ display: 'flex', gap: 0.5, flexWrap: 'wrap', pt: 1 }}>
          {params.value && params.value.map((spec, i) => (
            <Chip key={i} label={spec} size="small" variant="outlined" />
          ))}
        </Box>
      )
    },
    {
      field: 'id', headerName: 'Verify Status', width: 180, sortable: false,
      renderCell: (params) => (
        <Box sx={{ display: 'flex', gap: 1 }}>
          {activeTab === 'PENDING' ? (
            <>
              <Button size="small" variant="contained" color="success" startIcon={<Check />} onClick={() => handleVerifyOpen(params.row, 'APPROVED')}>
                Approve
              </Button>
              <Button size="small" variant="outlined" color="error" startIcon={<Close />} onClick={() => handleVerifyOpen(params.row, 'REJECTED')}>
                Reject
              </Button>
            </>
          ) : (
            <Chip label="Verified" size="small" color="success" />
          )}
        </Box>
      )
    }
  ];

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      <Box>
        <Typography variant="h4" sx={{ fontWeight: 800, mb: 0.5 }}>Clinic Verification</Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary' }}>Verify credentials, licensing, and set verification status for clinics.</Typography>
      </Box>

      {/* Tabs */}
      <Grid container spacing={2}>
        <Grid item xs={12} sm={6}>
          <Card onClick={() => setActiveTab('PENDING')} sx={{ cursor: 'pointer', border: activeTab === 'PENDING' ? '2px solid #F59E0B' : '1px solid rgba(255,255,255,0.05)', bgcolor: activeTab === 'PENDING' ? 'rgba(255,255,255,0.02)' : 'transparent' }}>
            <CardContent sx={{ py: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 700, color: activeTab === 'PENDING' ? '#F59E0B' : 'text.secondary' }}>
                Pending Verification Queue
              </Typography>
              <Chip label={activeTab === 'PENDING' ? clinics.length : '*'} size="small" sx={{ bgcolor: '#F59E0B', color: 'white', fontWeight: 700 }} />
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6}>
          <Card onClick={() => setActiveTab('VERIFIED')} sx={{ cursor: 'pointer', border: activeTab === 'VERIFIED' ? '2px solid #10B981' : '1px solid rgba(255,255,255,0.05)', bgcolor: activeTab === 'VERIFIED' ? 'rgba(255,255,255,0.02)' : 'transparent' }}>
            <CardContent sx={{ py: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 700, color: activeTab === 'VERIFIED' ? '#10B981' : 'text.secondary' }}>
                Verified Clinics
              </Typography>
              <Chip label={activeTab === 'VERIFIED' ? clinics.length : '*'} size="small" sx={{ bgcolor: '#10B981', color: 'white', fontWeight: 700 }} />
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Main Roster List */}
      <Card>
        <Box sx={{ height: 500, width: '100%' }}>
          <DataGrid
            rows={clinics}
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

      {/* Verification Dialogue */}
      <Dialog open={openVerifyDialog} onClose={() => setOpenVerifyDialog(false)}>
        <DialogTitle sx={{ fontWeight: 700 }}>
          Moderate Clinic: {selectedClinic?.clinic.name}
        </DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ mb: 2, color: 'text.secondary' }}>
            Provide comments regarding the verification decision (mandatory for auditing).
          </Typography>
          <TextField
            fullWidth
            label="Internal Notes"
            multiline
            rows={3}
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Document check status..."
          />
        </DialogContent>
        <DialogActions sx={{ p: 2.5 }}>
          <Button onClick={() => setOpenVerifyDialog(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleVerifySubmit} sx={{ bgcolor: selectedClinic?.action === 'APPROVED' ? '#10B981' : '#EF4444', color: 'white' }}>
            Confirm Decisions
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

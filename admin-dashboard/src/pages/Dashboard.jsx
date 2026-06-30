import { useEffect, useState } from 'react';
import { Grid, Typography, Card, CardContent, Box, Button, Chip } from '@mui/material';
import { People, Business, Work, Description, CheckCircle, HourglassEmpty, ArrowForward } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import adminApi from '../api/adminApi';
import KpiCard from '../components/KpiCard';
import SkeletonLoader from '../components/SkeletonLoader';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export default function Dashboard() {
  const [loading, setLoading] = useState(true);
  const [kpis, setKpis] = useState(null);
  const [chartData, setChartData] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [kpisRes, chartRes] = await Promise.all([
          adminApi.get('/admin/stats/kpis'),
          adminApi.get('/admin/analytics/registrations?months=6'),
        ]);
        setKpis(kpisRes.data.data);
        setChartData(chartRes.data.data || []);
      } catch (err) {
        console.error('Failed to load dashboard data:', err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) {
    return (
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 800 }}>Dashboard Overview</Typography>
        <SkeletonLoader type="kpis" />
        <SkeletonLoader type="charts" />
      </Box>
    );
  }

  // Fallback / Mock sparkline configurations
  const mockSpark = [
    { value: 10 }, { value: 15 }, { value: 8 }, { value: 20 }, { value: 35 }, { value: 42 }
  ];

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      {/* Title */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, mb: 0.5 }}>
            Overview
          </Typography>
          <Typography variant="body2" sx={{ color: 'text.secondary' }}>
            System activity metrics and recruiter verification queues.
          </Typography>
        </Box>
        <Button
          variant="contained"
          endIcon={<ArrowForward />}
          onClick={() => navigate('/clinics')}
          sx={{ py: 1, px: 2, bgcolor: '#1E40AF', color: 'white', '&:hover': { bgcolor: '#1D4ED8' } }}
        >
          Verify Pending Profiles
        </Button>
      </Box>

      {/* KPI Cards Grid */}
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={4}>
          <KpiCard
            title="Registered Dentists"
            value={kpis?.totalDentists || 0}
            change={kpis?.dentistGrowth ? kpis.dentistGrowth.toFixed(1) : "12.4"}
            isPositive={kpis?.dentistGrowth >= 0}
            icon={<People />}
            color="#38BDF8"
            sparklineData={mockSpark}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <KpiCard
            title="Total Clinics"
            value={kpis?.totalClinics || 0}
            change="8.2"
            isPositive={true}
            icon={<Business />}
            color="#10B981"
            sparklineData={mockSpark}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <KpiCard
            title="Verified Clinics"
            value={kpis?.verifiedClinics || 0}
            change="5.1"
            isPositive={true}
            icon={<CheckCircle />}
            color="#3B82F6"
            sparklineData={mockSpark}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <KpiCard
            title="Active Job Postings"
            value={kpis?.totalJobs || 0}
            change="14.2"
            isPositive={true}
            icon={<Work />}
            color="#F59E0B"
            sparklineData={mockSpark}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <KpiCard
            title="Applications Received"
            value={kpis?.totalApplications || 0}
            change="22.8"
            isPositive={true}
            icon={<Description />}
            color="#EC4899"
            sparklineData={mockSpark}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <KpiCard
            title="Scheduled Interviews"
            value={kpis?.interviewsScheduled || 0}
            change="3.4"
            isPositive={false}
            icon={<HourglassEmpty />}
            color="#A855F7"
            sparklineData={mockSpark}
          />
        </Grid>
      </Grid>

      {/* Recruiter Actionable Workflow Queues */}
      <Card sx={{ border: '1px solid rgba(255, 255, 255, 0.05)' }}>
        <CardContent>
          <Typography variant="h6" sx={{ fontWeight: 700, mb: 3 }}>
            Recruitment Flow Queues
          </Typography>
          <Grid container spacing={3}>
            <Grid item xs={12} sm={4}>
              <Box sx={{
                p: 3,
                borderRadius: 4,
                bgcolor: 'rgba(56, 189, 248, 0.05)',
                border: '1px solid rgba(56, 189, 248, 0.1)',
                cursor: 'pointer',
                transition: 'border-color 0.2s',
                '&:hover': { borderColor: '#38BDF8' }
              }} onClick={() => navigate('/clinics?status=PENDING')}>
                <Typography variant="subtitle2" sx={{ color: '#38BDF8', fontWeight: 700, mb: 1 }}>
                  Pending Profile Verifications
                </Typography>
                <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 1 }}>
                  <Typography variant="h3" sx={{ fontWeight: 850 }}>
                    {kpis?.pendingVerification || 0}
                  </Typography>
                  <Typography variant="body2" sx={{ color: 'text.secondary' }}>profiles</Typography>
                </Box>
              </Box>
            </Grid>

            <Grid item xs={12} sm={4}>
              <Box sx={{
                p: 3,
                borderRadius: 4,
                bgcolor: 'rgba(245, 158, 11, 0.05)',
                border: '1px solid rgba(245, 158, 11, 0.1)',
                cursor: 'pointer',
                transition: 'border-color 0.2s',
                '&:hover': { borderColor: '#F59E0B' }
              }} onClick={() => navigate('/jobs?status=PENDING_APPROVAL')}>
                <Typography variant="subtitle2" sx={{ color: '#F59E0B', fontWeight: 700, mb: 1 }}>
                  Pending Job Approvals
                </Typography>
                <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 1 }}>
                  <Typography variant="h3" sx={{ fontWeight: 850 }}>
                    4
                  </Typography>
                  <Typography variant="body2" sx={{ color: 'text.secondary' }}>jobs</Typography>
                </Box>
              </Box>
            </Grid>

            <Grid item xs={12} sm={4}>
              <Box sx={{
                p: 3,
                borderRadius: 4,
                bgcolor: 'rgba(16, 185, 129, 0.05)',
                border: '1px solid rgba(16, 185, 129, 0.1)',
                cursor: 'pointer',
                transition: 'border-color 0.2s',
                '&:hover': { borderColor: '#10B981' }
              }} onClick={() => navigate('/users')}>
                <Typography variant="subtitle2" sx={{ color: '#10B981', fontWeight: 700, mb: 1 }}>
                  Completed Profiles Today
                </Typography>
                <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 1 }}>
                  <Typography variant="h3" sx={{ fontWeight: 850 }}>
                    {kpis?.onboardingCompleted || 0}
                  </Typography>
                  <Typography variant="body2" sx={{ color: 'text.secondary' }}>dentists</Typography>
                </Box>
              </Box>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Main Registrations Chart */}
      <Card sx={{ p: 3 }}>
        <Typography variant="h6" sx={{ fontWeight: 700, mb: 3 }}>
          Platform Registrations Timeline
        </Typography>
        <Box sx={{ height: 350, width: '100%' }}>
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={chartData}>
              <defs>
                <linearGradient id="colorRegistrations" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#38BDF8" stopOpacity={0.3} />
                  <stop offset="95%" stopColor="#38BDF8" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
              <XAxis dataKey="month" stroke="#94A3B8" />
              <YAxis stroke="#94A3B8" />
              <Tooltip
                contentStyle={{ backgroundColor: '#111827', border: '1px solid rgba(255,255,255,0.1)' }}
                labelStyle={{ color: 'white' }}
              />
              <Area type="monotone" dataKey="count" stroke="#38BDF8" strokeWidth={3} fillOpacity={1} fill="url(#colorRegistrations)" name="Registrations" />
            </AreaChart>
          </ResponsiveContainer>
        </Box>
      </Card>
    </Box>
  );
}

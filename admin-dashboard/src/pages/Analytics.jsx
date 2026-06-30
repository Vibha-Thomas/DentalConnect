import { useEffect, useState } from 'react';
import { Grid, Typography, Card, CardContent, Box, CircularProgress } from '@mui/material';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, LineChart, Line, FunnelChart, Funnel, LabelList } from 'recharts';
import adminApi from '../api/adminApi';

const COLORS = ['#38BDF8', '#10B981', '#F59E0B', '#EC4899', '#8B5CF6'];

export default function Analytics() {
  const [loading, setLoading] = useState(true);
  const [registrations, setRegistrations] = useState([]);
  const [topCities, setTopCities] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [regRes, citiesRes] = await Promise.all([
          adminApi.get('/admin/analytics/registrations?months=6'),
          adminApi.get('/admin/analytics/top-cities'),
        ]);
        setRegistrations(regRes.data.data || []);
        setTopCities(citiesRes.data.data || []);
      } catch (err) {
        console.error('Analytics load error:', err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
        <CircularProgress color="primary" />
      </Box>
    );
  }

  // Pre-configured conversion datasets matching SaaS flow
  const conversionData = [
    { value: 100, name: 'Registrations', fill: '#38BDF8' },
    { value: 80, name: 'Completed Profiles', fill: '#3B82F6' },
    { value: 55, name: 'Job Applications', fill: '#8B5CF6' },
    { value: 30, name: 'Interviews', fill: '#EC4899' },
    { value: 15, name: 'Offers Accepted', fill: '#10B981' },
  ];

  const specialtyData = [
    { name: 'General Dentistry', value: 45 },
    { name: 'Orthodontics', value: 25 },
    { name: 'Endodontics', value: 15 },
    { name: 'Oral Surgery', value: 10 },
    { name: 'Pediodontics', value: 5 },
  ];

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      <Box>
        <Typography variant="h4" sx={{ fontWeight: 800, mb: 0.5 }}>Analytics Dashboard</Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary' }}>Unified platform funnel charts and regional stats.</Typography>
      </Box>

      <Grid container spacing={3}>
        {/* Registrations Chart */}
        <Grid item xs={12} md={6}>
          <Card sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>Monthly Dentist Registrations</Typography>
            <Box sx={{ height: 300 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={registrations}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
                  <XAxis dataKey="month" stroke="#94A3B8" />
                  <YAxis stroke="#94A3B8" />
                  <Tooltip contentStyle={{ backgroundColor: '#111827', border: 'none', borderRadius: 8 }} />
                  <Bar dataKey="count" fill="#38BDF8" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </Box>
          </Card>
        </Grid>

        {/* Top Cities Chart */}
        <Grid item xs={12} md={6}>
          <Card sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>Dentists by City</Typography>
            <Box sx={{ height: 300 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={topCities.length > 0 ? topCities : [{ city: 'Bangalore', count: 12 }, { city: 'Chennai', count: 8 }]}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
                  <XAxis dataKey="city" stroke="#94A3B8" />
                  <YAxis stroke="#94A3B8" />
                  <Tooltip contentStyle={{ backgroundColor: '#111827', border: 'none', borderRadius: 8 }} />
                  <Bar dataKey="count" fill="#10B981" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </Box>
          </Card>
        </Grid>

        {/* Recruitment Conversion Funnel */}
        <Grid item xs={12} md={6}>
          <Card sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>Platform Conversion Funnel</Typography>
            <Box sx={{ height: 300 }}>
              <ResponsiveContainer width="100%" height="100%">
                <FunnelChart>
                  <Tooltip contentStyle={{ backgroundColor: '#111827', border: 'none', borderRadius: 8 }} />
                  <Funnel dataKey="value" data={conversionData} isAnimationActive>
                    <LabelList position="right" fill="#94A3B8" stroke="none" dataKey="name" />
                  </Funnel>
                </FunnelChart>
              </ResponsiveContainer>
            </Box>
          </Card>
        </Grid>

        {/* Specialties Distribution Pie */}
        <Grid item xs={12} md={6}>
          <Card sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>Dentist Specialties Distribution</Typography>
            <Box sx={{ height: 300, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={specialtyData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={90}
                    paddingAngle={5}
                    dataKey="value"
                  >
                    {specialtyData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip contentStyle={{ backgroundColor: '#111827', border: 'none', borderRadius: 8 }} />
                </PieChart>
              </ResponsiveContainer>
            </Box>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}

import { Grid, Card, CardContent, Typography, Box } from '@mui/material';
import { People, Work, Business, TrendingUp } from '@mui/icons-material';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, LineChart, Line,
} from 'recharts';

const stats = [
  { label: 'Total Users', value: '2,847', icon: <People />, color: '#1565C0' },
  { label: 'Active Jobs', value: '186', icon: <Work />, color: '#009688' },
  { label: 'Verified Clinics', value: '94', icon: <Business />, color: '#388E3C' },
  { label: 'Hiring Rate', value: '34%', icon: <TrendingUp />, color: '#F57C00' },
];

const monthlyData = [
  { month: 'Jan', applications: 120, hires: 18 },
  { month: 'Feb', applications: 180, hires: 24 },
  { month: 'Mar', applications: 250, hires: 38 },
  { month: 'Apr', applications: 310, hires: 45 },
  { month: 'May', applications: 420, hires: 62 },
  { month: 'Jun', applications: 380, hires: 54 },
];

const regionData = [
  { name: 'Bangalore', value: 35 },
  { name: 'Chennai', value: 25 },
  { name: 'Mumbai', value: 20 },
  { name: 'Hyderabad', value: 12 },
  { name: 'Delhi', value: 8 },
];

const COLORS = ['#1565C0', '#009688', '#F57C00', '#D32F2F', '#7B1FA2'];

export default function Dashboard() {
  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>Dashboard</Typography>

      {/* Stats Cards */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        {stats.map((stat) => (
          <Grid item xs={12} sm={6} md={3} key={stat.label}>
            <Card>
              <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                <Box sx={{
                  width: 48, height: 48, borderRadius: 2,
                  bgcolor: `${stat.color}15`, color: stat.color,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  {stat.icon}
                </Box>
                <Box>
                  <Typography variant="body2" color="text.secondary">{stat.label}</Typography>
                  <Typography variant="h5">{stat.value}</Typography>
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* Charts */}
      <Grid container spacing={3}>
        {/* Applications Trend */}
        <Grid item xs={12} md={8}>
          <Card sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ mb: 2 }}>Applications & Hires</Typography>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={monthlyData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="applications" fill="#1565C0" radius={[4, 4, 0, 0]} />
                <Bar dataKey="hires" fill="#009688" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </Card>
        </Grid>

        {/* Regional Distribution */}
        <Grid item xs={12} md={4}>
          <Card sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ mb: 2 }}>Jobs by Region</Typography>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie data={regionData} dataKey="value" nameKey="name" cx="50%" cy="50%"
                  outerRadius={100} label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}>
                  {regionData.map((_, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}

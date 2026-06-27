import { Typography, Box, Grid, Card, CardContent } from '@mui/material';
import {
  LineChart, Line, BarChart, Bar, XAxis, YAxis,
  CartesianGrid, Tooltip, ResponsiveContainer,
} from 'recharts';

const userGrowth = [
  { month: 'Jan', users: 120 }, { month: 'Feb', users: 280 },
  { month: 'Mar', users: 520 }, { month: 'Apr', users: 890 },
  { month: 'May', users: 1450 }, { month: 'Jun', users: 2100 },
];

const topSpecializations = [
  { name: 'General Dentistry', count: 340 },
  { name: 'Orthodontics', count: 180 },
  { name: 'Endodontics', count: 120 },
  { name: 'Oral Surgery', count: 95 },
  { name: 'Pediatric', count: 72 },
];

export default function Analytics() {
  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>Analytics</Typography>
      <Grid container spacing={3}>
        <Grid item xs={12} md={7}>
          <Card sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ mb: 2 }}>User Growth</Typography>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={userGrowth}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip />
                <Line type="monotone" dataKey="users" stroke="#1565C0" strokeWidth={3} dot={{ r: 5 }} />
              </LineChart>
            </ResponsiveContainer>
          </Card>
        </Grid>
        <Grid item xs={12} md={5}>
          <Card sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ mb: 2 }}>Top Specializations</Typography>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={topSpecializations} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis type="number" />
                <YAxis dataKey="name" type="category" width={120} />
                <Tooltip />
                <Bar dataKey="count" fill="#009688" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}

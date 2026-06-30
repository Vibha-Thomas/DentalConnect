import { Card, CardContent, Typography, Box, Chip } from '@mui/material';
import { TrendingUp, TrendingDown } from '@mui/icons-material';
import { LineChart, Line, ResponsiveContainer } from 'recharts';

export default function KpiCard({ title, value, change, isPositive, icon, color, sparklineData }) {
  return (
    <Card sx={{
      position: 'relative',
      overflow: 'hidden',
      transition: 'transform 0.2s, box-shadow 0.2s',
      '&:hover': {
        transform: 'translateY(-4px)',
        boxShadow: '0 12px 20px -10px rgba(0,0,0,0.3)',
      }
    }}>
      <CardContent sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Box sx={{
            width: 44,
            height: 44,
            borderRadius: 3,
            bgcolor: `${color}15`,
            color: color,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}>
            {icon}
          </Box>
          <Chip
            icon={isPositive ? <TrendingUp style={{ color: '#10B981', fontSize: 16 }} /> : <TrendingDown style={{ color: '#EF4444', fontSize: 16 }} />}
            label={`${change}%`}
            size="small"
            sx={{
              bgcolor: isPositive ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)',
              color: isPositive ? '#10B981' : '#EF4444',
              fontWeight: 700,
              border: 'none',
              '& .MuiChip-icon': { ml: 0.5 }
            }}
          />
        </Box>

        <Box>
          <Typography variant="body2" sx={{ color: 'text.secondary', fontWeight: 500, mb: 0.5 }}>
            {title}
          </Typography>
          <Typography variant="h4" sx={{ fontWeight: 800 }}>
            {value}
          </Typography>
        </Box>

        {sparklineData && (
          <Box sx={{ height: 40, width: '100%', mt: 1 }}>
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={sparklineData}>
                <Line
                  type="monotone"
                  dataKey="value"
                  stroke={color}
                  strokeWidth={2}
                  dot={false}
                />
              </LineChart>
            </ResponsiveContainer>
          </Box>
        )}
      </CardContent>
    </Card>
  );
}

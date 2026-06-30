import { Box, Typography, Avatar, Divider } from '@mui/material';
import { FiberManualRecord } from '@mui/icons-material';

export default function ActivityFeed({ activities }) {
  if (!activities || activities.length === 0) {
    return (
      <Box sx={{ py: 4, textAlign: 'center', color: 'text.secondary' }}>
        No recent activity.
      </Box>
    );
  }

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2.5 }}>
      {activities.map((act, index) => (
        <Box key={act.id || index} sx={{ display: 'flex', gap: 2 }}>
          <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
            <Avatar sx={{
              width: 32,
              height: 32,
              bgcolor: 'primary.main',
              fontSize: '0.85rem',
              fontWeight: 600,
            }}>
              {act.actorName ? act.actorName.charAt(0) : 'U'}
            </Avatar>
            {index < activities.length - 1 && (
              <Box sx={{ width: 2, flexGrow: 1, bgcolor: 'divider', my: 1 }} />
            )}
          </Box>
          <Box sx={{ flexGrow: 1, pt: 0.5 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                {act.description || act.action}
              </Typography>
              <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                {new Date(act.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
              </Typography>
            </Box>
            <Typography variant="body2" sx={{ color: 'text.secondary' }}>
              By {act.actorName || 'System'} • {act.ipAddress || 'Internal'}
            </Typography>
          </Box>
        </Box>
      ))}
    </Box>
  );
}

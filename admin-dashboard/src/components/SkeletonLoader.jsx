import { Grid, Card, CardContent, Skeleton, Box } from '@mui/material';

export default function SkeletonLoader({ type = 'kpis' }) {
  if (type === 'kpis') {
    return (
      <Grid container spacing={3}>
        {[1, 2, 3, 4].map((i) => (
          <Grid item xs={12} sm={6} md={3} key={i}>
            <Card>
              <CardContent sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Skeleton variant="rectangular" width={44} height={44} sx={{ borderRadius: 3 }} />
                  <Skeleton variant="rounded" width={60} height={24} />
                </Box>
                <Box>
                  <Skeleton variant="text" width="60%" />
                  <Skeleton variant="text" width="40%" height={32} />
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>
    );
  }

  if (type === 'charts') {
    return (
      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <Card sx={{ p: 3 }}>
            <Skeleton variant="text" width="30%" height={32} sx={{ mb: 2 }} />
            <Skeleton variant="rectangular" height={300} sx={{ borderRadius: 2 }} />
          </Card>
        </Grid>
        <Grid item xs={12} md={4}>
          <Card sx={{ p: 3 }}>
            <Skeleton variant="text" width="50%" height={32} sx={{ mb: 2 }} />
            <Skeleton variant="circular" width={200} height={200} sx={{ mx: 'auto', my: 2 }} />
          </Card>
        </Grid>
      </Grid>
    );
  }

  return (
    <Card sx={{ p: 3 }}>
      <Skeleton variant="text" width="20%" height={32} sx={{ mb: 3 }} />
      {[1, 2, 3, 4, 5].map((i) => (
        <Skeleton key={i} variant="rectangular" height={50} sx={{ mb: 1.5, borderRadius: 1.5 }} />
      ))}
    </Card>
  );
}

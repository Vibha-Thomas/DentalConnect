import { Typography, Box, Button, Stack } from '@mui/material';
import { Download } from '@mui/icons-material';

export default function Reports() {
  const handleExport = (format) => {
    // TODO: Call backend /api/v1/admin/reports/export?format=csv|xlsx
    alert(`Exporting as ${format}...`);
  };

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>Reports</Typography>
      <Stack direction="row" spacing={2} sx={{ mb: 3 }}>
        <Button variant="contained" startIcon={<Download />}
          onClick={() => handleExport('csv')}>
          Export CSV
        </Button>
        <Button variant="outlined" startIcon={<Download />}
          onClick={() => handleExport('xlsx')}>
          Export Excel
        </Button>
      </Stack>
      <Box sx={{ p: 4, bgcolor: 'white', borderRadius: 2, textAlign: 'center' }}>
        <Typography color="text.secondary">
          Select report type and date range to generate reports.
        </Typography>
      </Box>
    </Box>
  );
}

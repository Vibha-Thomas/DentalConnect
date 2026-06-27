import { createTheme } from '@mui/material';

const theme = createTheme({
  palette: {
    primary: { main: '#1565C0', dark: '#0D47A1', light: '#42A5F5' },
    secondary: { main: '#009688' },
    background: { default: '#F5F7FA', paper: '#FFFFFF' },
    text: { primary: '#1A1A2E', secondary: '#6B7280' },
    success: { main: '#388E3C' },
    warning: { main: '#F57C00' },
    error: { main: '#D32F2F' },
  },
  typography: {
    fontFamily: '"Inter", sans-serif',
    h4: { fontWeight: 700 },
    h5: { fontWeight: 600 },
    h6: { fontWeight: 600 },
  },
  shape: { borderRadius: 12 },
  components: {
    MuiCard: {
      styleOverrides: {
        root: { borderRadius: 16, boxShadow: '0 1px 3px rgba(0,0,0,0.08)' },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: { textTransform: 'none', fontWeight: 600, borderRadius: 10 },
      },
    },
  },
});

export default theme;

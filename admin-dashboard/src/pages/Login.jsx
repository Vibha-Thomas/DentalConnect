import { useState } from 'react';
import { Box, Card, TextField, Button, Typography, Alert, CircularProgress, Container } from '@mui/material';
import { useNavigate } from 'react-router-dom';
import useAuthStore from '../store/authStore';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const { login, error, loading } = useAuthStore();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    const success = await login(email, password);
    if (success) {
      navigate('/dashboard');
    }
  };

  return (
    <Box sx={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      bgcolor: '#0F172A', // Premium slate/dark background
      background: 'radial-gradient(circle at top right, rgba(30, 64, 175, 0.15), transparent), radial-gradient(circle at bottom left, rgba(56, 189, 248, 0.1), transparent)',
    }}>
      <Container maxWidth="xs">
        <Card sx={{
          p: 4,
          borderRadius: 4,
          bgcolor: 'rgba(30, 41, 59, 0.7)',
          backdropFilter: 'blur(16px)',
          border: '1px solid rgba(255, 255, 255, 0.08)',
          boxShadow: '0 20px 25px -5px rgb(0 0 0 / 0.5), 0 8px 10px -6px rgb(0 0 0 / 0.5)',
        }}>
          <Box sx={{ textAlign: 'center', mb: 4 }}>
            <Typography variant="h4" sx={{ fontWeight: 800, color: '#38BDF8', mb: 1, letterSpacing: '-0.025em' }}>
              DentConnect
            </Typography>
            <Typography variant="body2" sx={{ color: '#94A3B8' }}>
              Enterprise Admin Portal
            </Typography>
          </Box>

          {error && <Alert severity="error" sx={{ mb: 3, borderRadius: 2 }}>{error}</Alert>}

          <form onSubmit={handleSubmit}>
            <TextField
              fullWidth
              label="Admin Email"
              type="email"
              variant="outlined"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              sx={{
                mb: 2.5,
                '& .MuiOutlinedInput-root': {
                  color: 'white',
                  '& fieldset': { borderColor: 'rgba(255, 255, 255, 0.1)' },
                  '&:hover fieldset': { borderColor: '#38BDF8' },
                  '&.Mui-focused fieldset': { borderColor: '#1E40AF' },
                },
                '& .MuiInputLabel-root': { color: '#94A3B8' },
              }}
            />
            <TextField
              fullWidth
              label="Password"
              type="password"
              variant="outlined"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              sx={{
                mb: 3.5,
                '& .MuiOutlinedInput-root': {
                  color: 'white',
                  '& fieldset': { borderColor: 'rgba(255, 255, 255, 0.1)' },
                  '&:hover fieldset': { borderColor: '#38BDF8' },
                  '&.Mui-focused fieldset': { borderColor: '#1E40AF' },
                },
                '& .MuiInputLabel-root': { color: '#94A3B8' },
              }}
            />
            <Button
              type="submit"
              fullWidth
              variant="contained"
              disabled={loading}
              sx={{
                py: 1.5,
                borderRadius: 2.5,
                bgcolor: '#1E40AF',
                '&:hover': { bgcolor: '#1D4ED8' },
                fontWeight: 600,
                textTransform: 'none',
                boxShadow: '0 4px 6px -1px rgba(30, 64, 175, 0.2)',
              }}
            >
              {loading ? <CircularProgress size={24} color="inherit" /> : 'Sign In to Portal'}
            </Button>
          </form>
        </Card>
      </Container>
    </Box>
  );
}

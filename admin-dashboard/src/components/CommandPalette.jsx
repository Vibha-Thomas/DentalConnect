import { useState, useEffect } from 'react';
import { Dialog, Box, InputBase, List, ListItemButton, ListItemText, Typography, Divider } from '@mui/material';
import { Search, People, Business, Work, Description } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import adminApi from '../api/adminApi';

export default function CommandPalette() {
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const navigate = useNavigate();

  // Listen for Ctrl+K
  useEffect(() => {
    const handleKeyDown = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        setOpen((prev) => !prev);
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  // Fetch search results
  useEffect(() => {
    if (query.trim().length < 2) {
      setResults([]);
      return;
    }
    const delayDebounce = setTimeout(async () => {
      try {
        const response = await adminApi.get(`/admin/search?q=${query}`);
        setResults(response.data.data || []);
      } catch (err) {
        console.error('Global search error:', err);
      }
    }, 300);

    return () => clearTimeout(delayDebounce);
  }, [query]);

  const handleSelect = (result) => {
    setOpen(false);
    setQuery('');
    setResults([]);
    
    // Route mapping
    switch (result.type) {
      case 'DENTIST':
        navigate(`/users?dentistId=${result.id}`);
        break;
      case 'CLINIC':
        navigate(`/clinics?clinicId=${result.id}`);
        break;
      case 'JOB':
        navigate(`/jobs?jobId=${result.id}`);
        break;
      case 'APPLICATION':
        navigate(`/reports?applicationId=${result.id}`);
        break;
      default:
        break;
    }
  };

  const getIcon = (type) => {
    switch (type) {
      case 'DENTIST': return <People sx={{ color: '#38BDF8' }} />;
      case 'CLINIC': return <Business sx={{ color: '#10B981' }} />;
      case 'JOB': return <Work sx={{ color: '#F59E0B' }} />;
      default: return <Description sx={{ color: '#EC4899' }} />;
    }
  };

  return (
    <Dialog
      open={open}
      onClose={() => { setOpen(false); setQuery(''); setResults([]); }}
      fullWidth
      maxWidth="sm"
      PaperProps={{
        sx: {
          bgcolor: 'rgba(30, 41, 59, 0.95)',
          backdropFilter: 'blur(16px)',
          border: '1px solid rgba(255, 255, 255, 0.08)',
          borderRadius: 4,
          boxShadow: '0 25px 50px -12px rgb(0 0 0 / 0.5)',
          color: 'white',
          p: 0,
        }
      }}
    >
      <Box sx={{ display: 'flex', alignItems: 'center', p: 2, gap: 1.5 }}>
        <Search sx={{ color: '#94A3B8' }} />
        <InputBase
          fullWidth
          placeholder="Search dentists, clinics, jobs, applications... (Ctrl+K)"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          autoFocus
          sx={{ color: 'white', fontSize: '1.1rem' }}
        />
        <Typography variant="caption" sx={{ bgcolor: 'rgba(255,255,255,0.08)', px: 1, py: 0.5, borderRadius: 1.5, color: '#94A3B8' }}>
          ESC
        </Typography>
      </Box>
      <Divider sx={{ borderColor: 'rgba(255,255,255,0.08)' }} />
      <Box sx={{ maxHeight: 350, overflowY: 'auto', p: 1 }}>
        {results.length > 0 ? (
          <List>
            {results.map((res) => (
              <ListItemButton
                key={res.id}
                onClick={() => handleSelect(res)}
                sx={{ borderRadius: 2, mb: 0.5, gap: 2, '&:hover': { bgcolor: 'rgba(255,255,255,0.05)' } }}
              >
                {getIcon(res.type)}
                <ListItemText
                  primary={res.title}
                  secondary={res.subtitle}
                  primaryTypographyProps={{ sx: { fontWeight: 600, color: 'white' } }}
                  secondaryTypographyProps={{ sx: { color: '#94A3B8' } }}
                />
                <Typography variant="caption" sx={{ color: '#94A3B8', textTransform: 'capitalize' }}>
                  {res.type.toLowerCase()}
                </Typography>
              </ListItemButton>
            ))}
          </List>
        ) : query.trim().length >= 2 ? (
          <Box sx={{ py: 6, textAlign: 'center', color: '#94A3B8' }}>
            No results found for "{query}"
          </Box>
        ) : (
          <Box sx={{ py: 3, px: 2, textAlign: 'center', color: '#94A3B8' }}>
            Type at least 2 characters to search...
          </Box>
        )}
      </Box>
    </Dialog>
  );
}

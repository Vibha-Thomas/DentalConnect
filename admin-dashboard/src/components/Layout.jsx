import { useState } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import {
  Box, Drawer, AppBar, Toolbar, Typography, List, ListItemButton,
  ListItemIcon, ListItemText, IconButton, Avatar, Chip, Divider,
  ThemeProvider, CssBaseline, Tooltip, Badge
} from '@mui/material';
import {
  Dashboard, Work, Business, People, BarChart,
  Assessment, Menu as MenuIcon, Notifications,
  LightMode, DarkMode, Search, Settings, Logout
} from '@mui/icons-material';
import { getAppTheme } from '../theme';
import useAuthStore from '../store/authStore';
import CommandPalette from './CommandPalette';

const DRAWER_WIDTH = 280;

const menuGroups = [
  {
    title: 'Platform',
    items: [
      { text: 'Overview', icon: <Dashboard />, path: '/dashboard' },
      { text: 'Analytics', icon: <BarChart />, path: '/analytics' },
    ]
  },
  {
    title: 'Management',
    items: [
      { text: 'Verification Queue', icon: <Business />, path: '/clinics' },
      { text: 'Dentist Roster', icon: <People />, path: '/users' },
      { text: 'Job Moderation', icon: <Work />, path: '/jobs' },
    ]
  },
  {
    title: 'System',
    items: [
      { text: 'Audit Logs', icon: <Assessment />, path: '/reports' },
    ]
  }
];

export default function Layout() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const [themeMode, setThemeMode] = useState(localStorage.getItem('theme_mode') || 'dark');
  const { user, logout } = useAuthStore();
  const navigate = useNavigate();
  const location = useLocation();

  const handleThemeToggle = () => {
    const newMode = themeMode === 'light' ? 'dark' : 'light';
    setThemeMode(newMode);
    localStorage.setItem('theme_mode', newMode);
  };

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const currentTheme = getAppTheme(themeMode);
  const isDark = themeMode === 'dark';

  const drawer = (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      {/* Brand Header */}
      <Toolbar sx={{ px: 3, py: 2, display: 'flex', alignItems: 'center', gap: 1.5 }}>
        <Typography variant="h5" sx={{
          fontWeight: 850,
          background: 'linear-gradient(45deg, #38BDF8 30%, #3B82F6 90%)',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent',
          letterSpacing: '-0.03em',
        }}>
          🦷 DentalConnect
        </Typography>
      </Toolbar>
      <Divider sx={{ borderColor: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)' }} />

      {/* Nav Groups */}
      <Box sx={{ flexGrow: 1, px: 2, py: 3, overflowY: 'auto' }}>
        {menuGroups.map((group) => (
          <Box key={group.title} sx={{ mb: 4 }}>
            <Typography variant="caption" sx={{
              px: 1.5,
              fontWeight: 700,
              textTransform: 'uppercase',
              color: isDark ? '#475569' : '#94A3B8',
              letterSpacing: '0.05em',
              display: 'block',
              mb: 1
            }}>
              {group.title}
            </Typography>
            <List disablePadding>
              {group.items.map((item) => {
                const isSelected = location.pathname === item.path;
                return (
                  <ListItemButton
                    key={item.text}
                    onClick={() => { navigate(item.path); setMobileOpen(false); }}
                    sx={{
                      borderRadius: 3,
                      mb: 0.5,
                      px: 2,
                      py: 1.25,
                      color: isSelected ? 'primary.main' : 'text.secondary',
                      bgcolor: isSelected ? (isDark ? 'rgba(56, 189, 248, 0.08)' : 'rgba(2, 132, 199, 0.06)') : 'transparent',
                      '&:hover': {
                        bgcolor: isDark ? 'rgba(255,255,255,0.02)' : 'rgba(0,0,0,0.02)',
                        color: 'text.primary',
                      },
                    }}
                  >
                    <ListItemIcon sx={{
                      minWidth: 36,
                      color: isSelected ? 'primary.main' : 'text.secondary',
                    }}>
                      {item.icon}
                    </ListItemIcon>
                    <ListItemText primary={item.text} primaryTypographyProps={{ sx: { fontWeight: isSelected ? 700 : 500 } }} />
                  </ListItemButton>
                );
              })}
            </List>
          </Box>
        ))}
      </Box>

      {/* Admin User Section Footer */}
      <Box sx={{ p: 2, borderTop: isDark ? '1px solid rgba(255,255,255,0.06)' : '1px solid rgba(0,0,0,0.06)' }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, p: 1.5, borderRadius: 3, bgcolor: isDark ? 'rgba(255,255,255,0.02)' : 'rgba(0,0,0,0.02)' }}>
          <Avatar sx={{ bgcolor: 'primary.main', width: 40, height: 40, fontWeight: 700, color: '#0F172A' }}>
            {user?.displayName ? user.displayName.charAt(0) : 'A'}
          </Avatar>
          <Box sx={{ flexGrow: 1, minWidth: 0 }}>
            <Typography variant="subtitle2" sx={{ fontWeight: 700, noWrap: true, textOverflow: 'ellipsis', overflow: 'hidden' }}>
              {user?.displayName || 'Super Admin'}
            </Typography>
            <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block' }}>
              {user?.role === 'SUPER_ADMIN' ? 'Super Administrator' : 'Regional Admin'}
            </Typography>
          </Box>
          <IconButton onClick={handleLogout} size="small" sx={{ color: 'error.main' }}>
            <Logout fontSize="small" />
          </IconButton>
        </Box>
      </Box>
    </Box>
  );

  return (
    <ThemeProvider theme={currentTheme}>
      <CssBaseline />
      <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: 'background.default' }}>
        {/* Sidebar Desktop */}
        <Drawer
          variant="permanent"
          sx={{
            width: DRAWER_WIDTH,
            flexShrink: 0,
            display: { xs: 'none', md: 'block' },
            '& .MuiDrawer-paper': { width: DRAWER_WIDTH, borderBox: 'border-box' },
          }}
        >
          {drawer}
        </Drawer>

        {/* Sidebar Mobile */}
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={() => setMobileOpen(false)}
          sx={{
            display: { xs: 'block', md: 'none' },
            '& .MuiDrawer-paper': { width: DRAWER_WIDTH, borderBox: 'border-box' },
          }}
        >
          {drawer}
        </Drawer>

        {/* Main Content Area */}
        <Box sx={{ flexGrow: 1, minWidth: 0, display: 'flex', flexDirection: 'column' }}>
          {/* Top Bar */}
          <AppBar position="sticky" color="inherit" elevation={0} sx={{
            bgcolor: 'background.default',
            borderBottom: isDark ? '1px solid rgba(255, 255, 255, 0.05)' : '1px solid rgba(0, 0, 0, 0.06)',
            backdropFilter: 'blur(8px)',
          }}>
            <Toolbar sx={{ px: { xs: 2, md: 4 } }}>
              <IconButton onClick={() => setMobileOpen(true)} sx={{ display: { md: 'none' }, mr: 1, color: 'text.primary' }}>
                <MenuIcon />
              </IconButton>

              {/* Ctrl+K Search Shortcut Banner */}
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, color: 'text.secondary', bgcolor: isDark ? 'rgba(255,255,255,0.03)' : 'rgba(0,0,0,0.03)', px: 2, py: 0.75, borderRadius: 2.5 }}>
                <Search fontSize="small" />
                <Typography variant="body2" sx={{ display: { xs: 'none', sm: 'inline' } }}>Press Ctrl + K to search system</Typography>
                <Chip label="Ctrl K" size="small" variant="outlined" sx={{ height: 20, fontSize: '0.7rem', color: 'text.secondary', borderColor: 'divider' }} />
              </Box>

              <Box sx={{ flexGrow: 1 }} />

              {/* Action Buttons */}
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Tooltip title="Toggle Theme">
                  <IconButton onClick={handleThemeToggle} color="inherit">
                    {isDark ? <LightMode /> : <DarkMode />}
                  </IconButton>
                </Tooltip>

                <IconButton color="inherit">
                  <Badge color="error" variant="dot">
                    <Notifications />
                  </Badge>
                </IconButton>
              </Box>
            </Toolbar>
          </AppBar>

          {/* Sub-page Content */}
          <Box sx={{ p: { xs: 2, md: 4 }, flexGrow: 1 }}>
            <Outlet />
          </Box>
        </Box>
      </Box>

      {/* Global Command Palette dialog */}
      <CommandPalette />
    </ThemeProvider>
  );
}

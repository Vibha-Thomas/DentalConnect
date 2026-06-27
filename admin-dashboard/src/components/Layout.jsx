import { useState } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import {
  Box, Drawer, AppBar, Toolbar, Typography, List, ListItemButton,
  ListItemIcon, ListItemText, IconButton, Avatar, Chip, Divider,
} from '@mui/material';
import {
  Dashboard, Work, Business, People, BarChart,
  Assessment, Menu as MenuIcon, Notifications,
} from '@mui/icons-material';

const DRAWER_WIDTH = 260;

const menuItems = [
  { text: 'Dashboard', icon: <Dashboard />, path: '/dashboard' },
  { text: 'Job Moderation', icon: <Work />, path: '/jobs' },
  { text: 'Clinic Verification', icon: <Business />, path: '/clinics' },
  { text: 'User Management', icon: <People />, path: '/users' },
  { text: 'Analytics', icon: <BarChart />, path: '/analytics' },
  { text: 'Reports', icon: <Assessment />, path: '/reports' },
];

export default function Layout() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const drawer = (
    <Box>
      <Toolbar sx={{ gap: 1 }}>
        <Typography variant="h6" sx={{ fontWeight: 700, color: 'primary.main' }}>
          🦷 DentConnect
        </Typography>
      </Toolbar>
      <Divider />
      <Box sx={{ px: 2, py: 1.5 }}>
        <Chip label="Super Admin" color="primary" size="small" />
      </Box>
      <List>
        {menuItems.map((item) => (
          <ListItemButton
            key={item.text}
            selected={location.pathname === item.path}
            onClick={() => navigate(item.path)}
            sx={{
              mx: 1, borderRadius: 2, mb: 0.5,
              '&.Mui-selected': {
                bgcolor: 'primary.main',
                color: 'white',
                '& .MuiListItemIcon-root': { color: 'white' },
                '&:hover': { bgcolor: 'primary.dark' },
              },
            }}
          >
            <ListItemIcon sx={{ minWidth: 40 }}>{item.icon}</ListItemIcon>
            <ListItemText primary={item.text} />
          </ListItemButton>
        ))}
      </List>
    </Box>
  );

  return (
    <Box sx={{ display: 'flex' }}>
      {/* Sidebar */}
      <Drawer
        variant="permanent"
        sx={{
          width: DRAWER_WIDTH,
          flexShrink: 0,
          display: { xs: 'none', md: 'block' },
          '& .MuiDrawer-paper': { width: DRAWER_WIDTH, borderRight: '1px solid #E5E7EB' },
        }}
      >
        {drawer}
      </Drawer>

      {/* Mobile drawer */}
      <Drawer
        variant="temporary"
        open={mobileOpen}
        onClose={() => setMobileOpen(false)}
        sx={{ display: { xs: 'block', md: 'none' }, '& .MuiDrawer-paper': { width: DRAWER_WIDTH } }}
      >
        {drawer}
      </Drawer>

      {/* Main content */}
      <Box sx={{ flexGrow: 1, minHeight: '100vh', bgcolor: 'background.default' }}>
        <AppBar position="sticky" color="inherit" elevation={0}
          sx={{ borderBottom: '1px solid #E5E7EB', ml: { md: `${DRAWER_WIDTH}px` } }}>
          <Toolbar>
            <IconButton onClick={() => setMobileOpen(true)} sx={{ display: { md: 'none' }, mr: 1 }}>
              <MenuIcon />
            </IconButton>
            <Box sx={{ flexGrow: 1 }} />
            <IconButton><Notifications /></IconButton>
            <Avatar sx={{ ml: 1, bgcolor: 'primary.main', width: 36, height: 36 }}>A</Avatar>
          </Toolbar>
        </AppBar>

        <Box sx={{ p: 3 }}>
          <Outlet />
        </Box>
      </Box>
    </Box>
  );
}

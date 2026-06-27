import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Welcome to',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const Text(
                'DentConnect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you\'d like to continue',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 60),
              _RoleCard(
                title: 'I\'m a Dentist',
                subtitle: 'Find jobs, apply to clinics,\nand grow your career',
                icon: Icons.medical_services_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => context.go('/login?role=DENTIST'),
              ),
              const SizedBox(height: 20),
              _RoleCard(
                title: 'I\'m a Clinic',
                subtitle: 'Post jobs, find dentists,\nand build your team',
                icon: Icons.business_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00695C), Color(0xFF00897B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => context.go('/login?role=CLINIC_OWNER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

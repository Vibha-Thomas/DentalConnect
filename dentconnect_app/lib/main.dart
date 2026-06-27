import 'package:flutter/material.dart';

void main() {
  runApp(const DentConnectApp());
}

class DentConnectApp extends StatelessWidget {
  const DentConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DentConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
        fontFamily: 'sans-serif',
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

// ── SPLASH ────────────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _slideCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    _fadeCtrl.forward();
    _slideCtrl.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Center(
                      child: Text('🦷', style: TextStyle(fontSize: 52)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'DentConnect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dental Recruitment Platform',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── ROLE SELECTION ────────────────────────────────────────────────────────────
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Welcome to\nDentConnect',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The dental recruitment platform for India',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'I am a...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                emoji: '🦷',
                title: 'Junior Dentist',
                subtitle: 'Find verified dental jobs near you',
                color: const Color(0xFF1565C0),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen(role: 'dentist')),
                ),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                emoji: '🏥',
                title: 'Clinic / Employer',
                subtitle: 'Post jobs and find qualified dentists',
                color: const Color(0xFF009688),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen(role: 'clinic')),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Trusted by 500+ dental professionals',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.color.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: widget.color)),
                    const SizedBox(height: 3),
                    Text(widget.subtitle,
                        style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: widget.color),
            ],
          ),
        ),
      ),
    );
  }
}

// ── LOGIN ─────────────────────────────────────────────────────────────────────
class LoginScreen extends StatelessWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isDentist = role == 'dentist';
    final color = isDentist ? const Color(0xFF1565C0) : const Color(0xFF009688);

    return Scaffold(
      appBar: AppBar(
        title: Text(isDentist ? 'Dentist Login' : 'Clinic Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Sign In', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Continue with Google, Phone, or Email', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              // Google Sign In
              _SocialButton(
                icon: '🌐',
                label: 'Continue with Google',
                onTap: () => _goHome(context, isDentist),
              ),
              const SizedBox(height: 12),
              _SocialButton(
                icon: '📱',
                label: 'Continue with Phone OTP',
                onTap: () => _goHome(context, isDentist),
              ),
              const SizedBox(height: 32),

              // Divider
              Row(children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or use email', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ]),
              const SizedBox(height: 24),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _goHome(context, isDentist),
                  child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Don't have an account? Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goHome(BuildContext context, bool isDentist) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isDentist ? const DentistHomeScreen() : const ClinicHomeScreen(),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _SocialButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── DENTIST HOME ──────────────────────────────────────────────────────────────
class DentistHomeScreen extends StatefulWidget {
  const DentistHomeScreen({super.key});
  @override
  State<DentistHomeScreen> createState() => _DentistHomeScreenState();
}

class _DentistHomeScreenState extends State<DentistHomeScreen> {
  int _index = 0;

  final _screens = const [
    _JobFeedScreen(),
    _MyApplicationsScreen(),
    _DentistProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Applied'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── JOB FEED ─────────────────────────────────────────────────────────────────
class _JobFeedScreen extends StatefulWidget {
  const _JobFeedScreen();

  @override
  State<_JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<_JobFeedScreen> {
  final _search = TextEditingController();
  String _filter = 'All';
  final _filters = ['All', 'Full-Time', 'Part-Time', 'Locum', 'Internship'];

  final _jobs = const [
    _Job('Associate Dentist', 'Smile Dental Clinic', 'Bangalore', '₹40,000–60,000', 'Full-Time', '0–2 yrs', true),
    _Job('Orthodontist', 'Bright Teeth Centre', 'Chennai', '₹80,000–1,20,000', 'Full-Time', '3–5 yrs', true),
    _Job('Locum Dentist', 'Care Dental Clinic', 'Hyderabad', '₹3,000/day', 'Locum', '1+ yrs', false),
    _Job('Dental Intern', 'City Dental Hospital', 'Mumbai', '₹15,000–20,000', 'Internship', 'Fresher', true),
    _Job('Pediatric Dentist', 'Kids Smile Clinic', 'Pune', '₹70,000–90,000', 'Full-Time', '2+ yrs', true),
    _Job('Dental Surgeon', 'Apollo Dental', 'Delhi', '₹1,00,000–1,50,000', 'Full-Time', '5+ yrs', true),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _jobs.where((j) {
      final matchSearch = _search.text.isEmpty ||
          j.title.toLowerCase().contains(_search.text.toLowerCase()) ||
          j.clinic.toLowerCase().contains(_search.text.toLowerCase()) ||
          j.city.toLowerCase().contains(_search.text.toLowerCase());
      final matchFilter = _filter == 'All' || j.type == _filter;
      return matchSearch && matchFilter;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          title: const Text('Find Jobs', style: TextStyle(fontWeight: FontWeight.w700)),
          actions: [
            IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search jobs, clinics, cities...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final selected = _filter == f;
                return FilterChip(
                  label: Text(f),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: const Color(0xFF1565C0),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight: FontWeight.w500,
                  ),
                  checkmarkColor: Colors.white,
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _JobCard(job: filtered[i]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _Job {
  final String title, clinic, city, salary, type, experience;
  final bool verified;
  const _Job(this.title, this.clinic, this.city, this.salary, this.type, this.experience, this.verified);
}

class _JobCard extends StatelessWidget {
  final _Job job;
  const _JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _JobDetailScreen(job: job)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Text('🏥', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(job.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                        if (job.verified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: const Text('✓ Verified', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                      ]),
                      const SizedBox(height: 2),
                      Text(job.clinic, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Tag(Icons.location_on_outlined, job.city),
                _Tag(Icons.currency_rupee_outlined, job.salary),
                _Tag(Icons.work_outline, job.type),
                _Tag(Icons.timeline_outlined, job.experience),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat, size: 16),
                label: const Text('WhatsApp'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF25D366),
                  side: const BorderSide(color: Color(0xFF25D366)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showApplyDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showApplyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apply for ${job.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(job.clinic, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Cover letter (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Applied to ${job.title} at ${job.clinic}! ✓'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: const Text('Submit Application', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ── JOB DETAIL ────────────────────────────────────────────────────────────────
class _JobDetailScreen extends StatelessWidget {
  final _Job job;
  const _JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(child: Text('🏥', style: TextStyle(fontSize: 64))),
              ),
              title: Text(job.title, style: const TextStyle(color: Colors.white)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(job.clinic, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(job.city, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 12),
                  if (job.verified)
                    const Row(children: [
                      Icon(Icons.verified, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Verified Clinic', style: TextStyle(color: Colors.green, fontSize: 13)),
                    ]),
                ]),
                const SizedBox(height: 20),
                _DetailSection('Job Details', [
                  _DetailRow('Type', job.type),
                  _DetailRow('Experience', job.experience),
                  _DetailRow('Salary', job.salary),
                  _DetailRow('Interview', 'In-person / Online'),
                  _DetailRow('Openings', '2 positions'),
                ]),
                const SizedBox(height: 20),
                _DetailSection('About the Role', const []),
                const SizedBox(height: 8),
                const Text(
                  'We are looking for a skilled and passionate dentist to join our growing practice. '
                  'You will be responsible for diagnosing dental conditions, performing procedures, '
                  'and maintaining exceptional patient care standards.\n\n'
                  'This is a great opportunity to grow your career in a professional, '
                  'well-equipped clinic with experienced mentors.',
                  style: TextStyle(color: Colors.grey, height: 1.6),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Text('💬', style: TextStyle(fontSize: 18)),
                label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF25D366),
                  side: const BorderSide(color: Color(0xFF25D366)),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                child: const Text('Apply Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;
  const _DetailSection(this.title, this.rows);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        if (rows.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: rows),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── MY APPLICATIONS ───────────────────────────────────────────────────────────
class _MyApplicationsScreen extends StatelessWidget {
  const _MyApplicationsScreen();

  @override
  Widget build(BuildContext context) {
    final apps = [
      ('Associate Dentist', 'Smile Dental', 'Shortlisted', Colors.orange),
      ('Orthodontist', 'Bright Teeth', 'Under Review', Colors.blue),
      ('Dental Intern', 'City Hospital', 'Applied', Colors.grey),
    ];

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text('My Applications', style: TextStyle(fontWeight: FontWeight.w700)),
          floating: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList.separated(
            itemCount: apps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final (title, clinic, status, color) = apps[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text(clinic, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    // Timeline dots
                    Row(
                      children: ['Applied', 'Viewed', 'Shortlisted', 'Interview', 'Offer']
                          .asMap()
                          .entries
                          .map((e) {
                        final done = e.key <= (status == 'Applied' ? 0 : status == 'Under Review' ? 1 : 2);
                        return Expanded(
                          child: Row(children: [
                            Container(
                              width: 16, height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done ? color : Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            if (e.key < 4) Expanded(child: Container(height: 2, color: done ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.15))),
                          ]),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── DENTIST PROFILE ───────────────────────────────────────────────────────────
class _DentistProfileScreen extends StatelessWidget {
  const _DentistProfileScreen();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          actions: [IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {})],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const CircleAvatar(radius: 40, backgroundColor: Colors.white24, child: Text('👩‍⚕️', style: TextStyle(fontSize: 40))),
                  const SizedBox(height: 10),
                  const Text('Dr. Priya Kumar', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  Text('BDS • 2 years exp', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _ProfileSection('Skills', Wrap(
                spacing: 8, runSpacing: 8,
                children: ['General Dentistry', 'Root Canal', 'Orthodontics', 'Scaling', 'Bleaching']
                    .map((s) => Chip(label: Text(s), padding: const EdgeInsets.symmetric(horizontal: 4)))
                    .toList(),
              )),
              const SizedBox(height: 16),
              _ProfileSection('Preferences', Column(
                children: [
                  _DetailRow('Expected Salary', '₹40,000–60,000/month'),
                  _DetailRow('Availability', 'Immediate'),
                  _DetailRow('Preferred Cities', 'Bangalore, Hyderabad'),
                  _DetailRow('Languages', 'English, Hindi, Kannada'),
                ],
              )),
              const SizedBox(height: 16),
              _ProfileSection('Education', const Column(
                children: [
                  _DetailRow('Degree', 'BDS'),
                  _DetailRow('Institution', 'RGUHS Bangalore'),
                  _DetailRow('Year', '2022'),
                ],
              )),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _ProfileSection(this.title, this.child);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// ── CLINIC HOME ───────────────────────────────────────────────────────────────
class ClinicHomeScreen extends StatefulWidget {
  const ClinicHomeScreen({super.key});
  @override
  State<ClinicHomeScreen> createState() => _ClinicHomeScreenState();
}

class _ClinicHomeScreenState extends State<ClinicHomeScreen> {
  int _index = 0;

  final _screens = const [_ClinicDashboard(), _ClinicJobsScreen(), _ClinicProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'My Jobs'),
          NavigationDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: 'Clinic'),
        ],
      ),
    );
  }
}

class _ClinicDashboard extends StatelessWidget {
  const _ClinicDashboard();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text('Clinic Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
          floating: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _StatRow([
                _StatTile('Active Jobs', '3', Icons.work, const Color(0xFF1565C0)),
                _StatTile('Total Applicants', '24', Icons.people, const Color(0xFF009688)),
              ]),
              const SizedBox(height: 12),
              _StatRow([
                _StatTile('Shortlisted', '7', Icons.star, Colors.orange),
                _StatTile('Interviews', '3', Icons.calendar_today, Colors.purple),
              ]),
              const SizedBox(height: 24),
              const Text('Recent Applicants', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...['Dr. Priya Kumar', 'Dr. Arjun Mehta', 'Dr. Sneha Patel'].map((name) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: CircleAvatar(child: Text(name[3], style: const TextStyle(fontWeight: FontWeight.bold))),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Applied for Associate Dentist'),
                    trailing: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        side: const BorderSide(color: Color(0xFF25D366)),
                        foregroundColor: const Color(0xFF25D366),
                      ),
                      child: const Text('WhatsApp'),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final List<_StatTile> tiles;
  const _StatRow(this.tiles);
  @override
  Widget build(BuildContext context) => Row(
    children: tiles.map((t) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: t))).toList(),
  );
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatTile(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ClinicJobsScreen extends StatelessWidget {
  const _ClinicJobsScreen();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('My Jobs — Coming in Slice 4', style: TextStyle(color: Colors.grey)));
  }
}

class _ClinicProfileScreen extends StatelessWidget {
  const _ClinicProfileScreen();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Clinic Profile — Coming in Slice 4', style: TextStyle(color: Colors.grey)));
  }
}

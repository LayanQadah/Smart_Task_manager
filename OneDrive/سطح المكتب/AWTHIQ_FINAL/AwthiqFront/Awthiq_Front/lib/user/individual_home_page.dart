import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';
import '../models/UserModel.dart';
import 'user_profile.dart';
import 'certified_documents_page.dart';
import 'skills_page.dart';
import 'skills_dashboard_page.dart';
import 'employment_history_page.dart';
import '../loginSignin/user_type_screen.dart';

class IndividualHomePage extends StatefulWidget {
  @override
  _IndividualHomePageState createState() => _IndividualHomePageState();
}

class _IndividualHomePageState extends State<IndividualHomePage> {
  int currentIndex = 2;
  int _profileKey = 0;

  void changePage(int index) => setState(() => currentIndex = index);

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: const Text(
                  'هل أنت متأكد من تسجيل الخروج؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4563)),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _dialogBtn('إلغاء', () => Navigator.pop(ctx)),
                  _dialogBtn('نعم', () async {
                    Navigator.pop(ctx);
                    await ApiService.logout();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => UserTypeScreen()),
                        (_) => false,
                      );
                    }
                  }),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
        ),
        child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      UserProfilePage(key: ValueKey(_profileKey)),
      const CertifiedDocumentsPage(),
      HomeContent(onNavigate: changePage),
      const SkillsDashboardPage(),
      const SkillsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF1B4563)),
              onPressed: () => _showLogoutDialog(context),
            ),
            const Text('توثيق سريع، ثقة دائمة.',
                style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 14)),
            Image.asset("assets/awlogo1.png", height: 35),
          ],
        ),
      ),
      body: Stack(children: [HomeBackground(), pages[currentIndex]]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        onTap: (i) => setState(() {
          if (i == 0) _profileKey++;
          currentIndex = i;
        }),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B4563),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'الشهادات'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'اللوحة'),
          BottomNavigationBarItem(icon: Icon(Icons.military_tech), label: 'المهارات'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final Function(int) onNavigate;
  const HomeContent({super.key, required this.onNavigate});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  ProfileModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await ApiService.getProfile();
    if (mounted) setState(() { _profile = profile; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('مرحباً', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                  Text(
                    _loading ? '...' : (_profile?.fullName ?? ''),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF1B4563)),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Container(
                width: 70, height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF6FA8DC)]),
                ),
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 400 ? 2 : 3,
              mainAxisSpacing: 12, crossAxisSpacing: 12,
              childAspectRatio: MediaQuery.of(context).size.width < 400 ? 1.0 : 1.2,
            ),
            children: [
              _buildCard('عدد الشهادات',
                _loading ? '...' : '${_profile?.certificates.length ?? 0}',
                () => widget.onNavigate(1)),
              _buildCard('السجل الوظيفي', 'عرض', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EmploymentHistoryPage()));
              }),
              _buildCard('عدد المهارات',
                _loading ? '...' : '${_profile?.skills.length ?? 0}',
                () => widget.onNavigate(4)),
            ],
          ),
        ),
      ],
    ),
    ),
    );
  }

  Widget _buildCard(String text, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFFBFD8FF), Color(0xFFA7E3D7), Color(0xFF7FA8E6)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFF1B4563)),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B4563)), textAlign: TextAlign.center),
                  const SizedBox(height: 5),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';
import '../loginSignin/user_type_screen.dart';
import 'admin_requests_page.dart';
import 'admin_users_page.dart';
import 'admin_certificates_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await ApiService.getAdminStats();
    if (mounted) setState(() { _stats = s; _loading = false; });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => UserTypeScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.logout, color: Color(0xFF1B4563)), onPressed: _logout),
            const Text('لوحة التحكم', style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 18)),
            Image.asset('assets/awlogo1.png', height: 35),
          ],
        ),
      ),
      body: Stack(
        children: [
          HomeBackground(),
          RefreshIndicator(
            onRefresh: _load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('مرحباً، أدمن', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                  const Text('إحصائيات المنصة', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 20),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildStats(),
                  const SizedBox(height: 28),
                  const Text('الخدمات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                  const SizedBox(height: 14),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final s = _stats ?? {};
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: [
        _statCard('الأفراد',    '${s['individuals'] ?? 0}',    Icons.person,        const Color(0xFF5B8DEF)),
        _statCard('الشركات',    '${s['companies'] ?? 0}',     Icons.business,      const Color(0xFF43C6AC)),
        _statCard('المؤسسات',   '${s['institutions'] ?? 0}',  Icons.school,        const Color(0xFF9B59B6)),
        _statCard('الشهادات',   '${s['certificates'] ?? 0}',  Icons.verified,      const Color(0xFF27AE60)),
        _statCard('طلبات معلقة','${s['pending_requests'] ?? 0}', Icons.pending_actions, const Color(0xFFE74C3C)),
        _statCard('المهارات',   '${s['skills'] ?? 0}',        Icons.emoji_events,  const Color(0xFFF39C12)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _actionCard(
          context,
          icon: Icons.pending_actions,
          title: 'طلبات الشهادات',
          subtitle: 'قبول أو رفض طلبات المستخدمين',
          color: const Color(0xFFE74C3C),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequestsPage())).then((_) => _load()),
        ),
        const SizedBox(height: 14),
        _actionCard(
          context,
          icon: Icons.people_alt,
          title: 'إدارة المستخدمين',
          subtitle: 'عرض جميع حسابات المنصة',
          color: const Color(0xFF5B8DEF),
          badge: (_stats?['pending_approvals'] ?? 0) > 0 ? '${_stats!['pending_approvals']} تنتظر الموافقة' : null,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersPage())).then((_) => _load()),
        ),
        const SizedBox(height: 14),
        _actionCard(
          context,
          icon: Icons.verified,
          title: 'الشهادات الموثقة',
          subtitle: 'عرض الشهادات مع الهاش والصورة',
          color: const Color(0xFF27AE60),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCertificatesPage())),
        ),
      ],
    );
  }

  Widget _actionCard(BuildContext context, {
    required IconData icon, required String title, required String subtitle,
    required Color color, required VoidCallback onTap, String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
        ),
        child: Row(
          children: [
            const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (badge != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Text(badge, style: TextStyle(fontSize: 11, color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 14),
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

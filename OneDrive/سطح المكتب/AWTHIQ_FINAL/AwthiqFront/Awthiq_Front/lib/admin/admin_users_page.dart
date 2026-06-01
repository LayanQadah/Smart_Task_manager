import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> with SingleTickerProviderStateMixin {
  List<dynamic> _users = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;

  // التبويبات: الكل، شركات، أفراد، مؤسسات
  static const _tabs = [
    {'label': 'الكل',      'type': ''},
    {'label': 'شركات',     'type': 'company'},
    {'label': 'أفراد',     'type': 'user'},
    {'label': 'مؤسسات',    'type': 'institution'},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(_filter);
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.getAdminUsers();
    if (mounted) {
      setState(() {
        _users = data;
        _loading = false;
      });
      _filter();
    }
  }

  void _filter() {
    final q    = _searchCtrl.text.toLowerCase();
    final type = _tabs[_tabCtrl.index]['type'] as String;
    setState(() {
      _filtered = _users.where((u) {
        final matchType = type.isEmpty || u['user_type'] == type;
        if (!matchType) return false;
        if (q.isEmpty)  return true;
        final name = (u['name'] ?? '').toLowerCase();
        final uid  = (u['unique_id'] ?? '').toLowerCase();
        return name.contains(q) || uid.contains(q);
      }).toList();
    });
  }

  String _typeLabel(String? t) {
    switch (t) {
      case 'individual':   return 'فرد';
      case 'company':      return 'شركة';
      case 'institution':  return 'مؤسسة';
      default:             return t ?? '';
    }
  }

  Color _typeColor(String? t) {
    switch (t) {
      case 'individual':  return const Color(0xFF5B8DEF);
      case 'company':     return const Color(0xFF43C6AC);
      case 'institution': return const Color(0xFF9B59B6);
      default:            return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('إدارة المستخدمين', style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1B4563)),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: false,
          labelColor: const Color(0xFF1B4563),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          indicatorColor: const Color(0xFF1B4563),
          indicatorWeight: 3,
          tabs: _tabs.map((t) {
            final type  = t['type'] as String;
            final count = type.isEmpty
                ? _users.length
                : _users.where((u) => u['user_type'] == type).length;
            return Tab(text: '${t['label']} ($count)');
          }).toList(),
        ),
      ),
      body: Stack(
        children: [
          HomeBackground(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'بحث بالاسم أو الرقم...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF1B4563)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filtered.isEmpty
                        ? const Center(child: Text('لا يوجد مستخدمون', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _userCard(_filtered[i]),
                            ),
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> u) {
    final type       = u['user_type'] as String?;
    final color      = _typeColor(type);
    final isApproved = u['is_approved'] as bool? ?? true;
    final isPending  = !isApproved && (type == 'company' || type == 'institution');
    return GestureDetector(
      onTap: () => _showUserDetail(u),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isPending ? Border.all(color: Colors.orange.shade300, width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withValues(alpha: 0.13),
                  child: Icon(_typeIcon(type), color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(u['name'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                      const SizedBox(height: 3),
                      Text(u['unique_id'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      if ((u['email'] ?? '').isNotEmpty)
                        Text(u['email'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: Text(_typeLabel(type), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    if (isPending) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Text('معلق', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_back_ios, size: 13, color: Colors.grey),
                  ],
                ),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final id = u['id'] as int?;
                    if (id == null) return;
                    final ok = await ApiService.adminApproveUser(id);
                    if (ok) {
                      _load();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تفعيل الحساب بنجاح'), backgroundColor: Colors.green),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('الموافقة على الحساب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showUserDetail(Map<String, dynamic> u) async {
    final id = u['id'] as int?;
    if (id == null) return;

    // اعرض bottom sheet مع loading
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _UserDetailSheet(userId: id, basicInfo: u),
    );
  }

  IconData _typeIcon(String? t) {
    switch (t) {
      case 'individual':  return Icons.person;
      case 'company':     return Icons.business;
      case 'institution': return Icons.school;
      default:            return Icons.person_outline;
    }
  }
}

// ── Bottom Sheet تفاصيل المستخدم ──────────────────────────────────────────────

class _UserDetailSheet extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> basicInfo;
  const _UserDetailSheet({required this.userId, required this.basicInfo});

  @override
  State<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends State<_UserDetailSheet> {
  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getAdminUserDetail(widget.userId);
    if (mounted) setState(() { _detail = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(scrollCtrl),
      ),
    );
  }

  Widget _buildContent(ScrollController ctrl) {
    final d = _detail ?? widget.basicInfo;
    final certs = (d['certificates'] as List<dynamic>?) ?? [];
    final type = d['user_type'] as String? ?? '';

    return ListView(
      controller: ctrl,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      children: [
        // مقبض السحب
        Center(child: Container(width: 50, height: 5,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
        const SizedBox(height: 20),

        // رأس البطاقة: أيقونة + اسم + نوع
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(d['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                  const SizedBox(height: 4),
                  Text(d['unique_id'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF1B4563).withValues(alpha: 0.1),
              child: Icon(_typeIcon(type), color: const Color(0xFF1B4563), size: 28),
            ),
          ],
        ),
        const Divider(height: 32),

        // البيانات الأساسية
        if ((d['email'] ?? '').isNotEmpty)               _infoRow('البريد الإلكتروني', d['email']),
        if ((d['phone_number'] ?? '').isNotEmpty)         _infoRow('الجوال', d['phone_number']),
        if ((d['national_id'] ?? '').isNotEmpty)          _infoRow('رقم الهوية', d['national_id']),
        if ((d['nationality'] ?? '').isNotEmpty)          _infoRow('الجنسية', d['nationality']),
        // بيانات الشركة / المؤسسة
        if ((d['commercial_registry'] ?? '').isNotEmpty)  _infoRow('السجل التجاري', d['commercial_registry']),
        if ((d['tax_id'] ?? '').isNotEmpty)               _infoRow('الرقم الضريبي', d['tax_id']),
        if ((d['legal_entity_type'] ?? '').isNotEmpty)    _infoRow('نوع الكيان القانوني', d['legal_entity_type']),
        if ((d['manager_name'] ?? '').isNotEmpty)         _infoRow('اسم المدير', d['manager_name']),
        if ((d['address'] ?? '').isNotEmpty)              _infoRow('العنوان', d['address']),
        if ((d['website'] ?? '').isNotEmpty)              _infoRow('الموقع الإلكتروني', d['website']),
        if ((d['date_joined'] ?? '').isNotEmpty)          _infoRow('تاريخ الانضمام', d['date_joined']),
        _infoRow('الحالة', (d['is_approved'] as bool? ?? true) ? 'مفعّل' : 'معلق'),

        const SizedBox(height: 20),

        // قسم الشهادات
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF27AE60).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Text('${certs.length}', style: const TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const Text('الشهادات الموثقة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
          ],
        ),
        const SizedBox(height: 12),

        if (certs.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('لا توجد شهادات بعد', style: TextStyle(color: Colors.grey)),
          ))
        else
          ...certs.map((c) => _certCard(c as Map<String, dynamic>)),
      ],
    );
  }

  Widget _certCard(Map<String, dynamic> c) {
    final imageUrl = c['image'] as String? ?? '';
    final fileUrl  = c['file_url'] as String? ?? '';
    final hash     = c['certificate_hash'] as String? ?? '';

    return GestureDetector(
      onTap: () => _showCertDetail(c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1B4563).withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            // صورة الشهادة أو أيقونة PDF
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, width: 64, height: 64, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _certPlaceholder())
                  : fileUrl.isNotEmpty
                      ? Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                        )
                      : _certPlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(c['title'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                  if ((c['issuer_name'] ?? '').isNotEmpty)
                    Text(c['issuer_name'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(c['issue_date'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (hash.isNotEmpty)
                    Text(
                      hash.length > 18 ? '${hash.substring(0, 18)}...' : hash,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF1B4563), fontFamily: 'monospace'),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_back_ios, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _certPlaceholder() {
    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(color: const Color(0xFF1B4563).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.verified, color: Color(0xFF1B4563), size: 28),
    );
  }

  void _showCertDetail(Map<String, dynamic> c) {
    final imageUrl = c['image'] as String? ?? '';
    final fileUrl  = c['file_url'] as String? ?? '';
    final hash     = c['certificate_hash'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(24),
            children: [
              Center(child: Container(width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              if (imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (fileUrl.isNotEmpty) ...[
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(fileUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red, size: 22),
                        SizedBox(width: 8),
                        Text('فتح ملف الشهادة (PDF)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(c['title'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4563)),
                  textAlign: TextAlign.center),
              const Divider(height: 28),
              if ((c['issuer_name'] ?? '').isNotEmpty) _infoRow('الجهة المانحة', c['issuer_name']),
              if ((c['major'] ?? '').isNotEmpty) _infoRow('التخصص', c['major']),
              _infoRow('تاريخ الإصدار', c['issue_date'] ?? ''),
              if (hash.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('هاش البلوكشين', style: TextStyle(fontSize: 13, color: Colors.grey), textAlign: TextAlign.right),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: hash));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ الهاش'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.copy, size: 15, color: Color(0xFF1B4563)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(hash,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF1B4563), fontFamily: 'monospace'),
                          textDirection: TextDirection.ltr)),
                    ]),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
                  ),
                  child: const Center(child: Text('رجوع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87))),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  IconData _typeIcon(String? t) {
    switch (t) {
      case 'individual':  return Icons.person;
      case 'company':     return Icons.business;
      case 'institution': return Icons.school;
      default:            return Icons.person_outline;
    }
  }
}

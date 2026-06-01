import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';

class AdminCertificatesPage extends StatefulWidget {
  const AdminCertificatesPage({super.key});

  @override
  State<AdminCertificatesPage> createState() => _AdminCertificatesPageState();
}

class _AdminCertificatesPageState extends State<AdminCertificatesPage> {
  List<dynamic> _certs = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _deleteCertificate(int id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد الحذف', textAlign: TextAlign.right, style: TextStyle(fontSize: 16)),
        content: Text('هل أنت متأكد من حذف شهادة "$title"؟\nلا يمكن التراجع عن هذا الإجراء.',
            textAlign: TextAlign.right, style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await ApiService.adminDeleteCertificate(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'تم حذف الشهادة بنجاح' : 'حدث خطأ أثناء الحذف'),
          backgroundColor: ok ? Colors.red.shade700 : Colors.grey,
        ));
        if (ok) _load();
      }
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.getAdminCertificates();
    if (mounted) {
      setState(() {
        _certs = data;
        _filtered = data;
        _loading = false;
      });
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _certs
          : _certs.where((c) {
              final title      = (c['title'] ?? '').toLowerCase();
              final userName   = (c['user_name'] ?? '').toLowerCase();
              final userId     = (c['user_id'] ?? '').toLowerCase();
              final issuerName = (c['issuer_name'] ?? '').toLowerCase();
              return title.contains(q) || userName.contains(q) || userId.contains(q) || issuerName.contains(q);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('الشهادات الموثقة', style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1B4563)),
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
                    hintText: 'بحث بالاسم أو المستخدم أو الجهة...',
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
                        ? const Center(child: Text('لا توجد شهادات', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _certCard(_filtered[i]),
                            ),
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _certCard(Map<String, dynamic> c) {
    final hash    = c['certificate_hash'] as String? ?? '';
    final imageUrl = c['image'] as String? ?? '';

    return GestureDetector(
      onTap: () => _showDetails(c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
        ),
        child: Row(
          children: [
            // صورة الشهادة أو أيقونة
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _certIcon())
                  : _certIcon(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(c['title'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                  const SizedBox(height: 3),
                  if ((c['issuer_name'] ?? '').isNotEmpty)
                    Text(c['issuer_name'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 3),
                  Text('${c['user_name']} · ${c['user_id']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 3),
                  Text(c['issue_date'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (hash.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: hash));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم نسخ الهاش'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF1B4563).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.copy, size: 11, color: Color(0xFF1B4563)),
                            const SizedBox(width: 4),
                            Text(
                              hash.length > 20 ? '${hash.substring(0, 20)}...' : hash,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF1B4563), fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _deleteCertificate(c['id'] as int, c['title'] as String? ?? ''),
                  child: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _certIcon() {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(color: const Color(0xFF1B4563).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.verified, color: Color(0xFF1B4563), size: 28),
    );
  }

  Future<void> _openFile(String url) async {
    final isPdf = url.toLowerCase().contains('.pdf') || url.contains('/raw/upload/');
    final openUrl = isPdf
        ? 'https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}'
        : url;
    final uri = Uri.parse(openUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showDetails(Map<String, dynamic> c) {
    final hash     = c['certificate_hash'] as String? ?? '';
    final imageUrl = c['image'] as String? ?? '';
    final fileUrl  = c['file_url'] as String? ?? '';
    final isPdf    = imageUrl.toLowerCase().contains('.pdf') || imageUrl.contains('/raw/upload/');
    final hasImage = imageUrl.isNotEmpty && !isPdf;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollCtrl) => Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              // صورة الشهادة أو زر PDF
              if (hasImage) ...[
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
              ] else if (isPdf || fileUrl.isNotEmpty) ...[
                GestureDetector(
                  onTap: () => _openFile(isPdf ? imageUrl : fileUrl),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1B4563).withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red, size: 22),
                        SizedBox(width: 8),
                        Text('فتح ملف الشهادة (PDF)', style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4563).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.verified, size: 60, color: Color(0xFF1B4563)),
                      SizedBox(height: 8),
                      Text('شهادة موثقة رقمياً', style: TextStyle(fontSize: 13, color: Color(0xFF1B4563), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(c['title'] ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4563)),
                  textAlign: TextAlign.center),
              const Divider(height: 30),
              if ((c['issuer_name'] ?? '').isNotEmpty) _row('الجهة المانحة', c['issuer_name']),
              if ((c['major'] ?? '').isNotEmpty) _row('التخصص', c['major']),
              _row('تاريخ الإصدار', c['issue_date'] ?? ''),
              _row('المستخدم', '${c['user_name']} (${c['user_id']})'),
              _row('تاريخ الإضافة', c['created_at'] ?? ''),
              const SizedBox(height: 12),
              // الهاش كاملاً مع نسخ
              if (hash.isNotEmpty) ...[
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
                    child: Row(
                      children: [
                        const Icon(Icons.copy, size: 16, color: Color(0xFF1B4563)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(hash,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF1B4563), fontFamily: 'monospace'),
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _deleteCertificate(c['id'] as int, c['title'] as String? ?? '');
                },
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: const Center(child: Text('حذف الشهادة', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold))),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
                  ),
                  child: const Center(child: Text('رجوع', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87))),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}

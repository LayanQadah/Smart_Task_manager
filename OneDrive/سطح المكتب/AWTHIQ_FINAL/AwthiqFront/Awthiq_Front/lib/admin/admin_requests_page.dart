// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';

class AdminRequestsPage extends StatefulWidget {
  const AdminRequestsPage({super.key});

  @override
  State<AdminRequestsPage> createState() => _AdminRequestsPageState();
}

class _AdminRequestsPageState extends State<AdminRequestsPage> {
  List<dynamic> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.getAdminRequests();
    if (mounted) setState(() { _requests = data; _loading = false; });
  }

  Future<void> _approve(int id) async {
    final ok = await ApiService.adminApproveRequest(id);
    _snack(ok ? 'تم قبول الطلب وإنشاء الشهادة' : 'حدث خطأ', ok ? Colors.green : Colors.red);
    if (ok) _load();
  }

  Future<void> _reject(int id, String title) async {
    final ctrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('رفض: $title', textAlign: TextAlign.right, style: const TextStyle(fontSize: 15)),
        content: TextField(
          controller: ctrl,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(hintText: 'سبب الرفض (اختياري)'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('رفض', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await ApiService.adminRejectRequest(id, ctrl.text.trim());
      _snack(ok ? 'تم رفض الطلب' : 'حدث خطأ', ok ? Colors.orange : Colors.red);
      if (ok) _load();
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('طلبات الشهادات', style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1B4563)),
      ),
      body: Stack(
        children: [
          HomeBackground(),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _requests.isEmpty
                  ? const Center(child: Text('لا توجد طلبات معلقة', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _requests.length,
                        itemBuilder: (_, i) => _requestCard(_requests[i]),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(10)),
                child: const Text('معلق', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Text(r['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
            ],
          ),
          const SizedBox(height: 8),
          _row('المستخدم', '${r['user_name']} (${r['user_id']})'),
          _row('الجهة المانحة', r['issuer_name'] ?? ''),
          _row('التخصص', r['major'] ?? ''),
          _row('تاريخ الإصدار', r['issue_date'] ?? ''),
          _row('تاريخ الطلب', r['created_at'] ?? ''),
          _certPreview(r),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _reject(r['id'], r['title'] ?? ''),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: const Center(child: Text('رفض', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _approve(r['id']),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: [Color(0xFF7FA8E6), Color(0xFF1B4563)]),
                    ),
                    child: const Center(child: Text('قبول', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _certPreview(Map<String, dynamic> r) {
    final imageUrl = r['image_url'] as String? ?? '';
    final fileUrl  = r['file_url']  as String? ?? '';

    if (imageUrl.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : const Center(child: CircularProgressIndicator()),
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      );
    }

    if (fileUrl.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: GestureDetector(
          onTap: () {
            final a = html.AnchorElement(href: fileUrl)
              ..setAttribute('target', '_blank')
              ..setAttribute('rel', 'noopener');
            html.document.body!.append(a);
            a.click();
            a.remove();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1B4563).withValues(alpha: 0.2)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('عرض ملف الشهادة (PDF)', style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _row(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          const SizedBox(width: 6),
          Text('$label:', style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

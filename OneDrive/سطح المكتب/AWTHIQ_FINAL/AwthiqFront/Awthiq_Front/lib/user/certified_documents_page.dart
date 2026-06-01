import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/UserModel.dart';
import 'request_certificate_page.dart';

class CertifiedDocumentsPage extends StatefulWidget {
  const CertifiedDocumentsPage({super.key});

  @override
  State<CertifiedDocumentsPage> createState() => _CertifiedDocumentsPageState();
}

class _CertifiedDocumentsPageState extends State<CertifiedDocumentsPage> {
  List<CertificateModel> _certs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final certs = await ApiService.getCertificates();
    if (mounted) setState(() { _certs = certs; _loading = false; });
  }

  Future<void> _openCertFile(String url) async {
    final isPdf = url.toLowerCase().contains('.pdf') || url.contains('/raw/upload/');
    final openUrl = isPdf
        ? 'https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}'
        : url;
    final uri = Uri.parse(openUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestCertificatePage()));
                  _load();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
                  ),
                  child: const Text('طلب شهادة', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
              const Text('شهاداتك الموثقة',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
            ],
          ),
          const SizedBox(height: 10),
          const Text('هنا تجد جميع الشهادات التي تم التحقق منها وتوثيقها',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 25),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF1B4563))))
          else if (_certs.isEmpty)
            const Expanded(child: Center(child: Text('لا توجد شهادات موثقة بعد', style: TextStyle(color: Color(0xFF1B4563)))))
          else
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth < 400 ? 2
                          : constraints.maxWidth < 700 ? 3
                          : constraints.maxWidth < 1000 ? 4 : 6;
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: _certs.length,
                        itemBuilder: (_, i) => _buildCard(_certs[i]),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(CertificateModel cert) {
    return GestureDetector(
      onTap: () => _showDetails(cert),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 9, color: Colors.green),
                    SizedBox(width: 2),
                    Text('موثقة', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/awlogo1.png', width: 40, height: 40, fit: BoxFit.contain),
                    const SizedBox(height: 6),
                    Text(cert.issuerName.isNotEmpty ? cert.issuerName : '-',
                        style: const TextStyle(fontSize: 8, color: Colors.grey),
                        textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(cert.title,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1B4563)),
                        textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 9, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(cert.issueDate, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(CertificateModel cert) {
    final imageUrl = cert.image ?? '';
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
              Center(child: Container(width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              if (hasImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(imageUrl, fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),
                const SizedBox(height: 16),
              ] else if (isPdf) ...[
                GestureDetector(
                  onTap: () => _openCertFile(imageUrl),
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
                        Text('فتح ملف الشهادة (PDF)',
                            style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
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
                  child: Column(
                    children: [
                      Image.asset("assets/awlogo1.png", height: 60),
                      const SizedBox(height: 8),
                      const Text('شهادة موثقة رقمياً',
                          style: TextStyle(fontSize: 13, color: Color(0xFF1B4563), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(cert.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4563)),
                  textAlign: TextAlign.center),
              const Divider(height: 40),
              if (cert.major.isNotEmpty) _infoRow('التخصص / الوصف', cert.major),
              if (cert.issuerName.isNotEmpty) _infoRow('الجهة المانحة', cert.issuerName),
              _infoRow('تاريخ الإصدار', cert.issueDate),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity, height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
                  ),
                  child: const Center(child: Text('رجوع', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87))),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

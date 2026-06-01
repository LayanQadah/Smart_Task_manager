import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';
import '../models/UserModel.dart';
import 'edit_company_profile.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  ProfileModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ApiService.getProfile();
    if (mounted) setState(() { _profile = p; _loading = false; });
  }

  void _onAvatarTap() {
    final hasPhoto = _profile?.profilePhoto != null && _profile!.profilePhoto!.isNotEmpty;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF1B4563)),
              title: const Text('اختيار صورة من الجهاز', textAlign: TextAlign.right),
              onTap: () { Navigator.pop(context); _pickPhoto(); },
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('إزالة الصورة', textAlign: TextAlign.right, style: TextStyle(color: Colors.red)),
                onTap: () { Navigator.pop(context); _removePhoto(); },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    final bytes = file.bytes!;
    final name  = file.name;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري رفع الصورة...'), duration: Duration(seconds: 30)),
    );
    final res = await ApiService.updateProfile({}, imageBytes: bytes, imageName: name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (res['success'] == true) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الصورة بنجاح'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'خطأ في رفع الصورة'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _removePhoto() async {
    await ApiService.updateProfile({'remove_photo': 'true'});
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF1B4563)));
    if (_profile == null) return const Center(child: Text('تعذر تحميل بيانات المنشأة'));
    return Stack(
      children: [
        HomeBackground(),
        Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 20),
                _buildCompanyDetails(),
                const SizedBox(height: 30),
                _buildEditButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final p = _profile!;
    final displayName = p.companyName.isNotEmpty ? p.companyName : p.fullName;
    final photoUrl = p.profilePhoto;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _onAvatarTap,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFF0F7FF),
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? const Icon(Icons.business_rounded, size: 55, color: Color(0xFF1B4563))
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Color(0xFF1B4563), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(displayName, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
          const SizedBox(height: 5),
          Text("ID: ${p.uniqueId}",
              style: const TextStyle(color: Color(0xFF7FA8E6), fontWeight: FontWeight.bold)),
          if ((p.legalEntityType ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(p.legalEntityType!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyDetails() {
    final p = _profile!;
    final rows = <_InfoItem>[
      _InfoItem('البريد الرسمي', p.email.isNotEmpty ? p.email : '-', Icons.alternate_email_rounded),
      _InfoItem('رقم الجوال', p.phoneNumber.isNotEmpty ? p.phoneNumber : '-', Icons.phone_outlined),
      _InfoItem('الرقم التعريفي', p.uniqueId, Icons.badge_outlined),
      if ((p.managerName ?? '').isNotEmpty) _InfoItem('المسؤول / المدير', p.managerName!, Icons.person_outline),
      if ((p.address ?? '').isNotEmpty) _InfoItem('العنوان', p.address!, Icons.location_on_outlined),
      if ((p.website ?? '').isNotEmpty) _InfoItem('الموقع الإلكتروني', p.website!, Icons.language_outlined),
      if ((p.commercialRegistry ?? '').isNotEmpty) _InfoItem('السجل التجاري', p.commercialRegistry!, Icons.article_outlined),
      if ((p.taxId ?? '').isNotEmpty) _InfoItem('الرقم الضريبي', p.taxId!, Icons.receipt_long_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _infoRow(rows[i].label, rows[i].value, rows[i].icon),
            if (i < rows.length - 1) const Divider(height: 25),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Text(value, textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        ),
        const SizedBox(width: 15),
        Text(label, style: const TextStyle(color: Color(0xFF1B4563), fontSize: 13)),
        const SizedBox(width: 10),
        Icon(icon, color: const Color(0xFFADCBE3), size: 22),
      ],
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => EditCompanyProfilePage(profile: _profile!)));
        _load();
      },
      child: Container(
        width: 200, height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
          boxShadow: [BoxShadow(color: const Color(0xFF1B4563).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('تعديل بيانات المنشأة',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            SizedBox(width: 10),
            Icon(Icons.edit_note, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label, value;
  final IconData icon;
  _InfoItem(this.label, this.value, this.icon);
}

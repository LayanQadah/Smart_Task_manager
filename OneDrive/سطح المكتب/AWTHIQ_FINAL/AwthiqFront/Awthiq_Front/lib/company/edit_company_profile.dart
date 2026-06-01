import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';
import '../models/UserModel.dart';

class EditCompanyProfilePage extends StatefulWidget {
  final ProfileModel profile;
  const EditCompanyProfilePage({super.key, required this.profile});

  @override
  State<EditCompanyProfilePage> createState() => _EditCompanyProfilePageState();
}

class _EditCompanyProfilePageState extends State<EditCompanyProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _managerCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _legalTypeCtrl;
  late TextEditingController _taxIdCtrl;

  Uint8List? _photoBytes;
  String?    _photoName;
  bool       _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameCtrl    = TextEditingController(text: p.companyName.isNotEmpty ? p.companyName : p.fullName);
    _emailCtrl   = TextEditingController(text: p.email);
    _phoneCtrl   = TextEditingController(text: p.phoneNumber);
    _managerCtrl = TextEditingController(text: p.managerName ?? '');
    _addressCtrl = TextEditingController(text: p.address ?? '');
    _websiteCtrl = TextEditingController(text: p.website ?? '');
    _legalTypeCtrl = TextEditingController(text: p.legalEntityType ?? '');
    _taxIdCtrl   = TextEditingController(text: p.taxId ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _managerCtrl.dispose(); _addressCtrl.dispose(); _websiteCtrl.dispose();
    _legalTypeCtrl.dispose(); _taxIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    if (mounted) setState(() { _photoBytes = file.bytes!; _photoName = file.name; });
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final data = <String, String>{
      'company_name':      _nameCtrl.text.trim(),
      'email':             _emailCtrl.text.trim(),
      'phone_number':      _phoneCtrl.text.trim(),
      'manager_name':      _managerCtrl.text.trim(),
      'address':           _addressCtrl.text.trim(),
      'website':           _websiteCtrl.text.trim(),
      'legal_entity_type': _legalTypeCtrl.text.trim(),
      'tax_id':            _taxIdCtrl.text.trim(),
    };
    final res = await ApiService.updateProfile(
      data,
      imageBytes: _photoBytes,
      imageName:  _photoName,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث بيانات المنشأة بنجاح'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'خطأ في التحديث'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPhoto = widget.profile.profilePhoto;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('تعديل بيانات المنشأة',
            style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          HomeBackground(),
          Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFF0F7FF),
                          backgroundImage: _photoBytes != null
                              ? MemoryImage(_photoBytes!)
                              : (currentPhoto != null && currentPhoto.isNotEmpty)
                                  ? NetworkImage(currentPhoto) as ImageProvider
                                  : null,
                          child: (_photoBytes == null && (currentPhoto == null || currentPhoto.isEmpty))
                              ? const Icon(Icons.business_rounded, size: 50, color: Color(0xFF1B4563))
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Color(0xFF1B4563), shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('اضغط لتغيير الصورة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 24),

                  _field('اسم المنشأة', _nameCtrl),
                  _field('البريد الإلكتروني الرسمي', _emailCtrl, keyboardType: TextInputType.emailAddress),
                  _field('رقم الجوال', _phoneCtrl, keyboardType: TextInputType.phone),
                  _field('اسم المسؤول / المدير', _managerCtrl),
                  _field('العنوان', _addressCtrl),
                  _field('الموقع الإلكتروني', _websiteCtrl, keyboardType: TextInputType.url, hint: 'https://example.com'),
                  _field('نوع الكيان القانوني', _legalTypeCtrl, hint: 'مثال: شركة ذات مسؤولية محدودة'),
                  _field('الرقم الضريبي', _taxIdCtrl),

                  if ((widget.profile.commercialRegistry ?? '').isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('السجل التجاري',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(widget.profile.commercialRegistry!,
                                textAlign: TextAlign.right,
                                style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ),
                          const SizedBox(height: 4),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text('لا يمكن تعديل السجل التجاري',
                                style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isLoading ? null : _save,
                    child: Container(
                      width: double.infinity, height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(height: 22, width: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('حفظ التغييرات',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType? keyboardType, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            textAlign: TextAlign.right,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFADCBE3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

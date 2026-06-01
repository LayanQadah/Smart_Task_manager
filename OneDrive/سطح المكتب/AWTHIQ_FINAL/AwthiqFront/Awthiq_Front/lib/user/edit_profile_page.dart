import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';
import '../models/UserModel.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileModel profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isLoading = false;

  Uint8List? _imageBytes;
  String?    _imageName;

  @override
  void initState() {
    super.initState();
    _firstNameController  = TextEditingController(text: widget.profile.firstName);
    _middleNameController = TextEditingController(text: widget.profile.middleName);
    _lastNameController   = TextEditingController(text: widget.profile.lastName);
    _emailController      = TextEditingController(text: widget.profile.email);
    _phoneController      = TextEditingController(text: widget.profile.phoneNumber);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
    if (mounted) setState(() { _imageBytes = file.bytes!; _imageName = file.name; });
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final result = await ApiService.updateProfile(
      {
        'first_name':   _firstNameController.text.trim(),
        'middle_name':  _middleNameController.text.trim(),
        'last_name':    _lastNameController.text.trim(),
        'email':        _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
      },
      imageBytes: _imageBytes,
      imageName:  _imageName,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحفظ بنجاح'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'خطأ في الحفظ'), backgroundColor: Colors.red),
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
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B4563)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('تعديل الملف الشخصي',
                style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 15),
            Image.asset("assets/awlogo1.png", height: 35),
          ],
        ),
      ),
      body: Stack(
        children: [
          HomeBackground(),
          Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF6FA8DC)]),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10)],
                            ),
                            child: ClipOval(
                              child: _imageBytes != null
                                  ? Image.memory(_imageBytes!, fit: BoxFit.cover, width: 100, height: 100)
                                  : (currentPhoto != null && currentPhoto.isNotEmpty)
                                      ? Image.network(currentPhoto, fit: BoxFit.cover, width: 100, height: 100,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 55, color: Colors.white))
                                      : const Icon(Icons.person, size: 55, color: Colors.white),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(color: Color(0xFF1B4563), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('اضغط لتغيير الصورة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          _buildField('الاسم الأول',  _firstNameController),
                          _buildField('اسم الأب', _middleNameController),
                          _buildField('اسم العائلة',   _lastNameController),
                          _buildField('البريد الإلكتروني',  _emailController),
                          _buildField('رقم الجوال',  _phoneController),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1B4563)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text('إلغاء', style: TextStyle(color: Color(0xFF1B4563))),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF7FA8E6), Color(0xFF1B4563)]),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: _isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('حفظ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF7FA8E6), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

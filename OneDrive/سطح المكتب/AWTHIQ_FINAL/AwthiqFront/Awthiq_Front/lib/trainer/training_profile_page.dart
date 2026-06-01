import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/UserModel.dart';

class TrainingProfilePage extends StatefulWidget {
  const TrainingProfilePage({super.key});

  @override
  State<TrainingProfilePage> createState() => _TrainingProfilePageState();
}

class _TrainingProfilePageState extends State<TrainingProfilePage> {
  ProfileModel? _profile;
  bool _loading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController  = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await ApiService.getProfile();
    if (mounted) {
      setState(() {
        _profile = p;
        _loading = false;
        if (p != null) {
          _nameController.text  = p.companyName.isNotEmpty ? p.companyName : p.fullName;
          _emailController.text = p.email;
          _phoneController.text = p.phoneNumber;
        }
      });
    }
  }

  Future<void> _saveUpdates() async {
    setState(() => _isSaving = true);
    final res = await ApiService.updateProfile({
      'company_name': _nameController.text.trim(),
      'email':        _emailController.text.trim(),
      'phone_number': _phoneController.text.trim(),
    });
    setState(() => _isSaving = false);
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث البيانات بنجاح', textAlign: TextAlign.right), backgroundColor: Colors.green),
      );
      setState(() => _isEditing = false);
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'خطأ في التحديث'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF1B4563)));
    if (_profile == null) return const Center(child: Text('تعذر تحميل بيانات المؤسسة'));

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 25),
          _isEditing ? _buildEditForm() : _buildDetailsCard(),
          const SizedBox(height: 40),
          _buildActionButton(),
        ],
      ),
      ),
    );
  }

  Widget _buildHeader() {
    final name = _profile!.companyName.isNotEmpty ? _profile!.companyName : _profile!.fullName;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFF0F7FF),
            child: Icon(Icons.school_rounded, size: 60, color: Color(0xFF1B4563)),
          ),
          const SizedBox(height: 15),
          Text(name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
          Text("ID: ${_profile!.uniqueId}",
              style: const TextStyle(color: Color(0xFF7FA8E6), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          _row('البريد:', _profile!.email.isNotEmpty ? _profile!.email : '-'),
          const Divider(),
          _row('الجوال:', _profile!.phoneNumber.isNotEmpty ? _profile!.phoneNumber : '-'),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          _editField('اسم المؤسسة', _nameController),
          const SizedBox(height: 10),
          _editField('البريد الإلكتروني', _emailController),
          const SizedBox(height: 10),
          _editField('رقم الجوال', _phoneController),
        ],
      ),
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        TextField(controller: controller, textAlign: TextAlign.right),
      ],
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: _isSaving ? null : (_isEditing ? _saveUpdates : () => setState(() => _isEditing = true)),
      child: Container(
        width: 220, height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  _isEditing ? 'حفظ التغييرات' : 'تعديل بيانات المؤسسة',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Color(0xFF1B4563))),
        ],
      ),
    );
  }
}

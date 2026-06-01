import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/UserModel.dart';
import 'edit_profile_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  ProfileModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getProfile();
    if (mounted) setState(() { _profile = profile; _loading = false; });
  }

  void _onAvatarTap(String? currentPhoto) {
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
            if (currentPhoto != null && currentPhoto.isNotEmpty)
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
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري رفع الصورة...'), duration: Duration(seconds: 30)),
    );
    final res = await ApiService.updateProfile({}, imageBytes: file.bytes!, imageName: file.name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (res['success'] == true) {
      _loadProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الصورة'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'خطأ في الرفع'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _removePhoto() async {
    final res = await ApiService.updateProfile({'remove_photo': 'true'});
    if (!mounted) return;
    if (res['success'] == true) {
      _loadProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إزالة الصورة'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1B4563)));
    }
    if (_profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('تعذر تحميل البيانات'),
            TextButton(onPressed: _loadProfile, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
    }

    final p = _profile!;
    final currentJob = p.careerHistory.where((j) => j.endDate == null).firstOrNull;

    return Scrollbar(
      thumbVisibility: true,
      child: RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // ── رأس الملف الشخصي ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(p.fullName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                      Text(p.uniqueId,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(width: 15),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                    onTap: () => _onAvatarTap(p.profilePhoto),
                    borderRadius: BorderRadius.circular(40),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF6FA8DC)]),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: ClipOval(
                            child: (p.profilePhoto != null && p.profilePhoto!.isNotEmpty)
                                ? Image.network(p.profilePhoto!, fit: BoxFit.cover, width: 80, height: 80,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50, color: Colors.white))
                                : const Icon(Icons.person, size: 50, color: Colors.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Color(0xFF1B4563), shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfilePage(profile: p)));
                    _loadProfile();
                  },
                  icon: const Icon(Icons.edit, size: 18, color: Color(0xFF7FA8E6)),
                  label: const Text('تعديل المعلومات الشخصية',
                      style: TextStyle(color: Color(0xFF7FA8E6), fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),

              // ── البيانات الأساسية ──
              _card(children: [
                _infoRow('الاسم الكامل', p.fullName),
                _divider(),
                _infoRow('رقم الهوية', p.nationalId),
                if (p.nationality.isNotEmpty) ...[
                  _divider(),
                  _infoRow('الجنسية', p.nationality),
                ],
                _divider(),
                _infoRow('البريد الإلكتروني', p.email),
                _divider(),
                _infoRow('رقم الجوال', p.phoneNumber),
                if (currentJob != null) ...[
                  _divider(),
                  _infoRow('المسمى الوظيفي', currentJob.jobTitle),
                  _divider(),
                  _infoRow('جهة العمل', currentJob.companyName),
                ],
              ]),

              const SizedBox(height: 12),

              // ── الحالة الوظيفية ──
              _jobStatusCard(p.jobStatus),

              const SizedBox(height: 18),

              // ── إحصائيات ──
              _card(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('عدد المهارات', '${p.skills.length}', Icons.star_border_rounded),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _statItem('عدد الشهادات', '${p.certificates.length}', Icons.workspace_premium_outlined),
                  ],
                ),
              ]),

              const SizedBox(height: 24),

              // ── السجل الوظيفي (مرتب من الأحدث للأقدم) ──
              _SectionWithAdd(
                title: 'السجل الوظيفي',
                icon: Icons.work_outline,
                onAdd: () => _showAddCareerSheet(context),
                child: p.careerHistory.isEmpty
                    ? _emptyHint('لا يوجد سجل وظيفي بعد')
                    : Column(
                        children: ([...p.careerHistory]
                          ..sort((a, b) {
                            if (a.endDate == null && b.endDate != null) return -1;
                            if (a.endDate != null && b.endDate == null) return 1;
                            return b.startDate.compareTo(a.startDate);
                          }))
                            .map((c) => _careerCard(c)).toList(),
                      ),
              ),

              const SizedBox(height: 18),

              // ── التعليم ──
              _SectionWithAdd(
                title: 'التعليم',
                icon: Icons.school_outlined,
                onAdd: () => _showAddEducationSheet(context),
                child: p.educationHistory.isEmpty
                    ? _emptyHint('لا يوجد سجل تعليمي بعد')
                    : Column(
                        children: p.educationHistory.map((e) => _educationCard(e)).toList(),
                      ),
              ),

              const SizedBox(height: 24),

              // ── تصدير CV ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url = await ApiService.getExportCVUrl(lang: 'ar');
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.print, color: Colors.white),
                  label: const Text('تصدير السيرة الذاتية',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4563),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // ─────────── Career sheet ───────────────────────────────────────────────────

  void _showAddCareerSheet(BuildContext context) {
    final company  = TextEditingController();
    final job      = TextEditingController();
    final start    = TextEditingController();
    final end      = TextEditingController();
    final desc     = TextEditingController();
    bool saving       = false;
    bool isSecondJob  = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('إضافة وظيفة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                const SizedBox(height: 16),
                _sheetField('الشركة / الجهة', company),
                _sheetField('المسمى الوظيفي', job),
                _sheetField('تاريخ البداية (YYYY-MM-DD)', start),
                _sheetField('تاريخ الانتهاء (اتركه فارغاً إن لا يزال)', end),
                _sheetField('وصف (اختياري)', desc, maxLines: 2),
                // خيار العمل الثاني
                InkWell(
                  onTap: () => setS(() => isSecondJob = !isSecondJob),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('هذا عمل ثاني (أبقِ الوظيفة السابقة حالية)',
                            style: TextStyle(fontSize: 13, color: Color(0xFF1B4563))),
                        const SizedBox(width: 8),
                        Checkbox(
                          value: isSecondJob,
                          onChanged: (v) => setS(() => isSecondJob = v ?? false),
                          activeColor: const Color(0xFF1B4563),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4563),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: saving ? null : () async {
                      if (company.text.trim().isEmpty || job.text.trim().isEmpty || start.text.trim().isEmpty) return;
                      setS(() => saving = true);
                      final data = {
                        'company_name':  company.text.trim(),
                        'job_title':     job.text.trim(),
                        'start_date':    start.text.trim(),
                        'is_second_job': isSecondJob.toString(),
                        if (end.text.trim().isNotEmpty) 'end_date': end.text.trim(),
                        if (desc.text.trim().isNotEmpty) 'description': desc.text.trim(),
                      };
                      final res = await ApiService.addCareer(data);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (res['success'] == true) _loadProfile();
                    },
                    child: saving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('حفظ', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────── Edit Career sheet ──────────────────────────────────────────────

  void _showEditCareerSheet(BuildContext context, CareerModel c) {
    final company = TextEditingController(text: c.companyName);
    final job     = TextEditingController(text: c.jobTitle);
    final start   = TextEditingController(text: c.startDate);
    final end     = TextEditingController(text: c.endDate ?? '');
    final desc    = TextEditingController(text: c.description ?? '');
    bool saving   = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('تعديل الوظيفة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                const SizedBox(height: 16),
                _sheetField('الشركة / الجهة', company),
                _sheetField('المسمى الوظيفي', job),
                _sheetField('تاريخ البداية (YYYY-MM-DD)', start),
                _sheetField('تاريخ الانتهاء (اتركه فارغاً إن لا يزال)', end),
                _sheetField('وصف (اختياري)', desc, maxLines: 2),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4563),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: saving ? null : () async {
                      if (company.text.trim().isEmpty || job.text.trim().isEmpty || start.text.trim().isEmpty) return;
                      setS(() => saving = true);
                      final data = <String, String>{
                        'company_name': company.text.trim(),
                        'job_title':    job.text.trim(),
                        'start_date':   start.text.trim(),
                        if (end.text.trim().isNotEmpty) 'end_date': end.text.trim(),
                        if (desc.text.trim().isNotEmpty) 'description': desc.text.trim(),
                      };
                      final res = await ApiService.editCareer(c.id, data);
                      if (!ctx.mounted) return;
                      if (res['success'] == true) {
                        Navigator.pop(ctx);
                        _loadProfile();
                      } else {
                        setS(() => saving = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(res['error'] ?? 'خطأ في التعديل'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: saving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('حفظ التعديلات', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────── Education sheet ────────────────────────────────────────────────

  void _showAddEducationSheet(BuildContext context) {
    final institution = TextEditingController();
    final degree      = TextEditingController();
    final field       = TextEditingController();
    final start       = TextEditingController();
    final end         = TextEditingController();
    bool saving       = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('إضافة مؤهل تعليمي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                const SizedBox(height: 16),
                _sheetField('الجامعة / المدرسة', institution),
                _sheetField('الدرجة العلمية (بكالوريوس، ماجستير...)', degree),
                _sheetField('التخصص (اختياري)', field),
                _sheetField('سنة البداية (YYYY-MM-DD)', start),
                _sheetField('سنة الانتهاء (اتركه فارغاً إن لا يزال)', end),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4563),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: saving ? null : () async {
                      if (institution.text.trim().isEmpty || degree.text.trim().isEmpty || start.text.trim().isEmpty) return;
                      setS(() => saving = true);
                      final data = {
                        'institution':    institution.text.trim(),
                        'degree':         degree.text.trim(),
                        'field_of_study': field.text.trim(),
                        'start_date':     start.text.trim(),
                        if (end.text.trim().isNotEmpty) 'end_date': end.text.trim(),
                      };
                      final res = await ApiService.addEducation(data);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (res['success'] == true) _loadProfile();
                    },
                    child: saving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('حفظ', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────── Cards ──────────────────────────────────────────────────────────

  Widget _careerCard(CareerModel c) {
    final isCurrent = c.endDate == null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7FA8E6).withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!c.addedByCompany) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF7FA8E6), size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showEditCareerSheet(context, c),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
                final ok = await ApiService.deleteCareer(c.id);
                if (ok) _loadProfile();
              },
            ),
          ],
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(c.companyName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
              Text(c.jobTitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              Text(
                isCurrent ? '${c.startDate} – حتى الآن' : '${c.startDate} – ${c.endDate}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCurrent)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                      child: const Text('حالي', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  if (c.addedByCompany)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF1B4563).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                      child: const Text('من الشركة', style: TextStyle(fontSize: 10, color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1B4563).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.work, color: Color(0xFF1B4563), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _jobStatusCard(String? currentStatus) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7FA8E6).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('الحالة الوظيفية',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _statusChip(
                label: 'غير محدد',
                isSelected: currentStatus == null,
                selectedColor: const Color(0xFF1B4563),
                onTap: currentStatus == null ? null : () async {
                  await ApiService.updateProfile({'job_status': ''});
                  _loadProfile();
                },
              ),
              const SizedBox(width: 8),
              _statusChip(
                label: 'موظف',
                isSelected: currentStatus == 'employed',
                selectedColor: Colors.green,
                onTap: currentStatus == 'employed' ? null : () async {
                  await ApiService.updateProfile({'job_status': 'employed'});
                  _loadProfile();
                },
              ),
              const SizedBox(width: 8),
              _statusChip(
                label: 'باحث عن عمل',
                isSelected: currentStatus == 'seeking',
                selectedColor: Colors.orange,
                onTap: currentStatus == 'seeking' ? null : () async {
                  await ApiService.updateProfile({'job_status': 'seeking'});
                  _loadProfile();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip({
    required String label,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? selectedColor : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _educationCard(EducationModel e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7FA8E6).withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
              final ok = await ApiService.deleteEducation(e.id);
              if (ok) _loadProfile();
            },
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(e.degree, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
              Text(e.institution, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              if (e.fieldOfStudy.isNotEmpty)
                Text(e.fieldOfStudy, style: const TextStyle(fontSize: 12, color: Color(0xFF7FA8E6))),
              Text(
                e.endDate == null ? 'منذ ${e.startDate} · حتى الآن' : '${e.startDate} — ${e.endDate}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF9B59B6).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school, color: Color(0xFF9B59B6), size: 18),
          ),
        ],
      ),
    );
  }

  // ─────────── Helpers ────────────────────────────────────────────────────────

  Widget _card({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha:0.9),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(children: children),
  );

  Widget _emptyHint(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
  );

  Widget _sheetField(String hint, TextEditingController c, {int maxLines = 1}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
  );

  Widget _statItem(String label, String value, IconData icon) => Column(
    children: [
      Icon(icon, color: const Color(0xFF7FA8E6), size: 28),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 3),
          Text(value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
        ],
      ),
    ),
  );

  Widget _divider() => Divider(color: Colors.grey.withValues(alpha:0.2), thickness: 1);
}

// ── قسم قابل للإضافة ────────────────────────────────────────────────────────

class _SectionWithAdd extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onAdd;
  final Widget child;

  const _SectionWithAdd({required this.title, required this.icon, required this.onAdd, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF7FA8E6)),
                  label: const Text('إضافة', style: TextStyle(color: Color(0xFF7FA8E6), fontSize: 13)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
                const Spacer(),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                const SizedBox(width: 8),
                Icon(icon, color: const Color(0xFF1B4563), size: 20),
              ],
            ),
          ),
          Divider(color: Colors.grey.withValues(alpha:0.15), thickness: 1, height: 1),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

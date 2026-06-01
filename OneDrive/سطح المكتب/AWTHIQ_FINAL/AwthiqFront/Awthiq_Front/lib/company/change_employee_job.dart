import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';

class ChangeEmployeeJobPage extends StatefulWidget {
  const ChangeEmployeeJobPage({super.key});

  @override
  State<ChangeEmployeeJobPage> createState() => _ChangeEmployeeJobPageState();
}

class _ChangeEmployeeJobPageState extends State<ChangeEmployeeJobPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _newJobController = TextEditingController();

  bool _isSearching = false;
  bool _isUpdating = false;
  Map<String, dynamic>? _employee;
  String? _searchError;

  @override
  void dispose() {
    _idController.dispose();
    _newJobController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    if (_idController.text.trim().isEmpty) return;
    setState(() { _isSearching = true; _employee = null; _searchError = null; });
    final res = await ApiService.searchEmployeeById(_idController.text.trim());
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() { _employee = res['employee']; _isSearching = false; });
    } else {
      setState(() { _searchError = res['error']; _isSearching = false; });
    }
  }

  Future<void> _confirmUpdate() async {
    if (_newJobController.text.trim().isEmpty || _employee == null) return;
    final uid = (_employee!['unique_id'] ?? '').toString();
    setState(() => _isUpdating = true);
    final res = await ApiService.updateEmployeeCareer(uid, _newJobController.text.trim());
    setState(() => _isUpdating = false);
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث المسمى الوظيفي بنجاح'), backgroundColor: Colors.green),
      );
      _newJobController.clear();
      _handleSearch();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'خطأ'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B4563)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('تغيير المسمى الوظيفي',
                style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 10),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSearchBox(),
                if (_isSearching)
                  const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFF1B4563))),
                if (_searchError != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_searchError!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ),
                if (_employee != null) ...[
                  const SizedBox(height: 30),
                  _buildEmployeeHeader(),
                  const SizedBox(height: 20),
                  _buildCurrentJobCard(),
                  _buildEditForm(),
                  const SizedBox(height: 20),
                  _buildHistorySection(),
                ],
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text('الرقم التعريفي للموظف:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextField(
            controller: _idController,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: "AW-XXXXXXX"),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _isSearching ? null : _handleSearch,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
              ),
              child: Center(
                child: _isSearching
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('بحث', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeHeader() {
    final name = _employee!['full_name'] ??
        '${_employee!['first_name'] ?? ''} ${_employee!['last_name'] ?? ''}'.trim();
    final uid = (_employee!['unique_id'] ?? '').toString();
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFFADCBE3),
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
        Text(uid, style: const TextStyle(color: Color(0xFF7FA8E6), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCurrentJobCard() {
    final career = _employee!['career_history'] as List? ?? [];
    final current = career.cast<Map?>().firstWhere((j) => j?['end_date'] == null, orElse: () => null);
    final jobTitle = current?['job_title'] ?? '-';
    final company = current?['company_name'] ?? '-';
    final startDate = current?['start_date'] ?? '-';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF0D3B50), width: 2),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text('الوظيفة الحالية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: Text(jobTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7FA8E6))),
          ),
          Align(alignment: Alignment.centerRight, child: Text(company, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          Align(
            alignment: Alignment.centerRight,
            child: Text('تاريخ الانضمام: $startDate', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text('المسمى الوظيفي الجديد:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          TextField(controller: _newJobController, textAlign: TextAlign.right, decoration: const InputDecoration(isDense: true)),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _isUpdating ? null : _confirmUpdate,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
              ),
              child: Center(
                child: _isUpdating
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('تأكيد التحديث', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    final career = (_employee!['career_history'] as List? ?? [])
      ..sort((a, b) {
        final aEnd = (a as Map)['end_date'];
        final bEnd = (b as Map)['end_date'];
        if (aEnd == null && bEnd != null) return -1;
        if (aEnd != null && bEnd == null) return 1;
        return ((b['start_date'] ?? '') as String).compareTo((a['start_date'] ?? '') as String);
      });
    final prev = career.where((j) => (j as Map?)?['end_date'] != null).toList();
    if (prev.isEmpty) return const SizedBox();
    return Column(
      children: [
        const Text('السجل المهني السابق:', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...prev.map<Widget>((job) {
          final j = job as Map;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(j['job_title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
                    Text(j['company_name'] ?? '', style: const TextStyle(fontSize: 12)),
                    Text('${j['start_date'] ?? ''} – ${j['end_date'] ?? ''}',
                        style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
                  ],
                ),
                const SizedBox(width: 15),
                const Icon(Icons.circle, size: 10, color: Color(0xFF1B4563)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

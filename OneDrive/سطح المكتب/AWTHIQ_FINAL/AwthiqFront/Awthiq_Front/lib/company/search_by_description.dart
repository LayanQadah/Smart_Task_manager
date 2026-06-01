import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import '../services/api_service.dart';
import 'search_by_id.dart';

class SearchByDescriptionPage extends StatefulWidget {
  const SearchByDescriptionPage({super.key});

  @override
  State<SearchByDescriptionPage> createState() => _SearchByDescriptionPageState();
}

class _SearchByDescriptionPageState extends State<SearchByDescriptionPage> {
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> _results = [];
  bool _searched = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSearch() async {
    if (descriptionController.text.trim().isEmpty) return;
    setState(() { isLoading = true; _results = []; _searched = false; });
    final res = await ApiService.searchEmployeesByAI(descriptionController.text.trim());
    if (!mounted) return;
    if (res['success'] == true) {
      final list = res['results'] as List? ?? [];
      setState(() {
        _results = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        isLoading = false;
        _searched = true;
      });
    } else {
      setState(() { isLoading = false; _searched = true; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['error'] ?? 'خطأ في البحث'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B4563)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('وصف الموظف المطلوب',
                style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold, fontSize: 18)),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeaderSearchSection(),
                if (isLoading)
                  const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFF1B4563))),
                if (_searched && !isLoading) _buildResultsContainer(),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSearchSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text(
            'وصف الموظف المطلوب',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B4563)),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: descriptionController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'مبرمج تطبيقات',
                    filled: true,
                    fillColor: const Color(0xFFF0F0F0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Text('اكتب الوصف:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4563))),
            ],
          ),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: _onSearch,
            child: Container(
              width: 150, height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [Color(0xFF8FBDEB), Color(0xFF1B4563)]),
              ),
              child: const Center(child: Text('ابحث', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContainer() {
    if (_results.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 30),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF0D3B50), width: 3),
        ),
        child: const Center(
          child: Text('لم يتم العثور على نتائج', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF0D3B50), width: 3),
      ),
      child: Column(
        children: [
          Text("(${_results.length} نتائج البحث:)",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          ..._results.map((emp) => _buildEmployeeCard(emp)),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> emp) {
    final name = '${emp['first_name'] ?? ''} ${emp['middle_name'] ?? ''} ${emp['last_name'] ?? ''}'.trim().replaceAll(RegExp(r'\s+'), ' ');
    final uid = (emp['unique_id'] ?? emp['id'] ?? '').toString();
    final String? jobStatus = emp['job_status'];
    final isEmployed = jobStatus == 'employed';
    final currentJob = emp['current_job'] ?? '';
    final matchedSkills = (emp['matched_skills'] as List?)?.join(', ') ?? '';
    final matchReason = emp['match_reason'] ?? matchedSkills;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchByIdPage(initialUid: uid)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF0D3B50), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Row(
                      children: [
                        Text(uid, style: const TextStyle(color: Color(0xFF7FA8E6), fontSize: 12)),
                        const SizedBox(width: 5),
                        if (jobStatus != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: isEmployed
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isEmployed ? 'موظف' : 'باحث عن عمل',
                              style: TextStyle(
                                color: isEmployed ? Colors.green : Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFFADCBE3),
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ],
            ),
            if (isEmployed && currentJob.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(currentJob,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87)),
            ],
            if (matchReason.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('سبب التطابق:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF7FA8E6).withValues(alpha: 0.5)),
                      ),
                      child: Text(matchReason,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

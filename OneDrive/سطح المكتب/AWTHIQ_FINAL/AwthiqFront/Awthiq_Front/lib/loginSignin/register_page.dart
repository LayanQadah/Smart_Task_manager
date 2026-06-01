import 'package:flutter/material.dart';
import '../widgets/backgrounds.dart';
import '../widgets/password_rules_widget.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  final String type;
  const RegisterPage({required this.type, super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final List<TextEditingController> _c = List.generate(12, (_) => TextEditingController());
  bool _isLoading = false;

  // فرد:    [0]firstName [1]middleName [2]lastName [3]nationalId [4]email [5]phone [6]pass [7]pass2
  // شركة:   [0]companyName [1]entityType [2]registry [3]taxId [4]address [5]website [6]manager [7]email [8]phone [9]pass [10]pass2

  @override
  void dispose() {
    for (final c in _c) { c.dispose(); }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);

    Map<String, String> data;
    String apiType;

    if (widget.type == 'individual') {
      apiType = 'user';
      data = {
        'first_name':  _c[0].text.trim(),
        'middle_name': _c[1].text.trim(),
        'last_name':   _c[2].text.trim(),
        'national_id': _c[3].text.trim(),
        'email':       _c[4].text.trim(),
        'phone_number': _c[5].text.trim(),
        'password':    _c[6].text,
        'password2':   _c[7].text,
      };
    } else {
      apiType = widget.type == 'company' ? 'company' : 'institution';
      data = {
        'company_name':        _c[0].text.trim(),
        'legal_entity_type':   _c[1].text.trim(),
        'commercial_registry': _c[2].text.trim(),
        'tax_id':              _c[3].text.trim(),
        'address':             _c[4].text.trim(),
        'website':             _c[5].text.trim(),
        'manager_name':        _c[6].text.trim(),
        'email':               _c[7].text.trim(),
        'phone_number':        _c[8].text.trim(),
        'password':            _c[9].text,
        'password2':           _c[10].text,
      };
    }

    final result = await ApiService.register(apiType, data);
    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      await ApiService.clearSession();
      if (!mounted) return;
      final isIndividual = widget.type == 'individual';
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isIndividual ? 'تم إنشاء الحساب بنجاح' : 'طلبك قيد المراجعة',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold),
          ),
          content: Text(
            isIndividual
                ? 'تم إنشاء حسابك بنجاح، يمكنك الآن تسجيل الدخول.'
                : 'تم استلام طلب تسجيل حسابك بنجاح.\nيرجى انتظار توثيق الحساب من مسؤولي النظام.',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.popUntil(context, (r) => r.isFirst);
              },
              child: const Text('حسناً', style: TextStyle(color: Color(0xFF1B4563), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'خطأ في إنشاء الحساب'), backgroundColor: Colors.red),
      );
    }
  }

  bool _validate() {
    final passIndex  = widget.type == 'individual' ? 6 : 9;
    final pass2Index = widget.type == 'individual' ? 7 : 10;
    final lastIndex  = widget.type == 'individual' ? 7 : 10;

    for (int i = 0; i <= lastIndex; i++) {
      if (_c[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تعبئة جميع الحقول'), backgroundColor: Colors.red),
        );
        return false;
      }
    }
    if (!isPasswordValid(_c[passIndex].text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور لا تستوفي الشروط المطلوبة'), backgroundColor: Colors.red),
      );
      return false;
    }
    if (_c[passIndex].text != _c[pass2Index].text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور غير متطابقة'), backgroundColor: Colors.red),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                HomeBackground(),
                Positioned(
                  top: 40, left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset("assets/HandAwthiq.png", width: 250),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        widget.type == "individual"
                            ? 'إنشاء حساب فرد'
                            : widget.type == "company"
                                ? 'إنشاء حساب شركة'
                                : 'إنشاء حساب مؤسسة تدريبية',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 25),

                      if (widget.type == 'individual') ...[
                        _input('الاسم الأول',    _c[0]),
                        _input('اسم الأب',   _c[1]),
                        _input('اسم العائلة',     _c[2]),
                        _input('رقم الهوية',   _c[3]),
                        _input('البريد الإلكتروني',         _c[4]),
                        _input('رقم الجوال',         _c[5]),
                        _password('كلمة المرور',         _c[6]),
                        PasswordRulesWidget(controller: _c[6]),
                        _password('تأكيد كلمة المرور', _c[7]),
                      ] else ...[
                        _input('اسم الجهة',      _c[0]),
                        _input('نوع الكيان',      _c[1]),
                        _input('السجل التجاري',   _c[2]),
                        _input('الرقم الضريبي',       _c[3]),
                        _input('العنوان',          _c[4]),
                        _input('الموقع الإلكتروني',          _c[5]),
                        _input('اسم المدير',     _c[6]),
                        _input('البريد الإلكتروني',            _c[7]),
                        _input('رقم الجوال',            _c[8]),
                        _password('كلمة المرور',      _c[9]),
                        PasswordRulesWidget(controller: _c[9]),
                        _password('تأكيد كلمة المرور', _c[10]),
                      ],

                      const SizedBox(height: 25),
                      GestureDetector(
                        onTap: _isLoading ? null : _register,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xCA90B3FF), Color(0xE017283A)],
                            ),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22, width: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'إنشاء حساب',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _password(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: true,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

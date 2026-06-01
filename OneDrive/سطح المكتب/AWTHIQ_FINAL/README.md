# أوثق — منصة توثيق الشهادات والمهارات

منصة ويب متكاملة تتيح للأفراد توثيق شهاداتهم ومهاراتهم، وللشركات إصدار شهادات موثوقة لموظفيها، ولمؤسسات التدريب إدارة دوراتها وإصدار شهاداتها.

---

## الرابط المباشر

**الفرونت إند (Vercel):** https://web-chi-indol-44.vercel.app  
**الباك إند (Railway):** https://web-production-fd6c6.up.railway.app

---

## هيكل المشروع

```
AWTHIQ_FINAL/
├── AwthiqFront/Awthiq_Front/   ← تطبيق Flutter Web (الواجهة)
│   └── lib/
│       ├── main.dart
│       ├── services/
│       │   └── api_service.dart        ← كل طلبات الـ API
│       ├── models/
│       │   └── UserModel.dart          ← موديلات البيانات
│       ├── widgets/
│       │   ├── backgrounds.dart        ← خلفيات الصفحات
│       │   └── password_rules_widget.dart
│       ├── loginSignin/               ← شاشات الدخول والتسجيل
│       ├── user/                      ← صفحات الفرد
│       ├── company/                   ← صفحات الشركة
│       ├── trainer/                   ← صفحات مؤسسة التدريب
│       └── admin/                     ← لوحة الأدمن
│
└── AwthiqBackEnd/                     ← Django REST Framework (الخادم)
    ├── core/                          ← الإعدادات الرئيسية (settings, urls)
    ├── accounts/                      ← المستخدمون والملفات الشخصية
    ├── certificates/                  ← إصدار الشهادات والبلوكشين
    └── skills/                        ← المهارات وتقييم الذكاء الاصطناعي
```

---

## التقنيات المستخدمة

| الطبقة | التقنية |
|--------|---------|
| الفرونت إند | Flutter Web (Dart) |
| الباك إند | Django 6 + Django REST Framework |
| قاعدة البيانات | PostgreSQL (عبر Railway) |
| تخزين الملفات والصور | Cloudinary |
| المصادقة | Token Authentication (DRF) |
| نشر الفرونت إند | Vercel |
| نشر الباك إند | Railway |

---

## أنواع الحسابات

| النوع | الوصف |
|-------|-------|
| **فرد** (`user`) | يوثق شهاداته، يقيّم مهاراته، يصدّر سيرته الذاتية |
| **شركة** (`company`) | تصدر شهادات لموظفيها، تبحث عن الكفاءات، تضيف موظفين |
| **مؤسسة تدريب** (`institution`) | تنشئ الدورات، تصدر شهادات إتمام للمشاركين |

> الشركات والمؤسسات تحتاج موافقة الأدمن قبل تفعيل الحساب.

---

## المميزات الرئيسية

### للأفراد
- **الملف الشخصي:** اسم، هوية، جوال، بريد، صورة شخصية
- **السجل الوظيفي:** إضافة وتعديل وحذف الوظائف
- **السجل التعليمي:** إضافة المؤهلات والشهادات الأكاديمية
- **الشهادات الموثقة:** عرض الشهادات المصدرة من الشركات والمؤسسات
- **المهارات:** تقييم المهارات بالذكاء الاصطناعي وتصنيفها بميداليات (ذهبي / فضي / برونزي)
- **تصدير السيرة الذاتية:** PDF بالعربية
- **طلب توثيق شهادة:** رفع صورة الشهادة لمراجعتها من فريق أوثق

### للشركات
- **إصدار الشهادات:** فردياً أو جماعياً (Bulk) لعدة موظفين دفعةً واحدة
- **البحث عن الموظفين:** بالرقم التعريفي أو بالذكاء الاصطناعي (وصف طبيعي)
- **إدارة الموظفين:** إضافة وإزالة الموظفين المرتبطين بالشركة
- **تحديث السجل الوظيفي:** إضافة وظيفة لأي موظف مباشرة

### لمؤسسات التدريب
- **إنشاء الدورات:** مع تاريخ بداية ونهاية
- **تسجيل المشاركين:** وربطهم بالدورة
- **إصدار شهادات إتمام**

### لوحة الأدمن
- مراجعة طلبات الشركات والمؤسسات والموافقة أو الرفض
- عرض جميع المستخدمين والشهادات
- حذف الشهادات غير المرغوب فيها
- بروكسي آمن لعرض الملفات المرفوعة

---

## هيكل قاعدة البيانات (الموديلات الرئيسية)

```
User (AbstractUser)
├── user_type: user | company | institution
├── unique_id: AW-XXXXXXXX (توليد تلقائي)
├── profile_photo: URLField (Cloudinary)
├── [حقول الفرد]: national_id, middle_name, nationality
├── [حقول الشركة]: company_name, commercial_registry, tax_id, ...
├── CareerHistory (FK)
├── Education (FK)
└── CompanyEmployee (M2M عبر جدول وسيط)

Certificate
├── user (FK → User)
├── title, issuer_name, issue_date
├── certificate_hash (SHA-256 للتحقق)
├── image (Cloudinary)
└── is_verified: Boolean

SkillMedal
├── user (FK → User)
├── skill_name
├── score (0-100)
├── medal_type: gold | silver | bronze
├── progress_level: beginner | intermediate | advanced | expert
└── ai_feedback: Text (تقييم الذكاء الاصطناعي)

Course
├── trainer (FK → User)
├── name, description
├── start_date, end_date
└── CourseEnrollment (M2M مع User)
```

---

## واجهة الـ API (أهم النقاط)

| النقطة | الطريقة | الوصف |
|--------|---------|-------|
| `/api/auth/register/<type>/` | POST | تسجيل حساب جديد |
| `/api/auth/login/` | POST | تسجيل الدخول |
| `/api/auth/logout/` | POST | تسجيل الخروج |
| `/api/profile/` | GET / PATCH | عرض وتعديل الملف الشخصي مع رفع الصورة |
| `/api/profile/career/` | POST | إضافة وظيفة |
| `/api/profile/education/` | POST | إضافة مؤهل تعليمي |
| `/api/profile/export-cv/` | GET | تصدير السيرة الذاتية PDF |
| `/api/certificates/requests/` | POST | طلب توثيق شهادة |
| `/api/certificates/my/` | GET | شهاداتي الموثقة |
| `/api/certificates/company/issue/` | POST | إصدار شهادة (شركة) |
| `/api/certificates/company/bulk-issue/` | POST | إصدار جماعي |
| `/api/skills/` | GET / POST | المهارات وبدء اختبار |
| `/api/company/search/` | GET | البحث بالرقم التعريفي |
| `/api/company/search/ai/` | POST | البحث بالذكاء الاصطناعي |
| `/api/company/employees/` | GET / POST / DELETE | إدارة الموظفين |

---

## تشغيل المشروع محلياً

### الباك إند

```bash
cd AwthiqBackEnd

# إنشاء بيئة افتراضية
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # Linux/Mac

# تثبيت المتطلبات
pip install -r requirements.txt

# تهيئة قاعدة البيانات
python manage.py migrate

# تشغيل السيرفر
python manage.py runserver
```

**متغيرات البيئة المطلوبة (ملف `.env` أو Railway Variables):**

```
SECRET_KEY=...
DEBUG=False
DATABASE_URL=postgresql://...
CLOUDINARY_CLOUD_NAME=...
CLOUDINARY_API_KEY=...
CLOUDINARY_API_SECRET=...
ANTHROPIC_API_KEY=...        # لتقييم المهارات بالذكاء الاصطناعي
```

### الفرونت إند

```bash
cd AwthiqFront/Awthiq_Front

# تثبيت الحزم
flutter pub get

# تشغيل على المتصفح
flutter run -d chrome

# بناء للنشر
flutter build web --release
```

> **ملاحظة:** تأكد من أن `baseUrl` في `lib/services/api_service.dart` يشير إلى عنوان الباك إند الصحيح.

---

## النشر (Deploy)

### الفرونت إند → Vercel

```bash
flutter build web --release
vercel deploy build/web --prod --yes
```

### الباك إند → Railway

يتم النشر تلقائياً عند الـ push إلى الـ main branch، أو يدوياً من لوحة Railway.

```bash
# تطبيق الـ migrations بعد أي تعديل على الموديلات
python manage.py migrate
```

---

## ملاحظات تقنية مهمة

### رفع الصور في Flutter Web
نستخدم `dart:html` مباشرةً بدلاً من حزمة `file_picker` لأنها تُرجع `bytes=null` أحياناً على المتصفح.  
بعد `readAsArrayBuffer`، النتيجة `ByteBuffer` لا `List<int>`، لذا نتحقق من النوع:

```dart
final buf = reader.result;
final bytes = buf is ByteBuffer
    ? buf.asUint8List()
    : Uint8List.fromList(buf as List<int>);
```

### التحقق من الشهادات (Blockchain-بديل)
كل شهادة تحصل على `certificate_hash` (SHA-256) يمكن التحقق منه عبر:  
`GET /api/certificates/verify/<hash>/`

### تقييم المهارات بالذكاء الاصطناعي
يستخدم Claude API (Anthropic) لتوليد أسئلة اختبار مخصصة حسب المهارة المطلوبة، وتقييم الإجابات وإعطاء ميدالية ومستوى وتقرير تفصيلي.

---

## فريق التطوير

| الاسم | الدور |
|-------|-------|
| لَيَان حمدي قضاه | مطورة Flutter و Django |

---

## الترخيص

هذا المشروع خاص وغير مرخص للنشر العام.

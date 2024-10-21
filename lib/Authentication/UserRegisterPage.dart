// استيراد الحزم اللازمة للتعامل مع Firebase وواجهة المستخدم
import 'package:cloud_firestore/cloud_firestore.dart'; // للتعامل مع Cloud Firestore
import 'package:firebase_auth/firebase_auth.dart'; // للتعامل مع Firebase Auth
import 'package:flutter/material.dart';


// تعريف كلاس UserRegisterPage الذي يمثل صفحة التسجيل في التطبيق
class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({Key? key})
      : super(key: key); // Constructor يقبل مفتاح للويدجت

  @override
  _UserRegisterPageState createState() =>
      _UserRegisterPageState(); // إنشاء الحالة الخاصة بالصفحة
}

enum Gender { male, female }

class _UserRegisterPageState extends State<UserRegisterPage> {
  // تعريف متحكمات النص لإدارة حقول الإدخال
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _confirmPasswordTextEditingController =
      TextEditingController();
  final TextEditingController _phoneNumberTextEditingController =
      TextEditingController();
  final TextEditingController _addressTextEditingController =
      TextEditingController();

  @override
  // تعريف دالة بناء واجهة المستخدم لصفحة التسجيل
  Widget build(BuildContext context) {
    // استخدام Scaffold لتوفير الهيكل الأساسي للصفحة مع AppBar ومنطقة المحتوى
    return Scaffold(
      appBar: AppBar(
        // تخصيص شريط التطبيق باستخدام IconThemeData لتعيين لون الأيقونات
        iconTheme: IconThemeData(color: Jemeel.buttonColor),
        // عنوان الصفحة مع تخصيص اللون
        // title: Text(
        //   "Create User Account",
        //   style: TextStyle(
        //     color: Jemeel.buttonColor,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        // تمكين تمركز العنوان في شريط التطبيق
        centerTitle: true,
      ),
      body: SafeArea(
        // استخدام SafeArea لتجنب العوائق مثل النوتش أو الحواف المنحنية
        child: SingleChildScrollView(
          // السماح بالتمرير في حال كان المحتوى أطول من الشاشة
          child: Container(
            // تعيين هامش حول الحاوية للتباعد
            margin: const EdgeInsets.all(20),
            child: Column(
              // استخدام Column لترتيب العناصر رأسياً
              mainAxisSize: MainAxisSize.max, // استخدام أقصى مساحة ممكنة
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "images/logo2.png", // شعار التطبيق أو الشركة
                      ),
                    ), // عرض الشعار من ملفات الصور
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 45,
                      margin: const EdgeInsets.all(5),
                      child: TextField(
                        controller:
                            _emailTextEditingController, // متحكم نص البريد الإلكتروني
                        cursorColor: Colors.black, // لون المؤشر
                        decoration: InputDecoration(
                          hintText: "Email", // نص الإرشاد للبريد الإلكتروني
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffc8d2d3)),
                          ),
                          isCollapsed: false,
                          isDense: true,
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffc8d2d3)),
                          ),
                          prefixIcon: Icon(Icons.email,
                              color: Jemeel
                                  .buttonColor), // أيقونة البريد الإلكتروني
                        ),
                      ),
                    ),
                    Container(
                      height: 45,
                      margin: const EdgeInsets.all(5),
                      child: TextField(
                        controller:
                            _nameTextEditingController, // متحكم نص الاسم الكامل
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: "Full Name", // نص الإرشاد للإسم
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffc8d2d3)),
                          ),
                          isCollapsed: false,
                          isDense: true,
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffc8d2d3)),
                          ),
                          prefixIcon: Icon(Icons.person,
                              color: Jemeel.buttonColor), // أيقونة الشخص
                        ),
                      ),
                    ),
                    Container(
                      height: 45,
                      margin: const EdgeInsets.all(5),
                      child: TextField(
                        controller:
                            _passwordTextEditingController, // متحكم نص كلمة المرور
                        cursorColor: Colors.black,
                        obscureText: true, // إخفاء النص لكلمة المرور
                        decoration: InputDecoration(
                          hintText: "Password", // نص الإرشاد لكلمة المرور
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffc8d2d3)),
                          ),
                          isCollapsed: false,
                          isDense: true,
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffc8d2d3)),
                          ),
                          prefixIcon: Icon(Icons.lock,
                              color: Jemeel.buttonColor), // أيقونة القفل
                        ),
                      ),
                    ),
                    Container(
                      height: 45,
                      margin: const EdgeInsets.all(5),
                      child: TextField(
                        controller:
                            _confirmPasswordTextEditingController, // متحكم نص تأكيد كلمة المرور
                        cursorColor: Colors.black,
                        obscureText: true, // إخفاء النص لتأكيد كلمة المرور
                        decoration: InputDecoration(
                          hintText:
                              "Confirm Password", // نص الإرشاد لتأكيد كلمة المرور
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffc8d2d3)),
                          ),
                          isCollapsed: false,
                          isDense: true,
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffc8d2d3)),
                          ),
                          prefixIcon: Icon(Icons.lock,
                              color: Jemeel.buttonColor), // أيقونة القفل
                        ),
                      ),
                    ),
                    Container(
                      height: 45,
                      margin: const EdgeInsets.all(5),
                      child: TextField(
                        controller:
                            _phoneNumberTextEditingController, // متحكم نص رقم الهاتف
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: "Phone Number", // نص الإرشاد لرقم الهاتف
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffc8d2d3)),
                          ),
                          isCollapsed: false,
                          isDense: true,
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Color(0xffc8d2d3)),
                          ),
                          prefixIcon: Icon(Icons.phone,
                              color: Jemeel.buttonColor), // أيقونة الهاتف
                        ),
                      ),
                    ),

                    const SizedBox(height: 30.0), // مسافة بادئة
                    ElevatedButton(
                      // زر لإجراء عملية التسجيل
                      onPressed: () {
                        registerNewUser(); // دالة تسجيل المستخدم الجديد
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Jemeel.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),

                        minimumSize: const Size(
                          250,
                          50,
                        ), // Us
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                        child: Text(
                          "Create Account", // نص الزر
                          style:
                              TextStyle(color: Colors.white), // تخصيص لون النص
                        ),
                      ),
                    ),
                    const Text("Already Have an account?"),
                    TextButton(
                      onPressed: () {
                        Route route = MaterialPageRoute(
                            builder: (_) => const UserLogin());
                        Navigator.push(context, route);
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(color: Jemeel.textColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لتسجيل المستخدم الجديد
  Future<void> registerNewUser() async {
    // التحقق من ملء جميع الحقول وتطابق كلمتي المرور
    if (_emailTextEditingController.text.isNotEmpty &&
        _nameTextEditingController.text.isNotEmpty &&
        _passwordTextEditingController.text.isNotEmpty &&
        _confirmPasswordTextEditingController.text.isNotEmpty &&
        _phoneNumberTextEditingController.text.isNotEmpty &&
        _passwordTextEditingController.text ==
            _confirmPasswordTextEditingController.text) {
      registerUser(); // إجراء تسجيل المستخدم إذا تم التحقق من الشروط
    } else {
      displayDialog(); // عرض مربع حوار الخطأ إذا لم تتحقق الشروط
    }
  }

  // دالة لعرض مربع حوار الخطأ
  displayDialog() {
    showDialog(
      context: context,
      builder: (c) {
        return const ErrorAlertDialog(
          message:
              "Please complete the form", // رسالة تطلب من المستخدم إكمال النموذج
        );
      },
    );
  }

  // دالة لإجراء تسجيل المستخدم في Firebase Auth
  registerUser() async {
    showDialog(
        context: context, // سياق البناء الحالي
        builder: (c) {
          // باني الحوار
          return const LoadingAlertDialog(
            // ويدجت حوار مخصص لحالة التحميل
            message:
                "Validating data, wait...", // الرسالة المعروضة أثناء المصادقة
          );
        });
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    )
        .then((ID) {
      saveUserInfo(
          ID.user!.uid); // حفظ معلومات المستخدم في Firestore بعد التسجيل الناجح
    }).catchError((error) {
      // عرض مربع حوار الخطأ في حال فشل التسجيل
      Navigator.pop(context); // إغلاق أي مربع حوار مفتوح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login failed\nPlease check your email address and password and try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  // دالة لحفظ معلومات المستخدم في Cloud Firestore
  Future saveUserInfo(String currentUser) async {
    await FirebaseFirestore.instance.collection("users").doc(currentUser).set({
      "uid": currentUser, // معرف المستخدم
      "email": _emailTextEditingController.text.trim(), // البريد الإلكتروني
      "fullName": _nameTextEditingController.text.trim(), // الاسم الكامل
      "phonenumber":
          _phoneNumberTextEditingController.text.trim(), // رقم الهاتف
      "address": _addressTextEditingController.text.trim(), // العنوان
      "RegistredTime": DateTime.now(), // وقت التسجيل
      "points": 0,
      "rewards": 0,
      "type": "user", // نوع المستخدم
    }).then((value) {
      Navigator.pop(context); // إغلاق أي مربع حوار مفتوح

      // بعد حفظ البيانات بنجاح، توجيه المستخدم إلى صفحة الاختيار
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const UserLogin()));
    });
  }
}

// استيراد مكتبات فلاتر و Firebase اللازمة لتطبيق الدخول
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // لاستخدام خدمات المصادقة من Firebase
import 'package:flutter/material.dart';
import 'package:jemeel/Admin/AdminHomePage.dart';
import 'package:jemeel/Authentication/resetPassword.dart';
import 'package:jemeel/DialogBox/errorDialog.dart';
import 'package:jemeel/DialogBox/loadingDialog.dart';
import 'package:jemeel/config/config.dart';


// تعريف كلاس UserLogin كـ StatefulWidget لأن حالته يمكن أن تتغير (مثل إدخال النص)
class UserLogin extends StatefulWidget {
  const UserLogin({Key? key})
      : super(key: key); // Constructor يسمح بتمرير Key اختياري

  @override
  State<UserLogin> createState() =>
      _UserLoginState(); // إنشاء الحالة لـ UserLogin
}

class _UserLoginState extends State<UserLogin> {
  // تعريف متحكمين لإدارة حقول النص في فورم الدخول
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    // بناء واجهة صفحة الدخول
    return Scaffold(
      appBar: AppBar(
        // تخصيص شريط التطبيق باستخدام IconThemeData لتعيين لون الأيقونات
        iconTheme: IconThemeData(color: Jemeel.primraryColor),
        // عنوان الصفحة مع تخصيص اللون

        // تمكين تمركز العنوان في شريط التطبيق
        centerTitle: true,
      ),
      body: SafeArea(
        // استخدام SingleChildScrollView لتجنب مشاكل الoverflow عند ظهور لوحة المفاتيح
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            margin: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset(
                      "images/logo2.png", // شعار التطبيق أو الشركة
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Email", // ليبل حقل الإيميل
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                      ),
                    ),
                    // حقل إدخال الإيميل
                    Container(
                      height: 45,
                      margin: const EdgeInsets.all(5),
                      child: TextField(
                        controller:
                            _emailTextEditingController, // متحكم حقل الإيميل
                        cursorColor: Colors.black, // لون المؤشر
                        decoration: InputDecoration(
                          hintText: "example@gmail.com", // نص المساعدة
                          // تعريف حدود الحقل عند التركيز
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xffc8d2d3),
                            ),
                          ),
                          isCollapsed: false,
                          isDense: true,
                          // تعريف حدود الحقل في الحالة الافتراضية
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xffc8d2d3),
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.email, // أيقونة حقل الإيميل
                            color: Jemeel.buttonColor, // تغيير لون الأيقونة
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      "Password", // ليبل حقل كلمة المرور
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                      ),
                    ),
                    // حقل إدخال كلمة المرور
                    Container(
                      height: 45,
                      margin: const EdgeInsets.all(5),
                      child: TextField(
                        obscureText: true, // إخفاء النص للخصوصية
                        controller:
                            _passwordTextEditingController, // متحكم حقل كلمة المرور
                        cursorColor: Colors.black, // لون المؤشر
                        decoration: InputDecoration(
                          hintText: "**********", // نص المساعدة
                          // تعريف حدود الحقل عند التركيز
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xffc8d2d3),
                            ),
                          ),
                          isCollapsed: false,
                          isDense: true,
                          // تعريف حدود الحقل في الحالة الافتراضية
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xffc8d2d3),
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.lock, // أيقونة حقل كلمة المرور
                            color: Jemeel.buttonColor, // تغيير لون الأيقونة
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    // زر تسجيل الدخول
                    ElevatedButton(
                      onPressed: () {
                        loginFunction(); // دالة تسجيل الدخول
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
                          "Login", // نص الزر
                          style: TextStyle(
                            color: Colors.white, // لون النص
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Route route =
                            MaterialPageRoute(builder: (_) => resetPassword());
                        Navigator.push(context, route);
                      },
                      child: Text(
                        "Forget Password?",
                        style: TextStyle(color: Jemeel.buttonColor),
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

  // دالة غير متزامنة لعملية تسجيل الدخول
  Future<void> loginFunction() async {
    // التحقق من أن حقول البريد الإلكتروني وكلمة المرور ليست فارغة
    _emailTextEditingController.text.isNotEmpty &&
            _passwordTextEditingController.text.isNotEmpty
        ? ValidatingData() // إذا لم تكن فارغة، البدء في عملية المصادقة
        : displayDialog(
            "Please Fill up the information"); // إذا كانت فارغة، إظهار حوار يطلب ملء المعلومات
  }

// دالة لعرض حوار برسالة مخصصة
  displayDialog(String msg) {
    showDialog(
      context: context, // سياق البناء الحالي
      barrierDismissible: false, // يمنع إغلاق الحوار بالنقر خارجه
      builder: (c) {
        // باني الحوار
        return ErrorAlertDialog(
          message: msg,
          // ويدجت حوار مخصص
        );
      },
    );
  }

// دالة للتعامل مع عملية المصادقة
  ValidatingData() async {
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
    _login(); // استدعاء دالة _login
  }

  var currentUser; // متغير لتخزين معلومات المستخدم الحالي
// دالة غير متزامنة للتعامل مع تسجيل الدخول في Firebase
  void _login() async {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            // طريقة المصادقة في Firebase
            email: _emailTextEditingController.text
                .trim(), // البريد الإلكتروني من حقل النص
            password: _passwordTextEditingController.text
                .trim()) // كلمة المرور من حقل النص
        .then((auth) {
      // التعامل مع المصادقة الناجحة
      currentUser = auth.user!.uid; // تخزين معرف المستخدم في currentUser
      saveUserInfo(currentUser); // استدعاء saveUserInfo لحفظ معلومات المستخدم
    }).catchError(
      // التعامل مع الأخطاء أثناء المصادقة
      (error) {
        Navigator.pop(context); // إغلاق أي حوارات مفتوحة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login failed\nPlease check your email address and password and try again.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
  }

// دالة غير متزامنة لحفظ معلومات المستخدم
  saveUserInfo(String userAuth) async {
    var results = await FirebaseFirestore.instance
        .collection("users") // الوصول إلى مجموعة 'users' في Firestore
        .doc(userAuth) // مرجع الوثيقة للمستخدم الحالي
        .get();
    if (results.exists) {
      String userType = results['type'];
      String fullName = results['fullName'];
      Jemeel.sharedPreferences?.setString(Jemeel.name, fullName);
      if (userType == "admin") {
        Route route = MaterialPageRoute(builder: (context) => AdminHomePage());
        Navigator.pushAndRemoveUntil(context, route, (route) => false);
      } else if (userType == "user") {
        // Route route =
        //     MaterialPageRoute(builder: (context) => BottomNabigationHome());
        // Navigator.pushAndRemoveUntil(context, route, (route) => false);
      } else {
        
      }
    }
  }

  ErrorMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Validate the user account"),),);
  }
}

// استيراد الحزم اللازمة للتعامل مع Firebase Auth وواجهة المستخدم في Flutter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jemeel/Authentication/UserLogin.dart';
import 'package:jemeel/DialogBox/errorDialog.dart';
import 'package:jemeel/DialogBox/loadingDialog.dart';
import 'package:jemeel/config/config.dart';

// تعريف كلاس يمثل صفحة إعادة تعيين كلمة المرور
class resetPassword extends StatelessWidget {
  // تعريف مفتاح النموذج للتحقق من البيانات المدخلة
  final GlobalKey<FormState> _formKey = GlobalKey();
  // تعريف متحكم لإدارة حقل إدخال البريد الإلكتروني
  final TextEditingController _emailTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    // بناء واجهة المستخدم لصفحة إعادة تعيين كلمة المرور
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true, // لتجنب التداخل مع لوحة المفاتيح
      appBar: AppBar(
        centerTitle: true, // تمركز العنوان
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // توسيط المحتوى في العمود
        children: [
          SingleChildScrollView(
            // استخدام SingleChildScrollView للسماح بالتمرير
            child: SafeArea(
              // استخدام SafeArea لتجنب العوائق
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        "images/logo2.png", // شعار التطبيق أو الشركة
                        width: MediaQuery.of(context).size.width *
                            0.8, // تحديد عرض الصورة
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      Text(
                        "Reset Password", // نص التعليمات
                        style: TextStyle(
                            color: Jemeel.buttonColor,
                            fontSize: 27,
                            fontWeight: FontWeight.bold), // تخصيص النص
                      ),
                      const SizedBox(height: 20), // مسافة بين العناصر
                      Form(
                        key: _formKey, // استخدام مفتاح النموذج للتحقق
                        child: Column(
                          children: [
                            Container(
                              height: 45,
                              margin:
                                  const EdgeInsets.all(5), // هامش حول حقل النص
                              child: TextField(
                                controller:
                                    _emailTextEditingController, // متحكم حقل البريد الإلكتروني
                                cursorColor: Colors.black, // لون المؤشر
                                decoration: InputDecoration(
                                  hintText: "Email", // نص الإرشاد
                                  focusedBorder: const OutlineInputBorder(
                                    // تخصيص الحدود عند التركيز
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color(0xffc8d2d3),
                                    ),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    // تخصيص الحدود في الحالة الافتراضية
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color(0xffc8d2d3),
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email, // أيقونة البريد الإلكتروني
                                    color: Jemeel.buttonColor, // لون الأيقونة
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // مسافة بين العناصر
                      ElevatedButton(
                        onPressed: () {
                          checkIfEmailIsEmpty(
                              context); // فحص إذا كان حقل البريد الإلكتروني فارغًا
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15), // تبطين الزر
                          child: Text(
                            "Reset", // نص الزر
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // تخصيص النص
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة لفحص إذا كان حقل البريد الإلكتروني فارغاً وعرض حوار الخطأ أو متابعة إعادة التعيين
  checkIfEmailIsEmpty(BuildContext context) {
    _emailTextEditingController.text.isNotEmpty
        ? resetPasswordFun(
            context) // إجراء إعادة تعيين كلمة المرور إذا كان البريد موجود
        : showDialog(
            context: context,
            builder: (_) => const ErrorAlertDialog(
                message: "Please Put Email"), // عرض رسالة الخطأ
          );
  }

  // دالة لبدء عملية إعادة تعيين كلمة المرور
  resetPasswordFun(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const LoadingAlertDialog(
          message: "Resetting Password"), // عرض حوار التحميل
    );
    resettingPassword(context); // الدالة المسؤولة عن إعادة تعيين كلمة المرور
  }

  // دالة لإعادة تعيين كلمة المرور باستخدام Firebase Auth
  resettingPassword(context) {
    FirebaseAuth.instance
        .sendPasswordResetEmail(email: _emailTextEditingController.text.trim())
        .then(
      (value) {
        Navigator.pop(context); // إغلاق حوار التحميل
        showDialog(
          context: context,
          builder: (_) => const ErrorAlertDialog(
              message: "Email were sent"), // عرض رسالة نجاح العملية
        );
        Route route = MaterialPageRoute(builder: (_) => const UserLogin());
        Navigator.pushAndRemoveUntil(context, route, (route) => false);
      },
    ).catchError(
      (error) {
        Navigator.pop(context); // إغلاق حوار التحميل
        showDialog(
          context: context,
          builder: (_) => const ErrorAlertDialog(
              message:
                  "Please make sure the email is correct"), // عرض رسالة الخطأ
        );
      },
    );
  }
}

// استيراد مكتبة Cloud Firestore من Firebase للتعامل مع قاعدة البيانات
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jemeel/config/config.dart';
// استيراد صفحة StartPage من المجلد Authentication
// استيراد الإعدادات من مجلد config
import 'package:firebase_auth/firebase_auth.dart';
// استيراد مكتبة Firebase Core لتهيئة التطبيق مع Firebase
import 'package:firebase_core/firebase_core.dart';
// استيراد مكتبة Firebase Storage لتخزين الملفات
import 'package:firebase_storage/firebase_storage.dart';
// استيراد مكتبة Flutter لبناء الواجهة الرسومية
import 'package:flutter/material.dart';
import 'package:jemeel/firebase_options.dart';
import 'package:jemeel/widgets/StartPage.dart';
// استيراد مكتبة SharedPreferences للتعامل مع تفضيلات المستخدم المحلية
import 'package:shared_preferences/shared_preferences.dart';

// دالة main التي تُنفذ عند بدء تشغيل التطبيق
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة الارتباط بين Flutter ومحرك التطبيق

  await Firebase.initializeApp(
    // تهيئة Firebase باستخدام خيارات النظام الحالي
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Jemeel.sharedPreferences = await SharedPreferences.getInstance();
  // جلب تفضيلات المستخدم

  // تعيين مكونات Firebase للتطبيق kkue
  Jemeel.firebaseFirestore = FirebaseFirestore.instance;
  // قاعدة بيانات Firestore

  Jemeel.firebaseStorage = FirebaseStorage.instance;
  // وحدة تخزين Firebase

  Jemeel.firebaseAuth = FirebaseAuth.instance;
  // مصادقة المستخدمين

  runApp(const MyApp());
  // تشغيل التطبيق
}

// تعريف تطبيق MyApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // مُنشئ بدون معطيات

  @override
  Widget build(BuildContext context) {
    // بناء واجهة التطبيق
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // إخفاء شارة التصحيح من الشاشة

      theme: ThemeData.dark(),
      // تعيين الثيم إلى الوضع الداكن

      home: const StartPage(),
      // تحديد الصفحة الرئيسية عند بدء التطبيق
    );
  }
}

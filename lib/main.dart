import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD8A9COQf4cqUH2fcZz9RBWeB3isegcOkU",
        appId: "1:65459186865:web:221f0a540c2dd3ff48c690",
        messagingSenderId: "65459186865",
        projectId: "msb-store-dd1da",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MSBStoreApp());
}

List<Map<String, dynamic>> cartItems = [];
double appliedDiscountValue = 0.0;
String appliedCouponTitle = '';
String appliedCouponId = '';

class MSBStoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSB Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MainScreen(),
    );
  }
}
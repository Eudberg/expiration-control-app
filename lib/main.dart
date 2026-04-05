import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const MeatExpiryApp());
}

class MeatExpiryApp extends StatelessWidget {
  const MeatExpiryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Validade do Açougue',
      theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

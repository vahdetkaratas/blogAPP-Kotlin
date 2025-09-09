import 'package:flutter/material.dart';
import 'core/di/injector.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependency injection
  await setupDI();
  
  runApp(const App());
}

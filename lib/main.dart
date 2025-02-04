import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vagacerta/firebase_options.dart';
import 'package:vagacerta/pages/checagemPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que os bindings do Flutter estejam prontos

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    print("Erro ao inicializar Firebase: $error");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove o banner "Debug"
      theme: ThemeData(
        primarySwatch: Colors.blue, // Personaliza o tema do app
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChecagemPage(),
    );
  }
}

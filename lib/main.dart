import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/Screens/login_screen.dart';
// import 'package:flutter_application_1/Screens/home_init_screen.dart';
import 'package:flutter_application_1/Screens/welcome_screen.dart';
import 'package:flutter_application_1/Screens/register_screen.dart';
import 'package:flutter_application_1/Screens/register_socio_screen.dart';
import 'package:flutter_application_1/Screens/socios_screen.dart';
import 'package:flutter_application_1/Screens/membresia_screen.dart';
import 'package:flutter_application_1/Screens/register_membresia_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos Supabase con los datos del proyecto
  await Supabase.initialize(
    url: 'https://gzzkjmfbvcctjegjgzsv.supabase.co',
    publishableKey: 'sb_publishable_LR29fs4Zpa3o0eyvW49TVQ_ISZbLzf3',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GYM Admin',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const SociosScreen(),
        '/register': (context) => const RegisterScreen(),
        '/registro_socio': (context) => const RegistroSocioScreen(),
        '/membresias': (context) => const MembresiasScreen(),
        '/registro_membresia': (context) => const RegistroMembresiaScreen(),
       '/register_screen': (context) => const RegisterScreen()
      
        
      },
    );
  }

}
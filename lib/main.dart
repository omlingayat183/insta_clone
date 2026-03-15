import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insta_clone/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: InstagramApp(),
    ),
  );
}

class InstagramApp extends StatelessWidget {
  const InstagramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Feed',
      debugShowCheckedModeBanner: false,


      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          surface: Colors.black,
          primary: Color(0xFF0095F6),
        ),
        
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),

      home: const HomeScreen(),
    );
  }
}

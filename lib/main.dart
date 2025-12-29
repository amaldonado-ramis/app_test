import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rhapsody/theme.dart';
import 'package:rhapsody/nav.dart';
import 'package:rhapsody/providers/playback_provider.dart';
import 'package:rhapsody/providers/library_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlaybackProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()..loadData()),
      ],
      child: MaterialApp.router(
        title: 'Rhapsody',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

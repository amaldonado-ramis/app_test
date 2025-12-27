import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echobeat/theme.dart';
import 'package:echobeat/nav.dart';
import 'package:echobeat/providers/playback_provider.dart';
import 'package:echobeat/providers/library_provider.dart';

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
        ChangeNotifierProvider(create: (_) => LibraryProvider()..initialize()),
      ],
      child: MaterialApp.router(
        title: 'EchoBeat',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

import 'package:echostream/providers/liked_songs_provider.dart';
import 'package:echostream/providers/playback_provider.dart';
import 'package:echostream/providers/user_playlist_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlaybackProvider()..init()),
        ChangeNotifierProvider(create: (_) => LikedSongsProvider()..init()),
        ChangeNotifierProvider(create: (_) => UserPlaylistProvider()..init()),
      ],
      child: MaterialApp.router(
        title: 'EchoStream',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

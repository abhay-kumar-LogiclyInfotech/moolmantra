import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:moolmantra/services/audio_services.dart';
import 'package:moolmantra/views/splash_view.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await AudioService().init(); // Load saved preferences
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Change to your desired color
      statusBarIconBrightness: Brightness.light, // For white icons
      statusBarBrightness: Brightness.dark, // For iOS status bar text color
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Moolmantra',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: SplashView(),
      ),
    );
  }
}

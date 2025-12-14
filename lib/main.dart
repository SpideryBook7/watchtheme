import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/AndroidScreens/home_screen.dart';
import 'screens/TvScreens/home_tv.dart';
import 'screens/WearScreens/home_wear.dart';
import 'utils/device.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase initialization paused for demo mode
  // await Supabase.initialize(
  //   url: 'https://ewtzyzsoktdpphzjmteu.supabase.co',
  //   anonKey:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3dHp5enNva3RkcHBoemptdGV1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzMDgwNjIsImV4cCI6MjA2Mzg4NDA2Mn0.dEbOUynruOWk6W_CL7wCZmqCwn4cYFNHM1-vWgj0BBE',
  // );

  final deviceType = await getDeviceType();

  runApp(MyApp(deviceType: deviceType));
}

class MyApp extends StatelessWidget {
  final String deviceType;

  const MyApp({super.key, required this.deviceType});

  @override
  Widget build(BuildContext context) {
    Widget homeWidget;

    switch (deviceType) {
      case 'tv':
        homeWidget = const HomeTVScreen();
        break;
      case 'wear':
        homeWidget = const HomeWearScreen();
        break;
      default:
        homeWidget = const HomeScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Temas App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness:
            deviceType == 'tv' || deviceType == 'wear'
                ? Brightness.dark
                : Brightness.light,
      ),
      home: homeWidget,
    );
  }
}

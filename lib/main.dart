import 'package:cf_analytics/home.dart';
import 'package:cf_analytics/services/notification.dart';
import 'package:cf_analytics/shared/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  await Favourite.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tz.initializeTimeZones();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CF Analytics',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.urbanistTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Home(),
    );
  }
}

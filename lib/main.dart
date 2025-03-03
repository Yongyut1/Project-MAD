import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/libraryProvider.dart';
import 'ui/mainScreen.dart';
import 'provider/themeProvider.dart';
import 'theme.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ตั้งค่าให้ใช้ Skia renderer
  if (TargetPlatform.android == defaultTargetPlatform) {
    // บังคับให้ใช้ Skia renderer
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
  await initializeDateFormatting();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  await dotenv.load(fileName: "assets/.env");
  print("🔑 API Key: ${dotenv.env['GEMINI_API_KEY']}");

  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LibraryProvider()),
        ChangeNotifierProvider(create: (context) => themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Library Member Card',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: MyTheme.lightTheme(
                themeProvider.primaryColor, themeProvider.backgroundColor),
            darkTheme: MyTheme.darkTheme(
                themeProvider.primaryColor, themeProvider.backgroundColor),
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:quick_attednce/auth/login_screen.dart';
import 'package:quick_attednce/professor/p_home_screen.dart';
import 'package:quick_attednce/utils/components/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin/a_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences sp = await SharedPreferences.getInstance();
  bool isLogin = sp.getBool("isLogin") ?? false;

  runApp(MyApp(isLogin: ValueNotifier<bool>(isLogin)));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<bool> isLogin;

  const MyApp({required this.isLogin, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quick Attendance',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: GoogleFonts.raleway().fontFamily,
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          colorScheme: lightColorScheme ??
              ColorScheme.fromSeed(
                seedColor: Colors.lightBlue,
                brightness: Brightness.dark,
              ).copyWith(background: Colors.white),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          colorScheme: darkColorScheme ??
              ColorScheme.fromSeed(
                seedColor: Colors.lightBlue,
                brightness: Brightness.dark,
              ).copyWith(background: Colors.black),
          fontFamily: GoogleFonts.raleway().fontFamily,
        ),
        themeMode: ThemeMode.system,
        home: SplashScreen(
          isLogin: isLogin,
        ), // pass isLogin notifier to SplashScreen
      );
    });
  }
}

class SplashScreen extends StatefulWidget {
  final ValueNotifier<bool> isLogin;

  SplashScreen({required this.isLogin, Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ValueListenableBuilder<bool>(
                    valueListenable: widget.isLogin,
                    builder: (context, value, _) {
                      return value
                          ? FutureBuilder<CupertinoPageRoute>(
                              future: userRoute(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Navigator(
                                    pages: [
                                      CupertinoPage(
                                        child: snapshot.data!.builder(context),
                                      ),
                                    ],
                                    onPopPage: (route, result) =>
                                        route.didPop(result),
                                  );
                                } else {
                                  return const LoadingScreen(
                                      message: "Redirecting ...");
                                }
                              })
                          : const LoginScreen();
                    },
                  )));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    Size screenSize = MediaQuery.of(context).size;

    // Calculate icon size based on screen dimensions
    double iconHeight = screenSize.height * 2;
    double iconWidth = screenSize.width * 0.6;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      body: Center(
        child: Image.asset('assets/icon.png', height: iconHeight, width: iconWidth,),
      ),
    );
  }
}

Future<CupertinoPageRoute> userRoute() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  final String? userRole = sp.getString("userRole");

  if (userRole == "0") {
    // Redirect to Prof Dashboard
    return CupertinoPageRoute(
      builder: (context) => const ProfessorHomeScreen(),
    );
  } else if (userRole == "1") {
    // Redirect to Admin Dashboard
    return CupertinoPageRoute(
      builder: (context) => const AdminHomeScreen(),
    );
  } else {
    return CupertinoPageRoute(builder: (context) => const LoginScreen());
  }
}

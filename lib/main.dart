import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quick_attednce/auth/login_screen.dart';
import 'package:quick_attednce/professor/p_home_screen.dart';
import 'package:quick_attednce/utils/components/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin/a_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences sp = await SharedPreferences.getInstance();
  // final String? expiry = sp.getString("expiry");
  // bool isLogin = sp.getBool("isLogin") ?? false;
  //
  // if (expiry != null) {
  //   try {
  //     DateTime expiryDateTime = DateFormat('YYYY-MM-DD HH:MM:SS').parse(expiry);
  //     DateTime currentDateTime = DateTime.now().toUtc();
  //
  //     if (currentDateTime.isAfter(expiryDateTime)) {
  //       if (kDebugMode) {
  //         print("The expiry has expired.");
  //       }
  //       isLogin = false;
  //     } else {
  //       if (kDebugMode) {
  //         print("The expiry is still valid.");
  //       }
  //       isLogin = true;
  //     }
  //   } on FormatException catch (e) {
  //     if (kDebugMode) {
  //       print("Expiry is not a valid date format. ${e.toString()}");
  //     }
  //     isLogin = false;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Unexpected error parsing expiry: ${e.toString()}");
  //     }
  //     isLogin = false;
  //   }
  // } else {
  //   if (kDebugMode) {
  //     print("Expiry not found in SharedPreferences.");
  //   }
  //   isLogin = false;
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        home: const LoginScreen(),
        // home: isLogin
        //     ? FutureBuilder<CupertinoPageRoute>(
        //         future: userRoute(),
        //         builder: (context, snapshot) {
        //           if (snapshot.connectionState == ConnectionState.done) {
        //             return Navigator(
        //               pages: [
        //                 CupertinoPage(
        //                   child: snapshot.data!.builder(context),
        //                 ),
        //               ],
        //               onPopPage: (route, result) => route.didPop(result),
        //             );
        //           } else {
        //             return const LoadingScreen(message: "Redirecting ...");
        //           }
        //         },
        //       )
        //     : const LoginScreen(),
      );
    });
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

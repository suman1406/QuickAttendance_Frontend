import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_attednce/auth/password/forgot_password.dart';
import 'package:quick_attednce/auth/otp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';
import '../utils/api_constants.dart';
import '../utils/components/text_field.dart';
import '../utils/components/loading_screen.dart';
import '../utils/components/toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isLogin = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = false;
      isPasswordVisible = false;
    });

    SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey('userEmail')) {
        _emailController.text = sp.getString('userEmail')!;
      }
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailValidator(String? value) {
    // No space allowed. Can't be empty.
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // Check for spaces
    if (value.contains(' ')) {
      return 'Email cannot contain spaces';
    }

    // Check if it's a valid email address
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    // No space allowed. Can't be empty. Minimum 8 characters.
    if (value!.isEmpty) {
      return 'Please enter your Password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (value.contains(' ')) {
      return 'Password cannot contain spaces';
    }
    return null;
  }

  Future<String?> _login() async {
    try {
      setState(() {
        isLoading = true;
      });

      final dio = Dio();
      dio.options = BaseOptions(
        baseUrl: ApiConstants().url,
        connectTimeout: const Duration(milliseconds: 10 * 1000),
        receiveTimeout: const Duration(milliseconds: 10 * 1000),
        sendTimeout: const Duration(milliseconds: 10 * 1000),
      );

      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: print,
      ));

      if (kDebugMode) {
        print("Sending login request to the server...");
      }

      final response = await dio.post(
        ApiConstants().login,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        },
      );

      if (kDebugMode) {
        print(response.data);
      }

      SharedPreferences sp = await SharedPreferences.getInstance();

      if (response.statusCode == 201 || response.statusCode == 200) {
        sp.setString("userEmail", _emailController.text);
        sp.setString("userName", response.data['profName']);
        sp.setString("userRole", response.data['userRole'].toString());
        sp.setString("expiry", response.data['exp'].toString());
        sp.setBool("isLogin", true);

        if (kDebugMode) {
          print('userRole============');
          print(response.data['userRole'].toString());
          print(response.data['profName'].toString());
          print(response.data['expiry'].toString());
        }

        if (response.statusCode == 201) {
          // Navigate to OTP page
          sp.setString('OTP_TOKEN', response.data['SECRET_TOKEN']);
          return "2";
        } else if (response.statusCode == 200) {
          // Navigate to the appropriate dashboard
          sp.setString('SECRET_TOKEN', response.data['SECRET_TOKEN']);

          return response.data['userRole'].toString();
        }
      } else if (response.statusCode == 400) {
        showToast("Please check your credentials.");
      } else if (response.statusCode == 401) {
        showToast("Account is deactivated, contact admin for more details.");
      } else if (response.data != null && response.data['error'] != null) {
        showToast(response.data['error']);
      } else if (response.statusCode == 403) {
        showToast("Unauthorized.");
      } else {
        showToast("Something went wrong. Please try again later.");
      }

      return null;
    } on DioException catch (e) {
      // Handle Dio specific errors
      if (e.type == DioExceptionType.connectionTimeout) {
        showToast("Connection timeout. Please try again later.: $e");
        if (kDebugMode) {
          print("Connection timeout. Please try again later.: $e");
        }
      } else if (e.type == DioExceptionType.badResponse) {
        showToast(
            "Error ${e.response?.statusCode}: ${e.response?.statusMessage}");
      } else {
        showToast("An error occurred: $e");
      }

      return null;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen(
            message: 'Signing In ...',
          )
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text('Quick Attendance'),
              ),
              extendBodyBehindAppBar: true,
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar.large(
                      floating: false,
                      pinned: true,
                      snap: false,
                      centerTitle: true,
                      expandedHeight: MediaQuery.of(context).size.height * 0.27,
                      flexibleSpace: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              "assets/icon.png",
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 1, 16, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 72,
                            ),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Center(
                                    child: MyTextField(
                                      controller: _emailController,
                                      prefixIcon:
                                          const Icon(Icons.badge_rounded),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: _emailValidator,
                                      labelText: 'Email',
                                      hintText: 'Please enter your email',
                                      obscureText: false,
                                      enabled: true,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Center(
                                    child: MyTextField(
                                      controller: _passwordController,
                                      prefixIcon:
                                          const Icon(Icons.lock_rounded),
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      validator: _passwordValidator,
                                      labelText: 'Password',
                                      hintText: 'Please enter your password',
                                      obscureText:
                                          true ? !isPasswordVisible : false,
                                      enabled: true,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(
                                            () {
                                              isPasswordVisible =
                                                  !isPasswordVisible;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // todo: Redirect to Forgot Password Screen
                                      Navigator.of(context).pushAndRemoveUntil(
                                          CupertinoPageRoute(
                                        builder: (context) {
                                          return const ForgotPasswordPage();
                                        },
                                      ), (route) => false);
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      overlayColor: MaterialStateProperty.all(
                                        Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      "Forgot Password?",
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  MaterialButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _login().then(
                                          (res) => {
                                            if (res == "0")
                                              {
                                                // todo: Redirect to Prof Dashboard
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        CupertinoPageRoute(
                                                  builder: (context) {
                                                    return const ProfessorHomeScreen();
                                                  },
                                                ), (route) => false),
                                              }
                                            else if (res == "1")
                                              {
                                                // todo: Redirect to Admin Dashboard
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        CupertinoPageRoute(
                                                  builder: (context) {
                                                    return const AdminHomeScreen();
                                                  },
                                                ), (route) => false),
                                              }
                                            else if (res == "2")
                                              {
                                                // todo: Redirect to OTP
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        CupertinoPageRoute(
                                                            builder: (context) {
                                                  return const OtpScreen();
                                                }), (route) => false),
                                              },
                                          },
                                        );
                                      }
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    minWidth: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0, vertical: 10.0),
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    child: Text(
                                      "Login",
                                      style: GoogleFonts.raleway(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Text(
                                    "Developed By:",
                                    style: GoogleFonts.raleway(
                                      textStyle: TextStyle(
                                          fontSize: 32,
                                          color: Theme.of(context).colorScheme.onBackground),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(16.0),
                                    onTap: () {
                                      launchUrl(
                                        Uri.parse("https://suman1406.github.io/Portfolio/"),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      width: 300,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const CircleAvatar(
                                            foregroundImage: AssetImage(
                                              "assets/dev_image.jpeg",
                                            ),
                                            radius: 32.0,
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Suman Panigrahi",
                                                style: GoogleFonts.raleway(
                                                  textStyle: TextStyle(
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground),
                                                ),
                                              ),
                                              Text(
                                                "Amrita School of Computing",
                                                style: GoogleFonts.raleway(
                                                  textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onErrorContainer),
                                                ),
                                              ),
                                              Text(
                                                "Coimbatore, Tamil Nadu",
                                                style: GoogleFonts.raleway(
                                                  textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground),
                                                ),
                                              ),
                                              Chip(
                                                padding: const EdgeInsets.all(1),
                                                backgroundColor: Theme.of(context)
                                                    .colorScheme
                                                    .brightness ==
                                                    Brightness.dark
                                                    ? Colors.black
                                                    : Theme.of(context).colorScheme.background,
                                                elevation: 3,
                                                label: Text(
                                                  "Full Stack Developer",
                                                  style: GoogleFonts.raleway(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                      textStyle: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500)),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(16.0),
                                    onTap: () {
                                      launchUrl(
                                        Uri.parse(
                                            "https://www.linkedin.com/in/thanus-kumaar/"),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      width: 300,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const CircleAvatar(
                                            foregroundImage: AssetImage(
                                              "assets/dev2_image.jpeg",
                                            ),
                                            radius: 32.0,
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Thanus Kumaara",
                                                style: GoogleFonts.raleway(
                                                  textStyle: TextStyle(
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground),
                                                ),
                                              ),
                                              Text(
                                                "Amrita School of Computing",
                                                style: GoogleFonts.raleway(
                                                  textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onErrorContainer),
                                                ),
                                              ),
                                              Text(
                                                "Coimbatore, Tamil Nadu",
                                                style: GoogleFonts.raleway(
                                                  textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground),
                                                ),
                                              ),
                                              Chip(
                                                padding: const EdgeInsets.all(1),
                                                backgroundColor: Theme.of(context)
                                                    .colorScheme
                                                    .brightness ==
                                                    Brightness.dark
                                                    ? Colors.black
                                                    : Theme.of(context).colorScheme.background,
                                                elevation: 3,
                                                label: Text(
                                                  "Backend Developer",
                                                  style: GoogleFonts.raleway(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                      textStyle: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500)),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Text(
                                    "Academic Mentors:",
                                    style: GoogleFonts.raleway(
                                      textStyle: TextStyle(
                                          fontSize: 32,
                                          color: Theme.of(context).colorScheme.onBackground),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(16.0),
                                    onTap: () {
                                      launchUrl(
                                        Uri.parse("https://www.amrita.edu/faculty/t-senthilkumar/"),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      width: 300,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const CircleAvatar(
                                            foregroundImage: AssetImage(
                                              "assets/mentor1.jpeg",
                                            ),
                                            radius: 32.0,
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Dr. Senthil Kumar T.",
                                                style: GoogleFonts.raleway(
                                                  textStyle: TextStyle(
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground),
                                                ),
                                              ),
                                              Text(
                                                "Amrita School of Computing",
                                                style: GoogleFonts.raleway(
                                                  textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onErrorContainer),
                                                ),
                                              ),
                                              Text(
                                                "Coimbatore, Tamil Nadu",
                                                style: GoogleFonts.raleway(
                                                  textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground),
                                                ),
                                              ),
                                              Chip(
                                                padding: const EdgeInsets.all(1),
                                                backgroundColor: Theme.of(context)
                                                    .colorScheme
                                                    .brightness ==
                                                    Brightness.dark
                                                    ? Colors.black
                                                    : Theme.of(context).colorScheme.background,
                                                elevation: 3,
                                                label: Text(
                                                  "Associate Professor",
                                                  style: GoogleFonts.raleway(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                      textStyle: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500)),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(16.0),
                                    onTap: () {
                                      launchUrl(
                                        Uri.parse(
                                            "https://www.amrita.edu/faculty/b-senthilkumar/"),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      width: 300,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const CircleAvatar(
                                            foregroundImage: AssetImage(
                                              "assets/mentor2.jpeg",
                                            ),
                                            radius: 32.0,
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "B. Senthil Kumar",
                                                style: GoogleFonts.raleway(
                                                  textStyle: TextStyle(
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground),
                                                ),
                                              ),
                                              Text(
                                                "Amrita School of Darshanam",
                                                style: GoogleFonts.raleway(
                                                  textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onErrorContainer),
                                                ),
                                              ),
                                              Text(
                                                "Coimbatore, Tamil Nadu",
                                                style: GoogleFonts.raleway(
                                                  textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground),
                                                ),
                                              ),
                                              Chip(
                                                padding: const EdgeInsets.all(1),
                                                backgroundColor: Theme.of(context)
                                                    .colorScheme
                                                    .brightness ==
                                                    Brightness.dark
                                                    ? Colors.black
                                                    : Theme.of(context).colorScheme.background,
                                                elevation: 3,
                                                label: Text(
                                                  "Associate Professor",
                                                  style: GoogleFonts.raleway(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                      textStyle: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500)),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 32,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

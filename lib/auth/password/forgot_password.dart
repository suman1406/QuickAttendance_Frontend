import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/auth/login_screen.dart';
import 'package:quick_attednce/auth/password/reset_otp_verify.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/loading_screen.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:quick_attednce/utils/components/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  Future<String?> _sendResetEmail() async {
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

      // Print the request payload for debugging
      if (kDebugMode) {
        print({'email': _emailController.text.trim()});
      }

      // Send the password reset request to the backend
      final response = await dio.post(
        ApiConstants().forgotPassword,
        data: {'email': _emailController.text},
      );

      // Print the response for debugging
      if (kDebugMode) {
        print(response.data);
        print(response);
        print("===============");
        print(response.statusCode);
      }

      // Check the response status code
      if (response.statusCode == 200) {
        SharedPreferences sp = await SharedPreferences.getInstance();
        sp.setString("resetToken", response.data?['SECRET_TOKEN']);
        sp.setString("userEmail", _emailController.text);
        // sp.setString("userRole", response.data?['userRole']);

        showToast('Password reset email sent successfully');
        return "1";
      } else if (response.statusCode == 400) {
        showToast("Please check your credentials.");
      } else if (response.statusCode == 401) {
        showToast("Account is deactivated, contact admin for more details.");
      } else if (response.data != null && response.data['error'] != null) {
        showToast(response.data['error']);
      } else if (response.statusCode == 403) {
        showToast("User does not exist");
      } else if (response.statusCode == 500) {
        showToast("Internal Server Error");
      } else {
        showToast("Something went wrong. Please try again later.");
      }
    } catch (error) {
      // Handle network or other errors
      if (kDebugMode) {
        print(error);
      }
      showToast('Something went wrong. Please try again later');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen(
            message: 'Sending reset email...',
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Forgot Password'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyTextField(
                      controller: _emailController,
                      validator: _emailValidator,
                      prefixIcon: const Icon(Icons.badge_rounded),
                      keyboardType: TextInputType.emailAddress,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      obscureText: false,
                      enabled: true,
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _sendResetEmail().then((res) => {
                                if (res == "1")
                                  {
                                    Navigator.of(context).pushReplacement(
                                        CupertinoPageRoute(builder: (context) {
                                      return const OtpVerificationPage();
                                    }),)
                                  }
                              });
                        }
                      },
                      child: const Text('Send Reset Email'),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

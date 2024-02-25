import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/auth/login_screen.dart';
import 'package:quick_attednce/auth/password/reset_password.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/loading_screen.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:quick_attednce/utils/components/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  OtpVerificationPageState createState() => OtpVerificationPageState();
}

class OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String? _otpValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits long';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    return null;
  }

  Future<String?> _verifyOtp() async {
    try {
      setState(() {
        isLoading = true;
      });

      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("resetToken");
      final String? userEmail = sp.getString("userEmail");

      final dio = Dio();
      dio.options = BaseOptions(
        baseUrl: ApiConstants().url,
        connectTimeout: const Duration(milliseconds: 10 * 1000),
        receiveTimeout: const Duration(milliseconds: 10 * 1000),
        sendTimeout: const Duration(milliseconds: 10 * 1000),
      );

      // Print the request payload for debugging
      if (kDebugMode) {
        print({'otp': _otpController.text.trim(), 'email': userEmail});
      }

      // Send the OTP verification request to the backend
      final response = await dio.post(
        ApiConstants().resetVerify,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'otp': _otpController.text,
          'email': userEmail,
        },
      );

      // Print the response for debugging
      if (kDebugMode) {
        print(response.data);
        print(response.statusCode);
        print(_otpController.text);
        print(userEmail);
      }

      // Check the response status code
      if (response.statusCode == 200) {
        // TODO: Navigate to the next screen or perform any other action
        sp.setString('SECRET_TOKEN', response.data['SECRET_TOKEN']);
        showToast('OTP verified successfully');

        return "1";
      } else if (response.statusCode == 400) {
        showToast("Invalid OTP");
      } else if (response.statusCode == 401) {
        showToast("User does not exist or OTP expired");
      } else if (response.data != null && response.data['error'] != null) {
        showToast(response.data['Error']);
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
            message: 'Verifying OTP...',
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('OTP Verification'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'An OTP has been sent to your email.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16.0),
                    MyTextField(
                      controller: _otpController,
                      validator: _otpValidator,
                      prefixIcon: const Icon(Icons.confirmation_number_sharp),
                      keyboardType: TextInputType.number,
                      labelText: 'OTP',
                      hintText: 'Enter 6 digit OTP',
                      obscureText: false,
                      enabled: true,
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _verifyOtp().then(
                            (res) => {
                              if (res == "1")
                                {
                                  // todo: Redirect to Prof Dashboard
                                  Navigator.of(context).pushAndRemoveUntil(
                                      CupertinoPageRoute(
                                    builder: (context) {
                                      return const ResetPasswordPage();
                                    },
                                  ), (route) => false),
                                }
                            },
                          );
                        }
                      },
                      child: const Text('Verify OTP'),
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

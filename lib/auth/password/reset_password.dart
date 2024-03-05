import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:quick_attednce/auth/login_screen.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/loading_screen.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:quick_attednce/utils/components/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ResetPasswordPageState createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String? _newPasswordValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (value.contains(' ')) {
      return 'Password cannot contain spaces';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value != _newPasswordController.text) {
      return 'Confirm password must match the password';
    }
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Password must contain only alphanumeric characters';
    }
    return null;
  }

  Future<String?> _resetPassword() async {
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

      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");
      final String? userEmail = sp.getString("userEmail");

      final response = await dio.post(
        ApiConstants().resetPassword,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'email': userEmail,
          'newPassword': _newPasswordController.text,
        },
      );

      if (response.statusCode == 200) {
        showToast('Password reset successful');
        sp.setString('SECRET_TOKEN', response.data['SECRET_TOKEN']);
        return "1";
      } else if (response.statusCode == 400) {
        showToast("Please check your credentials.");
      } else if (response.statusCode == 401) {
        showToast("Account is deactivated\nContact admin for more details.");
      } else if (response.data != null && response.data['message'] != null) {
        showToast(response.data['message']);
      } else if (response.statusCode == 403) {
        showToast("Unauthorized.");
      } else if (response.statusCode == 500) {
        showToast("Internal Server Error");
      } else {
        showToast("Something went wrong. Please try again later.");
      }
    } catch (error) {
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
            message: 'Resetting password...',
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Reset Password'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyTextField(
                      controller: _newPasswordController,
                      validator: _newPasswordValidator,
                      prefixIcon: const Icon(Icons.lock_rounded),
                      keyboardType: TextInputType.text,
                      labelText: 'New Password',
                      hintText: 'Enter a new password',
                      obscureText: true,
                      enabled: true,
                    ),
                    const SizedBox(height: 16.0),
                    MyTextField(
                      controller: _confirmPasswordController,
                      validator: _confirmPasswordValidator,
                      prefixIcon: const Icon(Icons.lock_rounded),
                      keyboardType: TextInputType.text,
                      labelText: 'Confirm Password',
                      hintText: 'Retype your new password',
                      obscureText: true,
                      enabled: true,
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _resetPassword().then(
                            (res) => {
                              if (res == "1")
                                {
                                  Navigator.of(context).pushReplacement(
                                      CupertinoPageRoute(
                                    builder: (context) {
                                      return const LoginScreen();
                                    },
                                  ),),
                                }
                            },
                          );
                        }
                      },
                      child: const Text('Reset Password'),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

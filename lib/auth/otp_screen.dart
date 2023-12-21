import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_attednce/auth/login_screen.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';
import '../utils/api_constants.dart';
import '../utils/components/text_field.dart';
import '../utils/components/loading_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isRePasswordVisible = false;

  @override
  void initSate() {
    SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey('newPassword')) {
        _newPasswordController.text = sp.getString('newPassword')!;
        _rePasswordController.text = sp.getString('newPassword')!;
      }
    });
  }

  String? _otpValidator(String? value) {
    // Check for empty value
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }

    // Validate OTP length
    if (value.length != 6) {
      return 'OTP must be 6 digits long';
    }

    // Check for non-numeric characters
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }

    return null;
  }

  String? _newPasswordValidator(String? value) {
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

  String? _confirmPasswordValidator(String? value) {
    // Check if the confirm password matches the original password
    if (value != _newPasswordController.text) {
      return 'Confirm password must match the password';
    }

    // Check for empty value
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }

    // Validate password length
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for non-numeric characters
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Password must contain only alphanumeric characters';
    }

    return null;
  }

  Future<String?> _verify() async {
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
      final String? userEmail = sp.getString("userEmail");
      final String? userRole = sp.getString("userRole");
      final String? secretCode = sp.getString("OTP_TOKEN");
      sp.setString("newPassword", _newPasswordController.text);
      sp.setString("ConPassword", _rePasswordController.text);

      // Print the request payload for debugging
      if (kDebugMode) {
        print({
          'otp': _otpController.text.trim(),
          'newPassword': _newPasswordController.text.trim(),
          'email': userEmail,
        });
      }

      // Send the verification request to the backend
      final response = await dio.post(
        ApiConstants().loginVerify,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'otp': _otpController.text.trim(),
          'password': _newPasswordController.text.trim(),
        },
      );

      if (kDebugMode) {
        print(response.data);
        print('userRole============${userRole!}');
      } // Print the response for debugging

      // Check the response status code
      if (response.statusCode == 200) {
        // Handle successful verification
        sp.setString('SECRET_TOKEN', response.data['SECRET_TOKEN']);
        return userRole;
      } else if (response.statusCode == 400) {
        showToast("Invalid OTP\nPlease try again");
      } else if (response.data != null && response.data['error'] != null) {
        showToast(response.data['Error']);
      } else {
        showToast("Something went wrong. Please try again later.");
      }
    } catch (error) {
      // Handle network or other errors
      if (kDebugMode) {
        print(error);
      }
      showToast('Something went wrong. Please try again later');
      return null;
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
            message: 'Verifying you ...',
          )
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              extendBodyBehindAppBar: true,
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      floating: false,
                      pinned: true,
                      snap: false,
                      centerTitle: true,
                      expandedHeight: MediaQuery.of(context).size.height * 0.27,
                      leading: IconButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              CupertinoPageRoute(builder: (context) {
                            return const LoginScreen();
                          }), (route) => false);
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        titlePadding: const EdgeInsets.all(16),
                        centerTitle: true,
                        title: Text(
                          "Enter OTP and Create New Password",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleMedium!.color,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 32, 16, 90),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyTextField(
                                  controller: _otpController,
                                  validator: _otpValidator,
                                  prefixIcon: const Icon(
                                      Icons.confirmation_number_sharp),
                                  keyboardType: TextInputType.number,
                                  labelText: 'OTP',
                                  hintText: 'Enter 6 digit OTP',
                                  obscureText: false,
                                  enabled: true,
                                ),
                                const SizedBox(height: 16.0),
                                MyTextField(
                                  controller: _newPasswordController,
                                  validator: _newPasswordValidator,
                                  prefixIcon: const Icon(Icons.lock_rounded),
                                  keyboardType: TextInputType.text,
                                  labelText: 'Password',
                                  hintText: 'Enter a new password',
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
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                MyTextField(
                                  controller: _rePasswordController,
                                  validator: _confirmPasswordValidator,
                                  prefixIcon: const Icon(Icons.lock_rounded),
                                  keyboardType: TextInputType.text,
                                  labelText: 'Confirm Password',
                                  hintText: 'Retype your new password',
                                  obscureText:
                                      true ? !isRePasswordVisible : false,
                                  enabled: true,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isRePasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isRePasswordVisible =
                                            !isRePasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24.0),
                                MaterialButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _verify().then((res) => {
                                            if (res == "0")
                                              {
                                                // todo: Redirect to Prof Dashboard
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        CupertinoPageRoute(
                                                            builder: (context) {
                                                  return const ProfessorHomeScreen();
                                                }), (route) => false)
                                              }
                                            else if (res == "1")
                                              {
                                                // todo: Redirect to Admin Dashboard
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        CupertinoPageRoute(
                                                            builder: (context) {
                                                  return const AdminHomeScreen();
                                                }), (route) => false)
                                              }
                                          });
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
                                    "Verify",
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
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

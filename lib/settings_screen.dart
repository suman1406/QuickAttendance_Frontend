import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/professor/p_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'about_screen.dart';
import 'admin/a_home_screen.dart';
import 'admin/profile_screen.dart';
import 'auth/login_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        leading: IconButton(
          onPressed: () async {
            final SharedPreferences sp = await SharedPreferences.getInstance();
            final String userRole = sp.getString("userRole").toString();

            if (userRole == "0") {
              Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(builder: (context) {
                return const ProfessorHomeScreen();
              }),);
            } else if (userRole == "1") {
              Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(builder: (context) {
                return const AdminHomeScreen();
              }),);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            title: const Text(
              'View Profile',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserProfilePage()),
              );
            },
          ),
          const Divider(
            height: 1.0, // Add a divider between list tiles
            color: Colors.grey,
          ),
          ListTile(
            title: const Text(
              'About',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          const Divider(
            height: 1.0, // Add a divider between list tiles
            color: Colors.grey,
          ),
          ListTile(
            title: const Text(
              'Logout',
            ),
            onTap: () async {
              SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setBool('isLogin', false);
              Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
              );
            },
          ),
          const Divider(
            height: 1.0, // Add a divider between list tiles
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

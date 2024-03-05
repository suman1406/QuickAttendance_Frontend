import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserRoleDropdown extends StatefulWidget {
  final Function(String) onChanged;

  const UserRoleDropdown({super.key, required this.onChanged});

  @override
  UserRoleDropdownState createState() => UserRoleDropdownState();
}

class UserRoleDropdownState extends State<UserRoleDropdown> {
  late int selectedUserRole; // No default role initially

  @override
  void initState() {
    super.initState();
    // Set the selectedUserRole to the default role (0 for faculty)
    selectedUserRole = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.secondary,
              size: 25,
            ),
            const SizedBox(width: 10),
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedUserRole,
                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary,),
                iconSize: 30,
                elevation: 16,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedUserRole = newValue;
                      widget.onChanged(newValue.toString());
                    });
                  }
                },
                items: [
                  DropdownMenuItem<int>(
                    value: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: Text(
                        'Faculty',
                        style: GoogleFonts.raleway(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: Text(
                        'Admin',
                        style: GoogleFonts.raleway(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

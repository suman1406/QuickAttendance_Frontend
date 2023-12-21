import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;

  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size mq = MediaQuery.of(context).size;

    // Color buttonColor = theme.brightness == Brightness.light
    //     ? theme.primaryColor
    //     : Colors.white;

    Color textColor = theme.brightness == Brightness.light
        ? theme.primaryTextTheme.labelLarge?.color ?? Colors.white
        : Colors.white;

    Color borderColor = Colors.white; // Set the border color to white

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: mq.width * 0.3,
        height: mq.height * 0.07,
        decoration: BoxDecoration(
          color:  theme.primaryColor,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: borderColor), // Set the border color
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
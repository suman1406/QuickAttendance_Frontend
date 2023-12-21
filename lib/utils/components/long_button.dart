import 'package:flutter/material.dart';

// global object for accessing device screen size
late Size mq;

class LongButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;

  const LongButton({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size; // Get the screen size

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: mq.width * 0.8,
        height: mq.height * 0.07,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

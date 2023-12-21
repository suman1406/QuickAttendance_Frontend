import 'package:flutter/material.dart';

late Size mq;

class DropDownMenu extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final ValueChanged<String?> onChanged;

  const DropDownMenu({super.key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size; // Get the screen size

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                backgroundColor: Colors.white,
              ),
              child: SizedBox(
                width: mq.width * 0.80,
                child: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(12.0),
                  value: value,
                  isExpanded: true,
                  onTap: () {},
                  onChanged: onChanged,
                  hint: Text(hintText),
                  items: items.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

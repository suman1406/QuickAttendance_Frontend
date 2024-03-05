import 'package:flutter/material.dart';

class SlotDropdown extends StatefulWidget {
  final Function(String) onChanged;

  const SlotDropdown({super.key, required this.onChanged});

  @override
  SlotDropdownState createState() => SlotDropdownState();
}

class SlotDropdownState extends State<SlotDropdown> {
  late String selectedPeriodNo = '1'; // Initialize with a default value

  @override
  Widget build(BuildContext context) {
    List<String> periodNos = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

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
              Icons.access_time_rounded,
              color: Theme.of(context).colorScheme.secondary,
              size: 25,
            ),
            const SizedBox(width: 10),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPeriodNo,
                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary,),
                iconSize: 30,
                elevation: 16,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedPeriodNo = newValue;
                      widget.onChanged(newValue);
                    });
                  }
                },
                items: periodNos.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: Text(
                        'Period $value',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';

class QRScanningPage extends StatefulWidget {
  final String? slotIds;
  final String course;

  const QRScanningPage({Key? key, required this.slotIds, required this.course})
      : super(key: key);

  @override
  QRScanningPageState createState() => QRScanningPageState();
}

class QRScanningPageState extends State<QRScanningPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  Set<String> scannedDataSet = {}; // Store scanned data here

  Future<void> sendScannedData(String scannedData) async {
    final String? slotIds = widget.slotIds;
    final String course = widget.course;
    // final String timestamp = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Create a DateFormat instance with the desired pattern and IST time zone
    DateFormat istDateFormat = DateFormat('yyyy-MM-dd', 'en_US').add_Hms();

    // Format the current date and time in IST
    String timestamp = istDateFormat.format(DateTime.now());

    // Print the formatted timestamp
    print('Formatted Timestamp in IST: $timestamp');

    final List<Map<String, dynamic>> dataList = scannedDataSet
        .map((scannedData) => {
              'RollNo': scannedData,
              'SlotIDs': slotIds,
              'date': timestamp,
              'courseName': course,
            })
        .toList();

    final Dio dio = Dio();

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    if (kDebugMode) {
      print('=========================================');
      print(dataList[0]);
      print('=========================================');
    }

    try {
      final response = await dio.post(
        ApiConstants().addAttendance,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $secretCode',
        }),
        data: dataList.last,
      );

      // Handle the response as needed
      if (response.statusCode == 200) {
        // Data sent successfully
        if (kDebugMode) {
          print('Data sent successfully');
        }
      } else {
        // Handle other status codes
        if (kDebugMode) {
          print('Failed to send data. Status code: ${response.statusCode}');
        }
      }
    } catch (error) {
      // Handle errors
      if (kDebugMode) {
        print('Error sending data: $error');
      }
    }
  }

  void playBeepSound() async {
    FlutterBeep.beep();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
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
            color: colorScheme.primary,
          ),
        ),
        title: const Text('QR Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: QRView(
                key: qrKey,
                onQRViewCreated: (QRViewController controller) {
                  this.controller = controller;
                  controller.scannedDataStream.listen((scanData) {
                    final code = scanData.code!;
                    if (!scannedDataSet.contains(code)) {
                      setState(() {
                        scannedDataSet.add(code);
                      });

                      // Play beep sound when data is scanned
                      playBeepSound();

                      // Send scanned data directly to the backend
                      sendScannedData(code);
                    }
                  }, onError: (error) {
                    if (kDebugMode) {
                      print("Error while scanning QR code: $error");
                    }
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scanned Data:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: scannedDataSet.length,
                        itemBuilder: (context, index) {
                          final scannedData = scannedDataSet.toList()[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              'Scanned Data ${index + 1}: $scannedData',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

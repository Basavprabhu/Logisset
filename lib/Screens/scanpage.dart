import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> devices = [];
  bool isScanning = false;
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  List<String> matchedDeviceAddresses = [];

  void _startScanning() {
    setState(() {
      devices.clear();
      isScanning = true;
    });

    flutterBlue.scanResults.listen((scanResult) {
      setState(() {
        devices = scanResult;
      });
    });

    flutterBlue.startScan();
  }

  void _stopScanning() {
    flutterBlue.stopScan();
    setState(() {
      isScanning = false;
    });
  }

  Future<void> _checkDatabaseForDevice(String deviceName) async {
    try {
      final snapshot = await _databaseReference.once();
      final DataSnapshot data = snapshot.snapshot;

      if (data.value != null && data.value is Map) {
        final Map<dynamic, dynamic> mapData =
            data.value as Map<dynamic, dynamic>;
        mapData.forEach((key, value) {
          if (value is Map &&
              value.containsKey('name') &&
              value['name'] == deviceName) {
            setState(() {
              matchedDeviceAddresses.add(value['address']);
            });
          }
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void dispose() {
    flutterBlue.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Device Scanner'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isScanning ? _stopScanning : _startScanning,
            child: Text(isScanning ? 'Stop Scan' : 'Start Scan'),
          ),
          SizedBox(height: 10),
          if (isScanning) LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: matchedDeviceAddresses.length,
              itemBuilder: (context, index) {
                final address = matchedDeviceAddresses[index];
                return ListTile(
                  title: Text('Matched Device'),
                  subtitle: Text(address),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

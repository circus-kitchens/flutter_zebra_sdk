import 'dart:async';
import 'dart:typed_data';

import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_zebra_sdk/flutter_zebra_sdk.dart';
import 'package:flutter_zebra_sdk_example/label.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:widget_zpl_converter/widget_zpl_converter.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Uint8List? _labelScreenshot;
  late final Future<void> _init = initial();
  String? printerAddress;

  @override
  void initState() {
    super.initState();
  }

  Future<void> scan() async {
    final bt = BluetoothClassic();
    final zebraPattern = RegExp(r'^[0-9A-Z]{12}$');
    bt.onDeviceDiscovered().asBroadcastStream().listen((device) {
      if (zebraPattern.hasMatch(device.name ?? '')) {
        setState(() {
          printerAddress = device.address;
        });
      }
    });

    await bt.startScan();
  }

  Future<void> initial() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect
    ].request();

    unawaited(scan());
  }

  Future<void> onTestBluetooth() async {
    final widget = ImageZplConverter(Label(), width: 760);
    final data = await widget.convert();

    if (printerAddress == null) {
      return;
    }

    final rep =
        await ZebraSdk.printZPLOverBluetooth(printerAddress!, data: data);
    print(rep);
  }

  Future<void> takeScreenshot() async {
    final widget = ImageZplConverter(Label(), width: 760);
    final screenshot = await widget.takeScreenshot();
    setState(() {
      _labelScreenshot = screenshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder(
            future: _init,
            builder: (_, snapshot) {
              return Center(
                child: Column(
                  children: [
                    Wrap(
                      spacing: 24,
                      children: [
                        ElevatedButton(
                          onPressed: scan,
                          child: Text('Discover BT printers'),
                        ),
                        if (printerAddress == null)
                          ElevatedButton(
                            onPressed: onTestBluetooth,
                            child: Text('Print via Bluetooth'),
                          )
                        else
                          Banner(
                            message: 'Connected',
                            location: BannerLocation.topEnd,
                            color: Colors.lightGreen,
                            child: ElevatedButton(
                              onPressed: onTestBluetooth,
                              child: Text('Print via Bluetooth'),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: takeScreenshot,
                          child: Text('Take Screenshot'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 2 / 1,
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Label()),
                            ),
                          ),
                          if (_labelScreenshot != null)
                            Expanded(
                              child: Banner(
                                message: 'Image',
                                location: BannerLocation.bottomStart,
                                child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Image.memory(_labelScreenshot!)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

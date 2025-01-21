import 'dart:async';

import 'package:flutter/services.dart';

class ZebraSdk {
  static const MethodChannel _channel =
      const MethodChannel('flutter_zebra_sdk');

  static Future<String?> printZPLOverBluetooth(String macAddress,
      {String? data}) async {
    final Map<String, dynamic> params = {"mac": macAddress};
    if (data != null) {
      params['data'] = data;
    }
    return await _channel.invokeMethod('printZPLOverBluetooth', params);
  }
}

import 'dart:developer';

import 'package:bluetooth_serial/utils/repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'consts.dart';

requestEnable() async {
  await FlutterBluetoothSerial.instance.requestEnable();
}

saveLanguage(String languageCode) {
  prefs!.setString(LANGUAGE_CODE, languageCode);
}

getLanguage() {
  String languageCode =
      prefs!.getString(LANGUAGE_CODE) ?? languages[0].languageCode;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case 'en':
      return languages[0];
    case 'es':
      return languages[1];
    default:
      return languages[0];
  }
}

AppLocalizations translation(BuildContext context) {
  return AppLocalizations.of(context)!;
}

saveCurrentDevice(BluetoothDevice device) {
  prefs!.setString(DEVICE_ADDRESS, device.address);
  prefs!.setString(DEVICE_NAME, device.name!);
}

getCurrentDevice() {
  String? address = prefs!.getString(DEVICE_ADDRESS);
  String? name = prefs!.getString(DEVICE_NAME);
  if (address != null && name != null) {
    return BluetoothDevice(
      name: name,
      address: address,
    );
  }
  return null;
}

devPrint(dynamic message) {
  if (kDebugMode) {
    log('DEV: ________________ $message');
  }
}

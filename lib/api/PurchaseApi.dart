import 'dart:io' show Platform;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';

Future<void> initPlatformState() async {
  await Purchases.setDebugLogsEnabled(true);

  PurchasesConfiguration configuration;
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration("goog_WZiqNVmIVvkQgSbtEAtteprmaZE");
  } else{
    configuration = PurchasesConfiguration("goog_WZiqNVmIVvkQgSbtEAtteprmaZE");
  }
  await Purchases.configure(configuration);

}
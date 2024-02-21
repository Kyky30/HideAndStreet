import 'dart:io' show Platform;
import 'package:purchases_flutter/purchases_flutter.dart' ;

Future<void> initPlatformState() async {

  PurchasesConfiguration configuration;
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration("goog_WZiqNVmIVvkQgSbtEAtteprmaZE");
  } else{
    configuration = PurchasesConfiguration("goog_WZiqNVmIVvkQgSbtEAtteprmaZE");
  }
  await Purchases.configure(configuration);

}

Future<bool> isPremium() async {
  CustomerInfo purchaserInfo = await Purchases.getCustomerInfo();
  return purchaserInfo.entitlements.all["premium"]?.isActive ?? false;
}
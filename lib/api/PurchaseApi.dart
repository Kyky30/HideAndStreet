import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';


class PurchaseApi {
  static const _apiKey = '';

  static Future init() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup(_apiKey);
  }

  static Future<List<Offering>> fetchOffers() async {
    try{
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      return current == null ? [] : [current];
    } on PlatformException catch (e) {
      print(e);
      return [];
    }
  }
}
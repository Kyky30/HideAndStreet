// shop.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:hide_and_street/monetization/PurchaseApi.dart';
import 'package:hide_and_street/monetization/AdmobHelper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../components/buttons.dart';


void presentPaywallIfNeeded() async {
  await initPlatformState();
  final paywallResult = await RevenueCatUI.presentPaywallIfNeeded("default");
  print('Paywall result: $paywallResult');
}

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  double getScaleFactor(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return mediaQueryData.textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = getScaleFactor(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.boutique, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, fontFamily: 'Poppins',)),
        ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              child: AdWidget(
                ad: AdmobHelper.getBannerAd()..load(),
                key: UniqueKey(),
              ),
              height: 75 * scaleFactor,
            ),
            const SizedBox(height: 16),
            CustomButton(
                text: AppLocalizations.of(context)!.acheterpremium,
                onPressed: presentPaywallIfNeeded,
                scaleFactor: scaleFactor
            ),
            const SizedBox(height: 128),
            Text(AppLocalizations.of(context)!.boutique_bientot_dispo, style: TextStyle(fontSize: 32 * scaleFactor, fontFamily: "Poppins", fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}

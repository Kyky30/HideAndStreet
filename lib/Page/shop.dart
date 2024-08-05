// shop.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:HideAndStreet/monetization/PurchaseApi.dart';
import 'package:HideAndStreet/monetization/AdmobHelper.dart';
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
        title: Text(AppLocalizations.of(context)!.boutique,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            )),
      ),
      body: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset(
              'assets/Boutique.jpg', // Remplacez par le chemin de votre image de fond
              fit: BoxFit.cover,
            ),
          ),
          // Contenu de la page
          Padding(
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
                  scaleFactor: scaleFactor,
                  backgroundColor: Color(0x6E000000),
                ),
                const SizedBox(height: 128),
                Text(
                  AppLocalizations.of(context)!.boutique_bientot_dispo,
                  style: TextStyle(
                      fontSize: 32 * scaleFactor,
                      fontFamily: "Poppins",
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

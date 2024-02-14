// shop.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:hide_and_street/monetization/PurchaseApi.dart';

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
        title: Text(AppLocalizations.of(context)!.infospremium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: presentPaywallIfNeeded,
              style: ElevatedButton.styleFrom(
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 20 * scaleFactor, // Adapter la taille du coin en fonction du facteur de zoom
                    cornerSmoothing: 1,
                  ),
                ),
                minimumSize: Size(double.infinity, 80 * scaleFactor), // Adapter la hauteur du bouton en fonction du facteur de zoom
                backgroundColor: const Color(0xFF373967),
                foregroundColor: const Color(0xFF212348),
              ),
              child: Text(
                AppLocalizations.of(context)!.acheterpremium,
                style: TextStyle(
                  fontSize: 20 * scaleFactor, // Adapter la taille de la police en fonction du facteur de zoom
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

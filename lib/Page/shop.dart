// shop.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:hide_and_street/monetization/PurchaseApi.dart';

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
        title: Text(AppLocalizations.of(context)!.infospremium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CustomButton(
                text: AppLocalizations.of(context)!.acheterpremium,
                onPressed: presentPaywallIfNeeded,
                scaleFactor: scaleFactor
            ),
          ],
        ),
      ),
    );
  }
}

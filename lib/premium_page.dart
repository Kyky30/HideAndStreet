import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hide_and_street/squircle_block.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:hide_and_street/api/PurchaseApi.dart';



class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.infospremium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            SquircleInfoBlock(
              title: AppLocalizations.of(context)!.avantagespremium,
              informationList: [AppLocalizations.of(context)!.espacevide, AppLocalizations.of(context)!.nbparties, AppLocalizations.of(context)!.espacevide, AppLocalizations.of(context)!.publicite, AppLocalizations.of(context)!.espacevide, AppLocalizations.of(context)!.modesdejeutabprem, AppLocalizations.of(context)!.espacevide, AppLocalizations.of(context)!.reglagessupptabprem, AppLocalizations.of(context)!.espacevide, AppLocalizations.of(context)!.cosmetiquesuppmoistabprem, AppLocalizations.of(context)!.espacevide, AppLocalizations.of(context)!.cosmetiquesupptabprem],
            ),
            const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: print('Acheter premium'),
            //   style: ElevatedButton.styleFrom(
            //     shape: SmoothRectangleBorder(
            //       borderRadius: SmoothBorderRadius(
            //         cornerRadius: 20,
            //         cornerSmoothing: 1,
            //       ),
            //     ),
            //     minimumSize: const Size(double.infinity, 80),
            //     backgroundColor: const Color(0xFF373967),
            //     foregroundColor: const Color(0xFF212348),
            //   ),
            //   child: Text(
            //     AppLocalizations.of(context)!.acheterpremium,
            //     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
            //   ),
            // ),
          ],
        ),
      ),
    );

    // Future fetchOffers() async {
    //   final offerings = await PurchaseApi.fetchOffers();
    //
    //   if (offerings.isEmpty) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('No offerings available'),
    //       ),
    //     );
    //   }
    //   final offer = offerings.first;
    //   print('Offer: $offer');
    // }
  }
}


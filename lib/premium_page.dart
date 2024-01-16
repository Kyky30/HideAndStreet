import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({Key? key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.infospremium),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context)!.avantagespremium,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
         Container(
           decoration: BoxDecoration(
             borderRadius: SmoothBorderRadius(
             cornerRadius: 20,
             cornerSmoothing: 1,
            ),
             color: Colors.amber,

           ),
           width: (MediaQuery.of(context).size.width)*0.78,

           child:  CarouselSlider(
             options: CarouselOptions(
               height: MediaQuery.of(context).size.height * 0.65,
               enableInfiniteScroll: true,
               enlargeCenterPage: true,

             ),
             items: [
               _buildCarouselItem(
                 context,
                 title: AppLocalizations.of(context)!.nbparties,
                 description: AppLocalizations.of(context)!.espacevide,
                 image: AssetImage("assets/premium.png"),
               ),
               _buildCarouselItem(
                 context,
                 title: AppLocalizations.of(context)!.publicite,
                 description: AppLocalizations.of(context)!.espacevide,
                 image: AssetImage("assets/premium.png"),
               ),
               _buildCarouselItem(
                 context,
                 title: AppLocalizations.of(context)!.modesdejeutabprem,
                 description: AppLocalizations.of(context)!.espacevide,
                 image: AssetImage("assets/premium.png"),
               ),
               _buildCarouselItem(
                 context,
                 title: AppLocalizations.of(context)!.reglagessupptabprem,
                 description: AppLocalizations.of(context)!.espacevide,
                 image: AssetImage("assets/premium.png"),
               ),
               _buildCarouselItem(
                 context,
                 title: AppLocalizations.of(context)!.cosmetiquesuppmoistabprem,
                 description: AppLocalizations.of(context)!.espacevide,
                 image: AssetImage("assets/premium.png"),
               ),
               _buildCarouselItem(
                 context,
                 title: AppLocalizations.of(context)!.cosmetiquesupptabprem,
                 description: AppLocalizations.of(context)!.espacevide,
                 image: AssetImage("assets/premium.png"),
               ),
             ],
           ),
         ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(

              onPressed: () async {
                await Purchases.purchaseStoreProduct('premium_subscription' as StoreProduct);
              },
              style: ElevatedButton.styleFrom(
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 20,
                    cornerSmoothing: 1,
                  ),
                ),

                minimumSize: const Size(double.infinity, 80),
                backgroundColor: const Color(0xFFDAA520),
                foregroundColor: const Color(0xFF000000),

              ),
              child: Text(
                AppLocalizations.of(context)!.acheterpremium,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(
      BuildContext context, {
        required String title,
        required String description,
        required AssetImage image,
      }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image(
              image: image,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

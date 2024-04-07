import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

class AdmobHelper {

  InterstitialAd? _interstitialAd;

  int numInterstitialLoadAttempts = 0;

  static initialize() {
    MobileAds.instance.initialize();
  }

  Future<void> createInterstitialAd() {
    Completer<void> completer = Completer<void>();

    InterstitialAd.load(
      adUnitId: "ca-app-pub-3940256099942544/1033173712",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          numInterstitialLoadAttempts = 0;
          completer.complete(); // Completer le Future lorsque la publicité est chargée
        },
        onAdFailedToLoad: (error) {
          print('Failed to load interstitial ad: $error');
          numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (numInterstitialLoadAttempts <= 5) {
            createInterstitialAd();
          }
          completer.completeError(error); // Completer le Future avec une erreur si la publicité n'a pas pu être chargée
        },
      ),
    );

    return completer.future; // Retourner le Future
}

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        // Ne pas appeler createInterstitialAd() ici
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        // Ne pas appeler createInterstitialAd() ici
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  static BannerAd getBannerAd() {
    BannerAd bAd = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      listener: BannerAdListener(
        onAdClosed: (Ad ad) => print('Ad closed.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        onAdOpened: (Ad ad) => print('Ad opened.'),
      ),
      request: const AdRequest(),
    );

    return bAd;
  }




}
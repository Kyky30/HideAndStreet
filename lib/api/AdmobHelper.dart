import 'dart:ffi';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobHelper {

  InterstitialAd? _interstitialAd;

  int numInterstitialLoadAttempts = 0;

  static initialize() {
    if (MobileAds.instance == null) {
      MobileAds.instance.initialize();
    }
  }

  void createInterstitialAd() {

    InterstitialAd.load(
        adUnitId: "ca-app-pub-3940256099942544/1033173712",
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              print('$ad loaded');
              _interstitialAd = ad;
              numInterstitialLoadAttempts = 0;
            },
            onAdFailedToLoad: (LoadAdError error) {
              print('InterstitialAd failed to load: $error');
              numInterstitialLoadAttempts += 1;
              _interstitialAd = null;
              if (numInterstitialLoadAttempts <= 2) {
                createInterstitialAd();
              }
            }),
    );
    
  }

  void showInterstitialAd() {
    if(_interstitialAd == null) {
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }





}
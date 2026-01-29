import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._internal();

  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  // Test ID for Android Interstitial
  final String _adUnitId = 'ca-app-pub-3940256099942544/1033173712';

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _interstitialAd = ad;
          _isAdLoaded = true;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('$ad dismissed.');
              ad.dispose();
              _isAdLoaded = false;
              // Reload ad automatically after dismissal for next time
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('$ad failed to show: $error');
              ad.dispose();
              _isAdLoaded = false;
              // Reload ad automatically
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd(VoidCallback onAdClosed) {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('$ad dismissed.');
          ad.dispose();
          _isAdLoaded = false;
          onAdClosed(); // Trigger callback
          loadInterstitialAd(); // Reload for next time
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('$ad failed to show: $error');
          ad.dispose();
          _isAdLoaded = false;
          onAdClosed(); // Trigger callback even if failed
          loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
    } else {
      debugPrint('Ad not ready, skipping.');
      onAdClosed(); // Allow normal flow if ad not ready
      // Attempt load for next time
      loadInterstitialAd();
    }
  }
}

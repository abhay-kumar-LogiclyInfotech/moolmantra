import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:moolmantra/services/ad_services.dart';
import 'package:provider/provider.dart';

import '../services/audio_services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  /// instance of audio service class
  final audioService = AudioService();

  /// Banner Ad
  BannerAd? _bannerAd;

  /// Interstitial Ad
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();

    interstitialAdCount = 0;

    /// load interstitial ad
    loadInterstitialAd();

    /// show banner ad
    loadBannerAd();

  }

  /// Banner Ad
  int maxAdRetries = 5; // Set a sensible retry limit
  int adRetryCount = 0;

  void loadBannerAd() async {
    while (adRetryCount < maxAdRetries) {
      _bannerAd?.dispose(); // Dispose of the previous ad before creating a new one

      _bannerAd = BannerAd(
        adUnitId: AdServices.bannerAdUnitId,
        size: AdSize.banner,
        request: AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _bannerAd = ad as BannerAd;
            setState(() {});
            adRetryCount = 0; // Reset retry count on success
          },
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
            _bannerAd = null;
            adRetryCount++;
            if (adRetryCount < maxAdRetries) {
              Future.delayed(Duration(seconds: 5), loadBannerAd);
            }
          },
        ),
      );

      _bannerAd?.load();
      break; // Exit loop after attempting to load an ad
    }
  }


  int numMaxAttempt = 0;
  /// interstitial Ad
  void loadInterstitialAd() {
    _interstitialAd?.dispose();
    InterstitialAd.load(
      adUnitId: AdServices.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
            _interstitialAd = ad;
            _interstitialAd?.setImmersiveMode(true);
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                audioService.playAudio();
                _interstitialAd = null;
              });
              loadInterstitialAd(); // Load a new ad for future use
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              debugPrint("Failed to show full screen ad $error");
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint(error.toString());
        },
      ),
    );
  }
  void showInterstitialAd() {
    if (canShowInterstitialAd()) {
      if (_interstitialAd != null) {
        _interstitialAd!.show();
        _interstitialAd = null; // Dispose after showing
        loadInterstitialAd(); // Load a new ad for future use
        interstitialAdCount++;
      } else {
        debugPrint("Interstitial Ad not available. Retrying...");
        retryLoadInterstitialAd(); // Retry mechanism
      }
    }
  }

  int interstitialAdCount = 0;

  // Check if we can show the ad
  bool canShowInterstitialAd() {
    return interstitialAdCount == 0;
  }

  // Function to retry loading the interstitial ad
  void retryLoadInterstitialAd({int retries = 3, int delaySeconds = 2}) async {
    for (int i = 0; i < retries; i++) {
      await Future.delayed(Duration(seconds: delaySeconds)); // Wait before retrying
      loadInterstitialAd(); // Try loading the ad again

      if (_interstitialAd != null) {
        debugPrint("Interstitial Ad loaded successfully on retry $i.");
        return;
      }
    }
    debugPrint("Failed to load Interstitial Ad after $retries retries.");
  }


  @override
  void dispose() {
    audioService.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildUi(context),
          if (_bannerAd != null)
            SafeArea(
              child: Center(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: _bannerAd!.size.height.toDouble(),
                    width: _bannerAd!.size.width.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildUi(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/home/home_image.jpg"),
          fit: BoxFit.fill,
        ),
      ),

      child: Stack(
        children: [
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 150,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChangeNotifierProvider(
                  create: (context) => AudioService(),
                  child: Consumer<AudioService>(
                    builder: (context, provider, _) {
                      return InkWell(
                        onTap: () async {
                            showInterstitialAd();
                             provider.toggleAudio();

                        },
                        child: Image(
                          image: AssetImage(
                            provider.isPlaying
                                ? "assets/home/stop_image.png"
                                : "assets/home/play_button_image.png",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:audioplayers/audioplayers.dart';
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
    _bannerAd = BannerAd(
      adUnitId: AdServices.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {});
        },
        onAdFailedToLoad: (ad, err) {
          _bannerAd = null; // Avoid referencing a failed ad
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdServices.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
          });
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
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
      }
    }
  }

  int interstitialAdCount = 0;

  bool canShowInterstitialAd() {
    return interstitialAdCount == 0;
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
                          if (canShowInterstitialAd()) {
                            showInterstitialAd();
                          } else {
                            await provider.toggleAudio();
                            setState(() {});
                          }
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

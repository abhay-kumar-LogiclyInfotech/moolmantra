import 'dart:io';

class AdServices{
  static String get bannerAdUnitId{
    if(Platform.isAndroid){
      return "ca-app-pub-9809262906118130/7226300622";
    }
    else if(Platform.isIOS){
      return "ca-app-pub-3940256099942544/6300978111";
    }
    else{
      throw UnsupportedError("Unsupported Platform");
    }
  }

  static String get interstitialAdUnitId{
    if(Platform.isAndroid){
      return "ca-app-pub-9809262906118130/4693542605";
    }
    else if(Platform.isIOS){
      return "ca-app-pub-3940256099942544/1033173712";
    }
    else{
      throw UnsupportedError("Unsupported Platform");
    }
  }
}
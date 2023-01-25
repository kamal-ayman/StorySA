import 'dart:io';
const bool testMode = false;

class AdHelper {

  static String get bannerAdUnitId {
    if (testMode) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return 'ca-app-pub-7136012509023664/2061746151';
  }

  static String get interstitialAdUnitId {
    if (testMode) {
      return "ca-app-pub-3940256099942544/1033173712";
    }
    if (Platform.isAndroid) {
      return "ca-app-pub-7136012509023664/5462731271";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/4411468910";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/5224354917";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}

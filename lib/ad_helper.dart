import 'dart:io';
const bool testMode = false;

class AdHelper {

  static String get bannerAdUnitId {
    if (testMode) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else {
      return 'ca-app-pub-7136012509023664/2061746151';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-7136012509023664/2061746151';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
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
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/5224354917";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}

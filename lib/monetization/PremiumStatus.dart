class PremiumStatus {
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  set isPremium(bool value) {
    _isPremium = value;
  }

  // Singleton pattern
  static final PremiumStatus _instance = PremiumStatus._internal();

  factory PremiumStatus() {
    return _instance;
  }

  PremiumStatus._internal();
}

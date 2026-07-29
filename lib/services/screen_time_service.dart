class AppUsageInfo {
  const AppUsageInfo({
    required this.appName,
    required this.usageMinutes,
  });

  final String appName;
  final int usageMinutes;
}

class ScreenTimeService {
  ScreenTimeService._();
  static final ScreenTimeService _instance = ScreenTimeService._();
  factory ScreenTimeService() => _instance;

  Future<void> requestPermission() async {}

  Future<int> getDailyUsage() async => 0;

  Future<List<AppUsageInfo>> getMostUsedApps() async => [];

  Future<int> getSocialMediaUsage() async => 0;

  bool get isPermissionGranted => false;
}

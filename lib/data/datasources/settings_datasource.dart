abstract class SettingsDataSource {
  Future<void> setExcludedRoutes(String routes);

  Future<String> getExcludedRoutes();
}

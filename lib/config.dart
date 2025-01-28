class AppConfig {
  bool ssl;
  String baseUrl;

  String get ws => '${_getWsProtocol()}$baseUrl/ws';

  AppConfig({
    this.ssl = false, // ToDo: change to true before release
    required this.baseUrl,
  });


  String _getWsProtocol() {
    if (ssl) return 'wss://';
    return 'ws://';
  }
}
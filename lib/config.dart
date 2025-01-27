class AppConfig {
  bool ssl;
  String baseUrl;
  String? googleApiKey;
  // String? supportUrl;
  // String? contractUrl;
  // String? privacyUrl;
  String? whistoryApiKey;

  String get ws => '${_getWsProtocol()}$baseUrl/v0/ws'; // ToDo: why v0/ws? Mb change?
  String get http => _getHttpProtocol() + baseUrl;

  AppConfig({
    this.ssl = false, // ToDo: change to true before release
    required this.baseUrl,
    this.googleApiKey,
    // this.supportUrl,
    // this.contractUrl,
    // this.privacyUrl, // ToDo: cleanup comms
    this.whistoryApiKey,
  });

  String _getHttpProtocol() {
    if (ssl) return 'https://';
    return 'http://';
  }

  String _getWsProtocol() {
    if (ssl) return 'wss://';
    return 'ws://';
  }
}
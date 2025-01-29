import 'dart:async';
import 'dart:convert' as convert;
import 'package:omni_front/config.dart';
import 'package:omni_front/response.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:logger/logger.dart';
import 'locator.dart';

class WebSocket{
  final Logger _logger = Logger();
  late WebSocketChannel _channel;
  final url = locator.get<AppConfig>().ws;
  Map<int, dynamic> requests = {};
  final StreamController _events = StreamController.broadcast();
  int reqCount = 0;

  void resolveRemaining() {
    for (var req in requests.values) {
      req(ApiResponse.networkErr());
    }
    requests.clear();
  }

  void connect(){
    _channel = IOWebSocketChannel.connect(url);
    _logger.i('WebSocket connection established');
  }

  void broadcast({required Function onError}) {
    _channel.stream.listen(
      onMessage,
      onError: (e) {
        onError();
      },
      onDone: () {
        resolveRemaining();
      },
      cancelOnError: true,
    );
  }

  void onMessage(dynamic data) {
    var evt = convert.jsonDecode(data);
    _logger.i('Received message: $evt');
    if (evt['id'] != null) {
      requests[evt['id']](ApiResponse.fromMap(evt));
      requests.remove(evt['id']);
    } else {
      _events.add(evt);
    }
  }

  void send(String message){
    _channel.sink.add(message);
    _logger.d('Message sent: $message');
  }

  Future<ApiResponse<dynamic>> sendEvent(String method, {Map<String, dynamic>? data}) async {
    int currentCount = reqCount++;                          // Note: be careful with reqCount,
    var completer = Completer<ApiResponse<dynamic>>();      // there may be 2 simultaneous requests.
    var req = {                                             // Make sure those requests wont have same id.
      'id': currentCount,
      'method': method,
      'data': data == null ? null
          : Map.fromEntries(await Future.wait(data.entries.map((entry) async {
        if (entry.value is Future) {
          return MapEntry(entry.key, await entry.value);
        }
        return entry;
      }).toList()))
    };

    requests.putIfAbsent(currentCount, () => completer.complete);
    _channel.sink.add(convert.jsonEncode(req));
    _logger.d('Request sent: $req');
    return completer.future;
  }

  Future<String> getResponse() async{
    final response = await _channel.stream.first
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException('No response from server');
    });
    _logger.i('Received response: $response');
    return response;
  }

  Future<void> close() async{
    await _channel.sink.close();
    _logger.i('WebSocket connection closed');
  }
}
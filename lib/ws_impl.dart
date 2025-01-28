import 'dart:async';

import 'package:omni_front/config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:logger/logger.dart';
import 'locator.dart';

class WebSocket{
  final Logger _logger = Logger();
  late WebSocketChannel _channel;
  final url = locator.get<AppConfig>().ws;

  void connect(){
    _channel = IOWebSocketChannel.connect(url);
    _logger.i('WebSocket connection established');
  }

  void send(String message){
    _channel.sink.add(message);
    _logger.d('Message sent: $message');
  }

  Future<String> getResponse() async{
    final response = await _channel!.stream.first
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
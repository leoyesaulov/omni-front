import 'package:maap/pkg/websocket/models/event.dart';
import 'package:maap/pkg/websocket/models/response.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert' as convert;
import 'dart:async';
import 'webscoket.dart';

class Websocket {
  late WebSocketChannel channel;
  Map<int, dynamic> requests = {};
  int reqCount = 1;
  final StreamController _events = StreamController.broadcast();

  late String url;

  void resolveRemaining() {
    for (var req in requests.values) {
      req(ApiResponse.networkErr());
    }
    requests.clear();
  }

  Future<void> connect(String url) async {
    print('[WS] connect $url');
    resolveRemaining();
    channel = IOWebSocketChannel.connect(url,
        pingInterval: const Duration(seconds: 5));
  }

  void broadcast({required Function onError}) {
    channel.stream.listen(
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
    print('[WS] RECEIVE $evt');
    if (evt['id'] != null) {
      requests[evt['id']](ApiResponse.fromMap(evt));
      requests.remove(evt['id']);
    } else {
      _events.add(evt);
    }
  }

  @override
  Future<ApiResponse<dynamic>> send(String method,
      {Map<String, dynamic>? data}) async {
    int currentCount = reqCount;                          // Note: be careful with reqCount,
    reqCount++;                                           // there may be 2 simultaneous requests.
    var completer = Completer<ApiResponse<dynamic>>();    // Make sure those requests wont have same id.
    var req = {
      'id': currentCount,
      'method': method,
      'data': data == null
          ? null
          : Map.fromEntries(await Future.wait(data.entries.map((entry) async {
        if (entry.value is Future) {
          return MapEntry(entry.key, await entry.value);
        }
        return entry;
      }).toList()))
    };

    print('[WS] SEND $req');
    requests.putIfAbsent(currentCount, () => completer.complete);
    channel.sink.add(convert.jsonEncode(req));
    return completer.future;
  }

  @override
  Stream<ApiEvent> on([String? event]) {
    return _events.stream.where((e) {
      if (event == null) return true;
      return e['event'] == event;
    }).map((e) => ApiEvent.fromJson(e));
  }

  Future<void> close() {
    print('[WS] close');
    return channel.sink.close();
  }
}

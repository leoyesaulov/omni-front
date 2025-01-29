import 'dart:io';
import 'package:flutter/material.dart';
import 'package:omni_front/theme.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:logger/logger.dart';
import 'locator.dart';
import 'ws_impl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: AppTheme.purpleTheme,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Logger _logger = Logger();
  late WebSocket _ws;
  String _response = 'No response yet';
  bool _isLoading = false;

  @override
  initState() {
    super.initState();
    setupLocator();
  }

  Future<void> _sendRequest() async {
    _ws = locator.get<WebSocket>();
    setState(() {
      _isLoading = true;
      _response = 'Sending request...';
    });

    try {
      // Connection initialization
      _ws.connect();


      // Message sending
      _ws.send("Hello, Backend!");

      // Waiting for response
      final response = await _ws.getResponse();

      setState(() => _response = 'Response: $response');

    } on SocketException catch (e) {
      _handleError('Connection error: ${e.message}', Level.error);
    } on WebSocketChannelException catch (e) {
      _handleError('WebSocket error: ${e.message}', Level.error);
    } on TimeoutException catch (e) {
      _handleError(e.message ?? 'Request timed out', Level.warning);
    } on Exception catch (e) {
      _handleError('Unexpected error: ${e.toString()}', Level.error);
    } finally {
      await _ws.close();
      setState(() => _isLoading = false);
      _logger.d('Connection closed');
    }
  }

  void _handleError(String message, Level level) {
    _logger.log(level, message);
    setState(() => _response = 'Error: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leo\'s showcase project: frontend')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _sendRequest,
              child: const Text('Send Request'),
            ),
            const SizedBox(height: 20),
            Text(
              _response,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: _response.startsWith('Error:')
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ws.close();
    super.dispose();
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}
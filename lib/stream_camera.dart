import 'dart:convert';

import 'package:camera_websocket/stream_socket.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class StreamCamera extends StatefulWidget {
  final String address;
  final int clientID;

  const StreamCamera(
      {super.key, required this.address, required this.clientID});

  @override
  State<StreamCamera> createState() => _StreamCameraState();
}

class _StreamCameraState extends State<StreamCamera> {
  final StreamSocket streamSocket = StreamSocket();
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    connectAndListen();
  }

  void connectAndListen() {
    channel = WebSocketChannel.connect(
      Uri.parse(widget.address),
    );

    channel.stream.listen((message) {
      try {
        streamSocket.addResponse(message);
      } catch (e) {
        debugPrint('Received text message: $message');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: streamSocket.getResponse,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final imageBytes = base64.decode(snapshot.data!);

            final image = Image.memory(
              imageBytes,
              fit: BoxFit.scaleDown,
              gaplessPlayback: true,
            );
            return image;
          } else if (snapshot.hasError) {
            return Text('Erro: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

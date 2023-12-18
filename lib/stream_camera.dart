import 'dart:convert';

import 'package:camera_websocket/stream_socket.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class StreamCamera extends StatefulWidget {
  final String serverUrl;
  final int port;
  final String event;

  const StreamCamera({required this.serverUrl, required this.port, required this.event, super.key});

  @override
  State<StreamCamera> createState() => _StreamCameraState();
}

class _StreamCameraState extends State<StreamCamera> {
  final StreamSocket streamSocket = StreamSocket();
  Image? lastImage;

void connectAndListen(){
  io.Socket socket = io.io('http://${widget.serverUrl}:${widget.port}/${widget.event}',
      io.OptionBuilder()
       .setTransports(['websocket']).build());

    socket.onConnect((_) {
     debugPrint('connect');
    });

    socket.on('camera_frame', (data) {
      final String base64Image = data['image'];
      streamSocket.addResponse(base64Image);
      });
    socket.onDisconnect((_) => debugPrint('disconnect'));
  }  

  @override
  void initState() {
    super.initState();
    connectAndListen();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build');

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

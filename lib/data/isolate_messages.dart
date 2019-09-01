import 'dart:isolate';
import 'dart:collection';

import 'package:googleapis/docs/v1.dart';

class IsolateMessage<S,T> {
  final double progress;
  final bool finished;
  final bool error;
  final S errorData;
  final T data;

  IsolateMessage(this.progress, this.finished, this.error, this.errorData, this.data);
}

class IsolateInitMessage<T> {
  final SendPort sendPort;
  final T data;

  IsolateInitMessage(this.sendPort, this.data);
}

class IsolateRequest<T> {
  final String method;
  final T data;

  IsolateRequest(this.method, this.data);
}

class IsolateResponse<T> {
  final T data;

  IsolateResponse(this.data);
}

class IsolateCommunication {
  ReceivePort _receive;
  final SendPort sendPort;
  Stream<dynamic> _stream;

  IsolateCommunication(this.sendPort){
    _receive = ReceivePort();
    sendPort.send(IsolateRequest(".", _receive.sendPort));
    _stream = _receive.asBroadcastStream();
  }

  void send(IsolateRequest request){
    sendPort.send(request);
  }

  Future<IsolateResponse> receive() async {
    await for (IsolateResponse response in _stream){
      return response;
    }
  }
}

class IsolateCommunicationHandler {
  final ReceivePort receive;
  SendPort _send;
  final Function(IsolateRequest request, IsolateCommunicationHandler handler) _handler;

  IsolateCommunicationHandler(this.receive, this._handler);

  void start() async {
    receive.listen((data) {
      _handler(data, this);
    });
  }

  void setSend(SendPort send){
    _send = send;
  }

  void send(IsolateResponse response){
    _send.send(response);
  }
}
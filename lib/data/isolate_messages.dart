import 'dart:isolate';

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
  int _counter = 0;

  IsolateCommunication(this.sendPort){
    _receive = ReceivePort();
    sendPort.send(IsolateRequest(".", _receive.sendPort));
  }

  void send(IsolateRequest request){
    sendPort.send(request);
  }

  Future<IsolateResponse> receive() async {
    IsolateResponse response = await _receive.elementAt(_counter);
    _counter++;
    return response;
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
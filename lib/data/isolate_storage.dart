
import 'package:secure_upload/backend/cloud/google/cloudClient.dart' as cloudClient;
import 'package:secure_upload/data/isolate_messages.dart';

class IsolateStorage extends cloudClient.Storage {
  final IsolateCommunication comm;
  IsolateStorage(this.comm);

  Future<String> get(String key) async {
    comm.send(IsolateRequest<String>("storage.get", key));

    IsolateResponse value = await comm.receive();
    return value.data;
  }

  void set(String key, String value){
    comm.send(IsolateRequest<List<String>>("storage.set", [key, value]));
  }
}
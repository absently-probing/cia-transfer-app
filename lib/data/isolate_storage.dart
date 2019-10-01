
import '../backend/storage/storage.dart';
import 'package:cia_transfer/data/isolate_messages.dart';

class IsolateStorage extends Storage {
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
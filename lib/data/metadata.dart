class FileMetadata {
  final List<String> filenames;
  final int size;
  final int timestamp;
  final String fileLink;
  final String publicKey;

  FileMetadata(this.filenames, this.size, this.timestamp, this.fileLink, {this.publicKey = ""});

  FileMetadata.fromJson(Map<String, dynamic> json)
      : filenames = List<String>.from(json['filenames']),
        size = json['size'],
        timestamp = json['timestamp'],
        fileLink = json['fileLink'],
        publicKey = json['publicKey'];


  Map<String, dynamic> toJson() =>
      {
        'filenames': filenames,
        'size' : size,
        'timestamp' : timestamp,
        'fileLink' : fileLink,
        'publicKey' : publicKey,
      };

  List showMetadata(){
    var msize = (size.toDouble() / (1000 * 1000)).floor();
    List<String> keys = ['Files: ', 'Date: ', 'PublicKey: ', 'Total Size: '];
    List<String> values = [filenames.toString(), DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true)
        .toIso8601String(), publicKey, msize.toString() + " MB"];
    Map<String, String> map = {};

    if (keys.length != values.length){
      throw FormatException("invalid map configuration");
    }
    for (int i = 0; i < keys.length; i++){
      map[keys[i]] = values[i];
    }

    return [keys, map];
  }
}
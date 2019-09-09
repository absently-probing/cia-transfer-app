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
    // calculate size in MB
    var msize = (size.toDouble() / (1000 * 1000)).ceil();

    // create file entry
    String filesString = "";

    for (String file in filenames){
      if (filesString == ""){
        filesString = file;
      } else {
        filesString = filesString + "\n" + file;
      }
    }

    // show Date
    var tmpDate = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
    String date = "${tmpDate.year.toString()}-${tmpDate.month.toString().padLeft(2, "0")}-${tmpDate.day.toString().padLeft(2, "0")}"
        + " ${tmpDate.hour.toString()}:${tmpDate.minute.toString()}";

    List<String> keys = ['Files: ', 'Date: ', 'PublicKey: ', 'Total Size: '];
    List<String> values = [filesString, date, publicKey, msize.toString() + " MB"];
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
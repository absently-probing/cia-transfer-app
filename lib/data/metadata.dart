class FileMetadata {
  final List<String> filenames;
  final int size;
  final int timestamp;
  final String fileLink;
  final String publicKey;

  FileMetadata(this.filenames, this.size, this.timestamp, this.fileLink, {this.publicKey = ""});

  FileMetadata.fromJson(Map<String, dynamic> json)
      : filenames = json['filenames'],
        size = json['size'],
        timestamp = json['timestamp'],
        fileLink = json['fileLink'],
        publicKey = json['publicKey'];


  Map<String, dynamic> toJson() =>
      {
        'filenames': filenames,
        'size' : size,
        'timestmap' : timestamp,
        'fileLink' : fileLink,
        'publicKey' : publicKey,
      };
}
class File {
  final String id;
  final String name;
  final String? preview;
  final String download;
  final String size;

  const File({
    required this.id,
    required this.name,
    required this.download,
    required this.size,
    required this.preview,
  });

  Map<String, Object?> toMap() {
    return {
      "type": "file",
      "mode": "preview",
      "content": id,
      "metadata": {
        "size": size,
        "name": name,
        "preview": preview,
        "download": download
      }
    };
  }
}

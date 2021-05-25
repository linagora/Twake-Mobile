class Attachment {
  final String id;
  final AttachmentType type;

  const Attachment({required this.id, required this.type});
}

enum AttachmentType { file }

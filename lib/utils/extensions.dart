extension StringExtension on String {
  bool get isNotReallyEmpty => this.trim().isNotEmpty;

  bool get isReallyEmpty => this.trim().isEmpty;

  // https://github.com/flutter/flutter/issues/18761
  String get overflow => this
      .replaceAll('', '\u{200B}')
      .toString();
}
//
// extension MemberExtension on List<Member?> {
//   List<String?> get ids => this.map((e) => e!.userId).toList();
// }
//
// extension UsersListExtension on List<User> {
//   void excludeUsers(List<User> toExclude) {
//     for (User user in toExclude) {
//       this.removeWhere((element) => element.id == user.id);
//     }
//   }
// }

extension ChunkExtension<T> on List<T> {
  List<List<T>> chunks(int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < this.length; i += chunkSize) {
      chunks.add(this.sublist(
        i,
        i + chunkSize > this.length ? this.length : i + chunkSize,
      ));
    }
    return chunks;
  }
}

extension StringExtension on String {
  bool get isNotReallyEmpty => this.trim().isNotEmpty;

  bool get isReallyEmpty => this.trim().isEmpty;
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

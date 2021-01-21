
extension StringExtension on String {
  bool get isNotReallyEmpty => this.trim().isNotEmpty;
  bool get isReallyEmpty => this.trim().isEmpty;
}
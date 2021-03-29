class TwacodeParser {
  final String original;
  Map<String, dynamic> twacode;

  TwacodeParser(this.original);

  static final RegExp REGEX_EMOJI = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');

  List<dynamic> parse(String text) {
    List<dynamic> twacode = [];
    List<dynamic> open = [];
    List<TwacodeType> stack = [];

    // for (var e in REGEX_EMOJI.allMatches(text)) {}
    List<int> running = [];
    List<dynamic> currentParent = twacode;

    for (var rune in text.runes) {
      final last = stack.isEmpty ? TwacodeType.Text : stack.last;
      if (rune == Delimiter.star) {
        if (last == TwacodeType.Italic) {
          twacode.add({
            "start": "*",
            "content": String.fromCharCodes(running),
            "end": "*"
          });
          stack.removeLast();
          running.clear();
        } else {}
      } else if (rune == Delimiter.underline) {
        break;
      } else if (rune == Delimiter.tilde) {
        break;
      } else if (rune == Delimiter.gt) {
        break;
      } else if (rune == Delimiter.tick) {
        break;
      } else if (rune == Delimiter.at) {
        break;
      }
      running.add(rune);
    }
    return twacode;
  }
}

class ASTNode {
  TwacodeType type;
  List<ASTNode> children;
  String text;

  dynamic transform() {
    Map<String, dynamic> map = {};
    switch (this.type) {
      case TwacodeType.Text:
        return this.text;

      case TwacodeType.LineBreak:
        map['start'] = '';
        map['end'] = '\n';
        map['content'] = [];
        break;

      case TwacodeType.InlineCode:
        map['start'] = '`';
        map['end'] = '`';
        map['content'] = this.text;
        break;

      case TwacodeType.MultiLineCode:
        map['start'] = '```';
        map['end'] = '```';
        map['content'] = this.text;
        break;

      case TwacodeType.Underline:
        map['start'] = '__';
        map['end'] = '__';
        map['content'] = children.map((c) => c.transform()).toList();
        break;

      case TwacodeType.StrikeThrough:
        map['start'] = '~~';
        map['end'] = '~~';
        map['content'] = children.map((c) => c.transform()).toList();
        break;

      case TwacodeType.Bold:
        map['start'] = '**';
        map['end'] = '**';
        map['content'] = children.map((c) => c.transform()).toList();
        break;

      case TwacodeType.Italic:
        map['start'] = '_';
        map['end'] = '_';
        map['content'] = children.map((c) => c.transform()).toList();
        break;

      case TwacodeType.Quote:
        map['start'] = '>';
        map['content'] = children.map((c) => c.transform()).toList();
        break;

      case TwacodeType.User:
        map['start'] = '@';
        map['content'] = this.text;
        break;

      case TwacodeType.Channel:
        map['start'] = '#';
        map['content'] = this.text;
        break;

      case TwacodeType.Url:
        map['type'] = 'url';
        map['content'] = this.text;
        break;

      case TwacodeType.Email:
        map['type'] = 'email';
        map['content'] = this.text;
        break;

      case TwacodeType.Email:
        map['type'] = 'email';
        map['content'] = this.text;
        break;

      default:
        throw Exception('Unsupported type');
    }
  }
}

enum TwacodeType {
  Text,
  LineBreak,
  InlineCode,
  MultiLineCode,
  Underline,
  StrikeThrough,
  Bold,
  Italic,
  Quote,
  User,
  Channel,
  Url,
  Email
}

class Delimiter {
  static int star = '*'.codeUnitAt(0);
  static int underline = '_'.codeUnitAt(0);
  static int tilde = '~'.codeUnitAt(0);
  static int gt = '>'.codeUnitAt(0);
  static int tick = '`'.codeUnitAt(0);
  static int at = '@'.codeUnitAt(0);
}

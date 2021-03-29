class TwacodeParser {
  final String original;
  Map<String, dynamic> twacode;

  TwacodeParser(this.original);

  static final RegExp regexEmoji = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
  // for (var e in REGEX_EMOJI.allMatches(text)) {}

  ASTNode parse(String text, [TwacodeType parent = TwacodeType.Root]) {
    ASTNode node = ASTNode();
    String running = "";

    for (int i = 0; i < text.length; i++) {
      var rune = text[i];
      if (rune == Delimiter.star) {
        if (parent == TwacodeType.Italic) {}
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
      running += rune;
    }
    return node;
  }
}

class ASTNode {
  TwacodeType type;
  List<ASTNode> children;
  String text;

  dynamic transform() {
    Map<String, dynamic> map = {};
    switch (this.type) {
      case TwacodeType.Root:
        return this.children.map((c) => c.transform()).toList();

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

      default:
        throw Exception('Unsupported type');
    }
  }
}

enum TwacodeType {
  Root,
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
  static String star = '*';
  static String underline = '_';
  static String tilde = '~';
  static String gt = '>';
  static String tick = '`';
  static String at = '@';
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tuple/tuple.dart';

class TwacodeParser {
  final String original;
  static final RegExp userMatch = RegExp('([a-zA-z0-9_]+):([a-zA-z0-9-]+)');

  List<ASTNode> nodes = [];

  TwacodeParser(this.original) {
    parse();
  }

  List<dynamic> get message => nodes.map((n) => n.transform()).toList();

  void parse() {
    int start = 0;
    for (int i = 0; i < original.length - 1; i++) {
      // Bold text
      if (original[i] == Delim.star && original[i + 1] == Delim.star) {
        final index = this.doesCloseBold(i + 2);
        if (index != 0) {
          final acc = original.substring(start, i);
          if (acc.isNotEmpty) {
            this.nodes.add(ASTNode(type: TType.Text, text: acc));
          }
          this.nodes.add(ASTNode(
              type: TType.Bold, text: original.substring(i + 2, index - 2)));
          start = index;
          i = index - 1;
        }
      }
      // Underline text
      else if (original[i] == Delim.underline &&
          original[i + 1] == Delim.underline) {
        final index = doesCloseUnderline(i + 2);
        if (index != 0) {
          final acc = original.substring(start, i);
          if (acc.isNotEmpty) {
            this.nodes.add(ASTNode(type: TType.Text, text: acc));
          }
          this.nodes.add(ASTNode(
                type: TType.Underline,
                text: original.substring(i + 2, index - 2),
              ));
          start = index;
          i = index - 1;
        }
      }
      // Italic text
      else if (original[i] == Delim.underline &&
          original[i + 1] != Delim.underline) {
        final index = doesCloseItalic(i + 1);
        if (index != 0) {
          final acc = original.substring(start, i);
          if (acc.isNotEmpty) {
            this.nodes.add(ASTNode(type: TType.Text, text: acc));
          }
          this.nodes.add(ASTNode(
                type: TType.Italic,
                text: original.substring(i + 1, index - 1),
              ));
          start = index;
          i = index - 1;
        }
      }
      // StrikeThrough text
      else if (original[i] == Delim.tilde && original[i + 1] == Delim.tilde) {
        final index = doesCloseStrikeThrough(i + 2);
        if (index != 0) {
          final acc = original.substring(start, i);
          if (acc.isNotEmpty) {
            this.nodes.add(ASTNode(type: TType.Text, text: acc));
          }
          this.nodes.add(ASTNode(
                type: TType.StrikeThrough,
                text: original.substring(i + 2, index - 2),
              ));
          start = index;
          i = index - 1;
        }
      }
      // Newline text
      else if (original[i] == Delim.lf) {
        final acc = original.substring(start, i);
        if (acc.trimRight().isNotEmpty) {
          this.nodes.add(ASTNode(type: TType.Text, text: acc));
        }
        this.nodes.add(ASTNode(
              type: TType.LineBreak,
              text: "",
            ));
        start = i + 1;
      }
      // Quote detection
      else if (original[i] == Delim.gt) {
        if (nodes.isEmpty || nodes.last.type == TType.LineBreak) {
          int index = this.hasLineFeed(i + 1);
          index = index != 0 ? index : original.length + 1;
          this.nodes.add(ASTNode(
                type: TType.Quote,
                text: original.substring(i + 1, index - 1),
              ));
          start = index;
          i = index - 1;
        }
      }
      // Username
      else if (original[i] == Delim.at &&
          (i == 0 ||
              original[i - 1] == Delim.ws ||
              original[i - 1] == Delim.lf)) {
        final index = this.isUser(i + 1);
        if (index != 0) {
          final acc = original.substring(start, i);
          if (acc.isNotEmpty) {
            this.nodes.add(ASTNode(type: TType.Text, text: acc));
          }
          this.nodes.add(ASTNode(
                type: TType.User,
                text: original.substring(i + 1, index),
              ));
          start = index;
          i = index - 1;
        }
      }
      // Email
      else if (original[i] == Delim.at &&
          (i != 0 &&
              original[i - 1] != Delim.ws &&
              original[i - 1] != Delim.lf)) {
        final range = isEmail(i);
        if (range.item1 != 0 || range.item2 != 0) {
          this.nodes.add(
                ASTNode(
                  type: TType.Text,
                  text: original.substring(start, range.item1),
                ),
              );
          this.nodes.add(ASTNode(
                type: TType.Email,
                text: original.substring(range.item1, range.item2),
              ));
          start = range.item2;
          i = range.item2 - 1;
        }
      }
      // URL with full protocol description like https://hello.world
      else if (original[i] == Delim.slash && original[i + 1] == Delim.slash) {
        final range = this.isUrl(i + 1);
        if (range.item1 != 0 || range.item2 != 0) {
          this.nodes.add(
                ASTNode(
                  type: TType.Text,
                  text: original.substring(start, range.item1),
                ),
              );
          this.nodes.add(ASTNode(
                type: TType.Url,
                text: original.substring(range.item1, range.item2),
              ));
          start = range.item2;
          i = range.item2 - 1;
        }
      }
      // InlineCode text
      else if (original[i] == Delim.tick && original[i + 1] != Delim.tick) {
        final index = this.doesCloseInlineCode(i + 1);
        if (index != 0) {
          final acc = original.substring(start, i);
          if (acc.trimRight().isNotEmpty) {
            this.nodes.add(ASTNode(type: TType.Text, text: acc));
          }
          this.nodes.add(ASTNode(
                type: TType.InlineCode,
                text: original.substring(i + 1, index - 1),
              ));
          start = index;
          i = index - 1;
        }
      }
      // MultiLineCode text
      else if (original[i] == Delim.tick &&
          original[i + 1] == Delim.tick &&
          i + 2 < original.length &&
          original[i + 2] == Delim.tick) {
        final index = this.doesCloseMultiCode(i + 3);
        if (index != 0) {
          final acc = original.substring(start, i);
          if (acc.trimRight().isNotEmpty) {
            this.nodes.add(
                  ASTNode(
                    type: TType.Text,
                    text: acc,
                  ),
                );
          }
          this.nodes.add(ASTNode(
                type: TType.MultiLineCode,
                text: original.substring(i + 3, index - 3),
              ));
          start = index;
          i = index - 1;
        }
      }
      // #Channel
      else if (original[i] == Delim.pound &&
          original[i + 1] != Delim.ws &&
          original[i + 1] != Delim.lf) {
        final index = this.isChannel(i + 1);
        final acc = original.substring(start, i);
        if (acc.isNotEmpty) {
          this.nodes.add(
                ASTNode(
                  type: TType.Text,
                  text: acc,
                ),
              );
        }
        this.nodes.add(ASTNode(
              type: TType.Channel,
              text: original.substring(i + 1, index),
            ));
        start = index;
        i = index - 1;
      }
    }
    if (start < original.length) {
      this.nodes.add(ASTNode(
            type: TType.Text,
            text: original.substring(start).trimRight(),
          ));
    }
    if (this.nodes.first.text.trimLeft().isEmpty) {
      this.nodes.removeAt(0);
    }
    while (this.nodes.last.text.trim().isEmpty) {
      this.nodes.removeLast();
    }
  }

  int doesCloseBold(int i) {
    final len = original.length - 1;
    for (int j = i; j < len && original[j] != '\n'; j++) {
      if (original[j] == Delim.star && original[j + 1] == Delim.star) {
        return j + 2;
      }
    }
    return 0;
  }

  int doesCloseItalic(int i) {
    final len = original.length;
    for (int j = i; j < len && original[j] != '\n'; j++) {
      if (original[j] == Delim.underline) {
        return j + 1;
      }
    }
    return 0;
  }

  Tuple2 isEmail(int i) {
    var start = i;
    var end = i;
    while (start > 0) {
      final cur = original[start - 1];
      if (cur == Delim.ws || cur == Delim.lf) {
        break;
      }
      start -= 1;
    }
    while (end < original.length) {
      final cur = original[end];
      if (cur == Delim.ws || cur == Delim.lf) {
        break;
      }
      end += 1;
    }
    final parts = original.substring(start, end).split('@');
    if (parts[0].isEmpty || parts[1].isEmpty) {
      return Tuple2(0, 0);
    }
    final subparts = parts[1].split('.');
    final p1 = parts[0].codeUnits.every((c) => c > 32 && c < 127) &&
        parts[0].codeUnits.every((c) => c > 32 && c < 127);
    final p2 =
        subparts.length > 1 && subparts[0].isNotEmpty && subparts[1].isNotEmpty;
    if (p1 && p2) {
      return Tuple2(start, end);
    }

    return Tuple2(0, 0);
  }

  Tuple2 isUrl(int i) {
    var start = i;
    var end = i;
    while (start > 0) {
      final cur = original[start - 1];
      if (cur == Delim.ws || cur == Delim.lf) {
        break;
      }
      start -= 1;
    }
    while (end < original.length) {
      final cur = original[end];
      if (cur == Delim.ws || cur == Delim.lf) {
        break;
      }
      end += 1;
    }
    final parts = original.substring(start, end).split('://');
    if (parts[0].isEmpty || parts[1].isEmpty) {
      return Tuple2(0, 0);
    }
    final p1 = parts[0] == 'http' || parts[0] == 'https';
    // pretty dumb check, buut, for now it will do
    final p2 = parts[1].contains('.');
    if (p1 && p2) {
      return Tuple2(start, end);
    }

    return Tuple2(0, 0);
  }

  int doesCloseUnderline(int i) {
    final len = original.length - 1;
    for (int j = i; j < len && original[j] != '\n'; j++) {
      if (original[j] == Delim.underline &&
          original[j + 1] == Delim.underline) {
        return j + 2;
      }
    }
    return 0;
  }

  int isUser(int i) {
    for (int j = i; j < original.length; j++) {
      if (original[j] == Delim.ws || original[j] == Delim.lf) {
        if (userMatch.hasMatch(original.substring(i, j))) {
          return j;
        } else {
          return 0;
        }
      }
    }
    if (userMatch.hasMatch(original.substring(i))) {
      return original.length;
    } else {
      return 0;
    }
  }

  int isChannel(int i) {
    for (int j = i; j < original.length; j++) {
      if (original[j] == Delim.ws || original[j] == Delim.lf) {
        return j;
      }
    }
    return original.length;
  }

  int doesCloseStrikeThrough(int i) {
    final len = original.length - 1;
    for (int j = i; j < len && original[j] != '\n'; j++) {
      if (original[j] == Delim.tilde && original[j + 1] == Delim.tilde) {
        return j + 2;
      }
    }
    return 0;
  }

  int doesCloseInlineCode(int i) {
    final len = original.length;
    for (int j = i; j < len && original[j] != '\n'; j++) {
      if (original[j] == Delim.tick) {
        return j + 1;
      }
    }
    return 0;
  }

  int doesCloseMultiCode(int i) {
    final len = original.length;
    int ticks = 0;
    for (int j = i; j < len; j++) {
      if (original[j] == Delim.tick) {
        if (ticks == 2) {
          return j + 1;
        } else {
          ticks += 1;
        }
      } else {
        ticks = 0;
      }
    }
    return 0;
  }

  int hasLineFeed(int i) {
    final len = original.length;
    for (int j = i; j < len; j++) {
      if (original[j] == Delim.lf) {
        return j;
      }
    }
    return 0;
  }
}

class ASTNode {
  TType type;
  String text;
  ASTNode({this.type, this.text});

  dynamic transform() {
    Map<String, dynamic> map = {};
    switch (this.type) {
      case TType.Text:
        return this.text;

      case TType.LineBreak:
        map['start'] = '\n';
        map['end'] = '';
        map['content'] = [];
        break;

      case TType.InlineCode:
        map['start'] = '`';
        map['end'] = '`';
        map['content'] = this.text;
        break;

      case TType.MultiLineCode:
        map['start'] = '```';
        map['end'] = '```';
        map['content'] = this.text;
        break;

      case TType.Underline:
        map['start'] = '__';
        map['end'] = '__';
        map['content'] = this.text;
        break;

      case TType.StrikeThrough:
        map['start'] = '~~';
        map['end'] = '~~';
        map['content'] = this.text;
        break;

      case TType.Bold:
        map['start'] = '**';
        map['end'] = '**';
        map['content'] = this.text;
        break;

      case TType.Italic:
        map['start'] = '_';
        map['end'] = '_';
        map['content'] = this.text;
        break;

      case TType.Quote:
        map['start'] = '>';
        map['content'] = this.text;
        break;

      case TType.User:
        map['start'] = '@';
        map['content'] = this.text;
        break;

      case TType.Channel:
        map['start'] = '#';
        map['content'] = this.text;
        break;

      case TType.Url:
        map['type'] = 'url';
        map['content'] = this.text;
        break;

      case TType.Email:
        map['type'] = 'email';
        map['content'] = this.text;
        break;

      default:
        throw Exception('Unsupported twacode type');
    }
    return map;
  }
}

enum TType {
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
  Emoji,
  Email,
  Unknown
}

class Delim {
  static String star = '*';
  static String underline = '_';
  static String tilde = '~';
  static String gt = '>';
  static String tick = '`';
  static String slash = '/';
  static String at = '@';
  static String pound = '#';
  static String lf = '\n';
  static String ws = ' ';
}

// Rewrite the renderer once twake chooses
// one and only format for data representation
class TwacodeRenderer {
  final List<dynamic> twacode;
  List<InlineSpan> spans;

  TwacodeRenderer(this.twacode) {
    spans = render(this.twacode);
  }

  TextStyle getStyle(TType type) {
    TextStyle style;
    switch (type) {
      case TType.InlineCode:
        style = const TextStyle(
          fontFamily: MONOSPACE,
          backgroundColor: Colors.black87,
          color: Colors.white70,
        );
        break;

      case TType.MultiLineCode:
        style = TextStyle(
          fontFamily: MONOSPACE,
          backgroundColor: Colors.black87,
          color: Colors.white70,
        );
        break;

      case TType.Underline:
        style = TextStyle(
          decoration: TextDecoration.underline,
        );
        break;

      case TType.StrikeThrough:
        style = TextStyle(
          decoration: TextDecoration.lineThrough,
        );
        break;

      case TType.Bold:
        style = TextStyle(
          fontWeight: FontWeight.bold,
        );
        break;

      case TType.Italic:
        style = TextStyle(
          fontStyle: FontStyle.italic,
        );
        break;

      case TType.Quote:
        style = TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.black,
        );
        break;

      case TType.User:
        style = TextStyle(
          color: Colors.lightBlue,
        );
        break;

      case TType.Channel:
        style = TextStyle(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        );
        break;

      case TType.Url:
        style = TextStyle(color: Colors.blue);
        break;

      case TType.Email:
        style = TextStyle(color: Colors.purple);
        break;

      default:
        style = TextStyle(color: Colors.black, fontFamily: DEFAULT);
    }
    return style;
  }

  RichText get message => RichText(
        text: TextSpan(
          children: this.spans,
          style: getStyle(TType.Text),
        ),
      );

  List<InlineSpan> render(List<dynamic> twacode, [parent = false]) {
    List<InlineSpan> spans = [];

    for (int i = 0; i < twacode.length; i++) {
      if (twacode[i] is String) {
        spans.add(TextSpan(text: twacode[i], style: getStyle(TType.Text)));
      } else if (twacode[i] is List) {
        spans.addAll(render(twacode[i], true));
      } else if (twacode[i] is Map) {
        final t = twacode[i];
        TType type;
        if (t['type'] != null) {
          switch (t['type']) {
            case 'text':
              type = TType.Text;
              break;
            case 'url':
              type = TType.Url;
              break;
            case 'user':
              type = TType.User;
              break;
            case 'email':
              type = TType.Email;
              break;
            default:
              type = TType.Unknown;
          }
        } else if (t['start'] != null) {
          switch (t['start']) {
            case ':':
              type = TType.Emoji;
              break;
            case '\n':
              type = TType.LineBreak;
              break;
            case '**':
              type = TType.Bold;
              break;
            case '*':
            case '_':
              type = TType.Italic;
              break;
            case '__':
              type = TType.Underline;
              break;
            case '~~':
              type = TType.StrikeThrough;
              break;
            case '@':
              type = TType.User;
              break;
            case '>':
              type = TType.Quote;
              break;
            case '`':
              type = TType.InlineCode;
              break;
            case '```':
              type = TType.MultiLineCode;
              break;
            case '#':
              type = TType.Channel;
              break;
            default:
              type = TType.Unknown;
          }
        }
        if (type == TType.MultiLineCode) {
          if (spans.isNotEmpty)
            spans.add(
              TextSpan(
                text: '\n',
                style: getStyle(TType.LineBreak),
              ),
            );
          spans.add(
            TextSpan(
              text: t['content'],
              style: getStyle(type),
            ),
          );
        } else if (type == TType.Quote) {
          InlineSpan text;

          if (t['content'] is List) {
            final items = render(t['content'], true);
            text = TextSpan(children: items, style: getStyle(type));
          } else {
            // t['content'] is String
            text = TextSpan(text: t['content'], style: getStyle(type));
          }

          spans.add(
            WidgetSpan(
              child: Container(
                child: RichText(text: text),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      width: 2.0,
                      color: Colors.grey,
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: 8,
                  bottom: 3,
                  top: 3,
                ),
              ),
            ),
          );
        } else if (type == TType.LineBreak) {
          spans.add(TextSpan(text: '\n', style: getStyle(TType.LineBreak)));
        } else if (t['content'] is List) {
          final items = render(t['content'], true);
          spans.add(TextSpan(children: items, style: getStyle(type)));
        } else {
          if (type == TType.Channel) {
            t['content'] = '#' + t['content'];
          } else if (type == TType.User) {
            t['content'] = '@' + t['content'];
          }
          spans.add(TextSpan(text: t['content'], style: getStyle(type)));
        }
      }
    }
    return spans;
  }
}

const MONOSPACE = 'PTMono';
const DEFAULT = 'PT';

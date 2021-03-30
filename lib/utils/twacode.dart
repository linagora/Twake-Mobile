import 'dart:math';

class TwacodeParser {
  final String original;

  List<ASTNode> nodes = [];

  TwacodeParser(this.original) {
    parse();
  }

  void parse() {
    int start = 0;
    for (var i = 0; i < original.length; i++) {
      final rune = original[i];
      if (rune == Delimiter.star) {
        print("GOT STAR");
        final next = original[i + 1];
        if (next == Delimiter.star) {
          print("GOT ANOTHER STAR");
          bool complete = false;
          int endline = i + 2;
          for (var j = i + 2;
              j < original.length - 1 && original[j + 1] != '\n';
              endline = ++j) {
            if (original[j] == Delimiter.star &&
                original[j + 1] == Delimiter.star) {
              print("CLOSING BOLD");
              if (i != 0) {
                nodes.add(
                  ASTNode(
                    type: TwacodeType.Text,
                    text: original.substring(start, i),
                  ),
                );
              }
              nodes.add(
                ASTNode(
                  type: TwacodeType.Bold,
                  text: original.substring(i + 2, j),
                ),
              );
              complete = true;
              i = j + 2;
              start = j + 2;
              break;
            }
          }
          if (!complete) {
            nodes.add(
              ASTNode(
                type: TwacodeType.Text,
                text: original.substring(start, endline),
              ),
            );
            i = start = endline;
          }
        } else {
          for (var j = i + 1;
              j < original.length - 1 && original[j + 1] != '\n';
              endline = ++j) {
            if (original[j] == Delimiter.star &&
                original[j + 1] == Delimiter.star) {
              print("CLOSING BOLD");
              if (i != 0) {
                nodes.add(
                  ASTNode(
                    type: TwacodeType.Text,
                    text: original.substring(start, i),
                  ),
                );
              }
              nodes.add(
                ASTNode(
                  type: TwacodeType.Bold,
                  text: original.substring(i + 2, j),
                ),
              );
              complete = true;
              i = j + 2;
              start = j + 2;
              break;
            }
          }
          if (!complete) {
            nodes.add(
              ASTNode(
                type: TwacodeType.Text,
                text: original.substring(start, endline),
              ),
            );
            i = start = endline;
          }
        }
      }
    }
  }

  bool hasTripleTick(String line) {
    return line.contains('```');
  }
}

class ASTNode {
  TwacodeType type;
  String text;
  ASTNode({this.type, this.text});

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
        map['content'] = this.text;
        break;

      case TwacodeType.StrikeThrough:
        map['start'] = '~~';
        map['end'] = '~~';
        map['content'] = this.text;
        break;

      case TwacodeType.Bold:
        map['start'] = '**';
        map['end'] = '**';
        map['content'] = this.text;
        break;

      case TwacodeType.Italic:
        map['start'] = '_';
        map['end'] = '_';
        map['content'] = this.text;
        break;

      case TwacodeType.Quote:
        map['start'] = '>';
        map['content'] = this.text;
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
        throw Exception('Unsupported twacode type');
    }
    return map;
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
  static String lf = '\n';
}

int main() {
  final parsed = TwacodeParser("**HELLO * HELLO ** OUCH ** I *\n");
  print("NODES: ${parsed.nodes.map((el) => el.transform())}");
  return 1;
}

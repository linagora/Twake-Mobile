import 'dart:io';
// import 'dart:isolate';
//
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuple/tuple.dart';
import 'package:twake/utils/emojis.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:twake/services/service_bundle.dart';

final RegExp idMatch = RegExp(':([a-zA-z0-9-]+)');

class TwacodeParser {
  final String? original;

  List<ASTNode> nodes = [];

  TwacodeParser(this.original) {
    parse();
  }

  List<dynamic> get message => nodes.map((n) => n.transform()).toList();

  void parse() {
    int start = 0;
    for (int i = 0; i < original!.length - 1; i++) {
      // Bold text
      if (original![i] == Delim.star && original![i + 1] == Delim.star) {
        final index = this.doesCloseBold(i + 2);
        if (index != 0) {
          final acc = original!.substring(start, i);
          if (acc.isNotEmpty) {
            this.nodes.add(ASTNode(type: TType.Text, text: acc));
          }
          this.nodes.add(ASTNode(
              type: TType.Bold, text: original!.substring(i + 2, index - 2)));
          start = index;
          i = index - 1;
        }
      }
      // Underline text
      else if (original![i] == Delim.underline &&
          original![i + 1] == Delim.underline) {
        final index = doesCloseUnderline(i + 2);
        if (index != 0) {
          final acc = original!.substring(start, i);
          if (acc.isNotEmpty) {
            this.nodes.add(ASTNode(type: TType.Text, text: acc));
          }
          this.nodes.add(ASTNode(
                type: TType.Underline,
                text: original!.substring(i + 2, index - 2),
              ));
          start = index;
          i = index - 1;
        }
      }
      // Italic text
      else if (original![i] == Delim.underline &&
          original![i + 1] != Delim.underline) {
        final index = doesCloseItalic(i + 1);
        if (index != 0) {
          final acc = original!.substring(start, i);
          if (acc.isNotEmpty) {
            this.nodes.add(ASTNode(type: TType.Text, text: acc));
          }
          this.nodes.add(ASTNode(
                type: TType.Italic,
                text: original!.substring(i + 1, index - 1),
              ));
          start = index;
          i = index - 1;
        }
      }
      // StrikeThrough text
      else if (original![i] == Delim.tilde && original![i + 1] == Delim.tilde) {
        final index = doesCloseStrikeThrough(i + 2);
        if (index != 0) {
          final acc = original!.substring(start, i);
          if (acc.isNotEmpty) {
            this.nodes.add(ASTNode(type: TType.Text, text: acc));
          }
          this.nodes.add(ASTNode(
                type: TType.StrikeThrough,
                text: original!.substring(i + 2, index - 2),
              ));
          start = index;
          i = index - 1;
        }
      }
      // Newline text
      else if (original![i] == Delim.lf) {
        final acc = original!.substring(start, i);
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
      else if (original![i] == Delim.gt) {
        if (nodes.isEmpty || nodes.last.type == TType.LineBreak) {
          // Multline Quote detection
          if (original![i + 1] == Delim.gt &&
              i + 2 < original!.length &&
              original![i + 2] == Delim.gt) {
            this.nodes.add(ASTNode(
                  type: TType.MultiQuote,
                  text: TwacodeParser(original!.substring(i + 3).trimLeft())
                      .message,
                ));
            start = i = original!.length;
            break;
          }

          int index = this.hasLineFeed(i + 1);
          index = index != 0 ? index : original!.length;
          this.nodes.add(ASTNode(
                type: TType.Quote,
                text: original!.substring(i + 1, index),
              ));
          start = index;
          i = index - 1;
        }
      }
      // Username
      else if (original![i] == Delim.at &&
          (i == 0 ||
              original![i - 1] == Delim.ws ||
              original![i - 1] == Delim.lf)) {
        final index = this.isUser(i + 1);
        if (index != 0) {
          final acc = original!.substring(start, i);
          if (acc.isNotEmpty) {
            this.nodes.add(ASTNode(type: TType.Text, text: acc));
          }
          this.nodes.add(ASTNode(
                type: TType.User,
                text: original!.substring(i + 1, index),
              ));
          start = index;
          i = index - 1;
        }
      }
      // Email
      else if (original![i] == Delim.at &&
          (i != 0 &&
              original![i - 1] != Delim.ws &&
              original![i - 1] != Delim.lf)) {
        final range = isEmail(i);
        if (range.item1 != 0 || range.item2 != 0) {
          this.nodes.add(
                ASTNode(
                  type: TType.Text,
                  text: original!.substring(start, range.item1),
                ),
              );
          this.nodes.add(ASTNode(
                type: TType.Email,
                text: original!.substring(range.item1, range.item2),
              ));
          start = range.item2;
          i = range.item2 - 1;
        }
      }
      // URL with full protocol description like https://hello.world
      else if (original![i] == Delim.slash && original![i + 1] == Delim.slash) {
        final range = this.isUrl(i + 1);
        if (range.item1 != 0 || range.item2 != 0) {
          this.nodes.add(
                ASTNode(
                  type: TType.Text,
                  text: original!.substring(start, range.item1),
                ),
              );
          this.nodes.add(ASTNode(
                type: TType.Url,
                text: original!.substring(range.item1, range.item2),
              ));
          start = range.item2;
          i = range.item2 - 1;
        }
      }
      // InlineCode text
      else if (original![i] == Delim.tick && original![i + 1] != Delim.tick) {
        final index = this.doesCloseInlineCode(i + 1);
        if (index != 0) {
          final acc = original!.substring(start, i);
          if (acc.trimRight().isNotEmpty) {
            this.nodes.add(ASTNode(type: TType.Text, text: acc));
          }
          this.nodes.add(ASTNode(
                type: TType.InlineCode,
                text: original!.substring(i + 1, index - 1),
              ));
          start = index;
          i = index - 1;
        }
      }
      // MultiLineCode text
      else if (original![i] == Delim.tick &&
          original![i + 1] == Delim.tick &&
          i + 2 < original!.length &&
          original![i + 2] == Delim.tick) {
        final index = this.doesCloseMultiCode(i + 3);
        if (index != 0) {
          final acc = original!.substring(start, i);
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
                text: original!.substring(i + 3, index - 3),
              ));
          start = index;
          i = index - 1;
        }
      }
      // #Channel
      else if (original![i] == Delim.pound &&
          original![i + 1] != Delim.ws &&
          original![i + 1] != Delim.lf) {
        final index = this.isChannel(i + 1);
        final acc = original!.substring(start, i);
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
              text: original!.substring(i + 1, index),
            ));
        start = index;
        i = index - 1;
      }
    }
    if (start < original!.length) {
      this.nodes.add(ASTNode(
            type: TType.Text,
            text: original!.substring(start).trimRight(),
          ));
    }
    if (nodes.isEmpty) return;
    if (this.nodes.first.text is String &&
        this.nodes.first.text.trimLeft().isEmpty) {
      this.nodes.removeAt(0);
    }
    while (
        this.nodes.last.text is String && this.nodes.last.text.trim().isEmpty) {
      this.nodes.removeLast();
    }
  }

  int doesCloseBold(int i) {
    final len = original!.length - 1;
    for (int j = i; j < len && original![j] != '\n'; j++) {
      if (original![j] == Delim.star && original![j + 1] == Delim.star) {
        return j + 2;
      }
    }
    return 0;
  }

  int doesCloseItalic(int i) {
    final len = original!.length;
    for (int j = i; j < len && original![j] != '\n'; j++) {
      if (original![j] == Delim.underline) {
        return j + 1;
      }
    }
    return 0;
  }

  Tuple2 isEmail(int i) {
    var start = i;
    var end = i;
    while (start > 0) {
      final cur = original![start - 1];
      if (cur == Delim.ws || cur == Delim.lf) {
        break;
      }
      start -= 1;
    }
    while (end < original!.length) {
      final cur = original![end];
      if (cur == Delim.ws || cur == Delim.lf) {
        break;
      }
      end += 1;
    }
    final parts = original!.substring(start, end).split('@');
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
      final cur = original![start - 1];
      if (cur == Delim.ws || cur == Delim.lf) {
        break;
      }
      start -= 1;
    }
    while (end < original!.length) {
      final cur = original![end];
      if (cur == Delim.ws || cur == Delim.lf) {
        break;
      }
      end += 1;
    }
    final parts = original!.substring(start, end).split('://');
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
    final len = original!.length - 1;
    for (int j = i; j < len && original![j] != '\n'; j++) {
      if (original![j] == Delim.underline &&
          original![j + 1] == Delim.underline) {
        return j + 2;
      }
    }
    return 0;
  }

  int isUser(int i) {
    for (int j = i; j < original!.length; j++) {
      if (original![j] == Delim.ws || original![j] == Delim.lf) {
        if (idMatch.hasMatch(original!.substring(i, j))) {
          return j;
        } else {
          return 0;
        }
      }
    }
    if (idMatch.hasMatch(original!.substring(i))) {
      return original!.length;
    } else {
      return 0;
    }
  }

  int isChannel(int i) {
    for (int j = i; j < original!.length; j++) {
      if (original![j] == Delim.ws || original![j] == Delim.lf) {
        return j;
      }
    }
    return original!.length;
  }

  int doesCloseStrikeThrough(int i) {
    final len = original!.length - 1;
    for (int j = i; j < len && original![j] != '\n'; j++) {
      if (original![j] == Delim.tilde && original![j + 1] == Delim.tilde) {
        return j + 2;
      }
    }
    return 0;
  }

  int doesCloseInlineCode(int i) {
    final len = original!.length;
    for (int j = i; j < len && original![j] != '\n'; j++) {
      if (original![j] == Delim.tick) {
        return j + 1;
      }
    }
    return 0;
  }

  int doesCloseMultiCode(int i) {
    final len = original!.length;
    int ticks = 0;
    for (int j = i; j < len; j++) {
      if (original![j] == Delim.tick) {
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
    final len = original!.length;
    for (int j = i; j < len; j++) {
      if (original![j] == Delim.lf) {
        return j;
      }
    }
    return 0;
  }
}

class ASTNode {
  TType? type;
  dynamic text;
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

      case TType.MultiQuote:
        map['start'] = '>>>';
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
  MultiQuote,
  User,
  Channel,
  Url,
  Emoji,
  Email,
  Icon,
  File,
  Nop,
  System,
  Attachment,
  Compile,
  Unknown,
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
  List<dynamic>? twacode;
  List<InlineSpan>? spans;

  TwacodeRenderer({this.twacode, TextStyle? parentStyle}) {
    if (parentStyle == null)
      parentStyle = getStyle(TType.Text).copyWith(color: Colors.black);
    this.twacode!.addAll(this.extractFiles(this.twacode!));
    spans = render(twacode: this.twacode!, parentStyle: parentStyle);
  }

  // Files should only occur in the end of the twacode structure
  // they are usually put inside of nop type object's content
  // or rarely exist as a standalon object in the end of the list
  List<dynamic> extractFiles(List<dynamic> content) {
    List<dynamic> files = [];
    final last = content.last;

    if (last is List) {
      files.addAll(extractFiles(last));
    }

    if (last is Map) {
      if (last['type'] == 'file') {
        files.add(last);
        content.removeLast();
      } else if (last['content'] is List) {
        var inner = last['content'] as List;
        for (int i = 0; i < inner.length; i++)
          if (inner[i] is Map && inner[i]['type'] == 'file') {
            files.add(inner[i]);
            inner.removeAt(i);
          }
      }
    }
    return files;
  }

  TextStyle getStyle(TType? type) {
    TextStyle style;
    switch (type) {
      case TType.InlineCode:
        style = const TextStyle(
          height: 1.1,
          fontFamily: MONOSPACE,
          // backgroundColor: Color.fromRGBO(0xCC, 0xE6, 0xFF, 1),
          // color: Color.fromRGBO(0x75, 0x1A, 0xFF, 1),
        );
        break;

      case TType.MultiLineCode:
        style = TextStyle(
          fontFamily: MONOSPACE,
          // backgroundColor: Color.fromRGBO(0xCC, 0xE6, 0xFF, 1),
          // color: Color.fromRGBO(0x75, 0x1A, 0xFF, 1),
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
          // color: Colors.black,
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

      case TType.Attachment:
        style = TextStyle(fontStyle: FontStyle.italic);
        break;

      case TType.File:
        style = TextStyle(fontStyle: FontStyle.italic);
        break;

      case TType.Email:
        style = TextStyle(color: Colors.purple);
        break;

      case TType.Unknown:
        style = TextStyle(fontStyle: FontStyle.italic, fontFamily: MONOSPACE);
        break;

      default:
        style = TextStyle(
          // color: Colors.black,
          fontFamily: DEFAULT,
          // fontSize: 17,
        );
    }
    return style;
  }

  RichText get message {
    return RichText(
      text: TextSpan(
        children: this.spans,
      ),
    );
  }

  List<InlineSpan> render(
      {required List<dynamic> twacode, TextStyle? parentStyle}) {
    List<InlineSpan> spans = [];

    for (int i = 0; i < twacode.length; i++) {
      if (twacode[i] is String) {
        spans.add(
          TextSpan(
            text:
                spans.isEmpty ? (twacode[i] as String).trimLeft() : twacode[i],
            style: parentStyle!.merge(
              getStyle(TType.Text),
            ),
          ),
        );
      } else if (twacode[i] is List) {
        spans.addAll(render(twacode: twacode[i], parentStyle: parentStyle));
      } else if (twacode[i] is Map) {
        final t = twacode[i];
        TType? type;
        if (t['type'] != null) {
          switch (t['type']) {
            case 'nop':
              type = TType.Nop;
              break;
            case 'br':
              type = TType.LineBreak;
              break;
            case 'bold':
              type = TType.Bold;
              break;
            case 'system':
              type = TType.System;
              break;
            case 'attachment':
              type = TType.Attachment;
              break;
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
            case 'icon':
              type = TType.Icon;
              break;
            case 'file':
              type = TType.File;
              break;
            case 'compile':
              type = TType.Compile;
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
            case '>>>':
              type = TType.MultiQuote;
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
          final style = getStyle(type);
          spans.add(
            WidgetSpan(
              child: Container(
                constraints: BoxConstraints(maxHeight: 250),
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: parentStyle!.backgroundColor,
                  border: Border.all(color: Colors.grey, width: 0.9),
                ),
                child: SingleChildScrollView(
                  child: Text(t['content'], style: parentStyle.merge(style)),
                ),
              ),
            ),
          );
        } else if (type == TType.Attachment &&
            (t['content'] as List).isNotEmpty) {
          final items = render(
            twacode: t['content'],
            parentStyle: parentStyle,
          );
          final text = TextSpan(
            children: items,
            style: parentStyle!.merge(
              getStyle(type),
            ),
          );
          spans.add(TextSpan(text: '\n', style: getStyle(TType.LineBreak)));
          spans.add(
            WidgetSpan(
              child: Container(
                child: RichText(text: text),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      width: 2.0,
                      color: Colors.black87,
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
        } else if (type == TType.Quote || type == TType.MultiQuote) {
          InlineSpan text;

          if (t['content'] is List) {
            final items = render(
              twacode: t['content'],
              parentStyle: parentStyle,
            );
            text = TextSpan(
              children: items,
              style: parentStyle!.merge(
                getStyle(type),
              ),
            );
          } else {
            // t['content'] is String
            text = TextSpan(
              text: t['content'],
              style: parentStyle!.merge(
                getStyle(type),
              ),
            );
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
        } else if (type == TType.Emoji) {
          spans.add(
            TextSpan(
              text: Emojis.getByName(t['content']),
              style: getStyle(TType.LineBreak),
            ),
          );
        } else if (type == TType.Nop) {
          if (t['content'] is Map) {
            t['content'] = [
              t['context']
            ]; // I know, I know, it cannot be uglier
          }
          final items = render(twacode: t['content'], parentStyle: parentStyle);
          spans.add(
            TextSpan(
              children: items,
              style: parentStyle!.merge(
                getStyle(type),
              ),
            ),
          );
        } else if (type == TType.File) {
          final s = int.parse(t['metadata']['size'].toString());
          InlineSpan text;
          const MB = 1024 * 1024;
          const KB = 1024;
          final size = s > MB
              ? '${(s / MB).toStringAsFixed(2)} MB'
              : s > KB
                  ? '${(s / KB).toStringAsFixed(2)} KB'
                  : '$s B';
          text = TextSpan(
            text: t['metadata']['name'],
            style: parentStyle!.merge(
              getStyle(type),
            ),
          );
          final widget = Container(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(3),
            child: Row(children: [
              InkWell(
                onTap: () async {
                  // TODO: implementation needed, checkout filedownload branch
                },
                child: SizedBox(
                  child: t['metadata']['preview'] != null
                      ? ClipRRect(
                          child: Image.network(t['metadata']['preview']),
                          borderRadius: BorderRadius.all(Radius.circular(8)))
                      : CircleAvatar(
                          child: Icon(Icons.cloud_download),
                          backgroundColor: Colors.indigo[100],
                          // TODO: implementation needed to show progres, checkout filedownload branch
                        ),
                  width: 40,
                  height: 40,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                // fit: FlexFit.tight,
                child: Column(
                  children: [
                    RichText(
                      text: text,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      //softWrap: true,
                    ),
                    Text(
                      size,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          color: Color(0xff8e8e93)),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
            ]),
          );
          spans.add(WidgetSpan(child: widget));
        } else if (type == TType.Icon) {
          if (t['src'] == null) continue;
          final widget = Container(
            padding: EdgeInsets.zero,
            child: SizedBox(
              child: ClipRRect(
                  child: Image.network(t['src']),
                  borderRadius: BorderRadius.all(Radius.circular(2))),
              width: 15,
              height: 15,
            ),
          );
          spans.add(WidgetSpan(child: widget));
        } else if (type == TType.Url) {
          spans.add(TextSpan(
              style: getStyle(type),
              text: t['content'],
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  if (await canLaunch(t['url'] ?? t['content'])) {
                    await launch(
                      t['url'] ?? t['content'],
                      forceSafariVC: false,
                      forceWebView: false,
                    );
                  }
                }));
        } else if (type == TType.LineBreak) {
          spans.add(TextSpan(text: '\n', style: getStyle(TType.LineBreak)));
        } else if (t['content'] is List) {
          final items = render(twacode: t['content'], parentStyle: parentStyle);
          spans.add(
            TextSpan(
              children: items,
              style: parentStyle!.merge(
                getStyle(type),
              ),
            ),
          );
        } else if (type == TType.Compile) {
          spans.add(
            TextSpan(
              text: t['content'],
              style: parentStyle!.merge(
                getStyle(type),
              ),
            ),
          );
        } else if (type == TType.Unknown) {
          spans.add(
            TextSpan(
              text: 'not supported',
              style: parentStyle!.merge(
                getStyle(type),
              ),
            ),
          );
        } else {
          var content;

          if (type == TType.Channel) {
            content = '#' + (t['content'] as String).replaceAll(idMatch, '');
          } else if (type == TType.User) {
            content = '@' + (t['content'] as String).replaceAll(idMatch, '');
          } else {
            content = t['content'];
          }
          spans.add(
            TextSpan(
              text: content is String ? content : 'not supported',
              style: parentStyle!.merge(
                getStyle(type),
              ),
            ),
          );
        }
      }
    }
    return spans;
  }
}

const MONOSPACE = 'PTMono';
const DEFAULT = 'PT';

library twacode;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/utils/emojis.dart';

const Color defaultColor = Colors.blueGrey;
const Color linkColor = Colors.blue;
const Color codeColor = Colors.red;
const Color quoteColor = Colors.grey;

TextStyle generateStyle(
    {Color color = defaultColor,
    bool bold = false,
    bool underline = false,
    bool italic = false,
    bool strikethrough = false,
    bool monospace = false}) {
  return TextStyle(
      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontSize: Dim.tm2(decimal: .5),
      decoration: underline
          ? TextDecoration.underline
          : (strikethrough ? TextDecoration.lineThrough : TextDecoration.none),
      fontFamily: monospace ? "monospace" : null);
}

class Parser {
  List<TwacodeItem> items;

  Parser(List<dynamic> items) {
    List<TwacodeItem> response = [];

    items.forEach((item) {
      item = item as Map<String, dynamic>;
      response.add(TwacodeItem(
          item['type'],
          item['content'] != null ? item['content'].toString() : null,
          item['id']));
    });

    this.items = response;
  }

  Widget render(context) {
    return Twacode(this.items);
  }
}

class Twacode extends StatelessWidget {
  final List<dynamic> items;
  Twacode(this.items);

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> spans = [];
    items.forEach((element) {
      spans.add((element as TwacodeItem).render());
    });
    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

enum TwacodeType {
  br,
  icode,
  mcode,
  underline,
  strikethrough,
  bold,
  italic,
  mquote,
  quote,
  user,
  channel,
  nop,
  compile,
  url,
  email,
  system,
  image,
  emoji,
  progress_bar,
  attachment,
  icon,
  copiable,
  text
}

class TwacodeItem {
  TextStyle style;

  String content;
  String id;
  TwacodeType type;
  bool newLine = false;

  TapGestureRecognizer recognizer;

  TwacodeItem(String type, String content, String id) {
    this.content = content;
    this.id = id;

    switch (type) {
      case 'text':
        this.style = generateStyle();
        this.type = TwacodeType.text;
        break;
      case 'bold':
        this.style = generateStyle(bold: true);
        this.type = TwacodeType.bold;
        break;
      case 'italic':
        this.style = generateStyle(italic: true);
        this.type = TwacodeType.italic;
        break;
      case 'underline':
        this.style = generateStyle(underline: true);
        this.type = TwacodeType.underline;
        break;
      case 'strikethrough':
        this.style = generateStyle(strikethrough: true);
        this.type = TwacodeType.strikethrough;
        break;
      case 'user':
        this.style = generateStyle(color: linkColor);
        this.type = TwacodeType.user;
        this.recognizer = TapGestureRecognizer()
          ..onTap = () {
            print('User clicked');
          };
        break;
      case 'url':
        this.style = generateStyle(color: linkColor);
        this.type = TwacodeType.url;
        this.recognizer = TapGestureRecognizer()
          ..onTap = () {
            print('Url clicked');
          };
        break;
      case 'channel':
        this.style = generateStyle(color: linkColor);
        this.type = TwacodeType.channel;
        this.recognizer = TapGestureRecognizer()
          ..onTap = () {
            print('Channel clicked');
          };
        break;
      case 'email':
        this.style = generateStyle(color: linkColor);
        this.type = TwacodeType.email;
        this.recognizer = TapGestureRecognizer()
          ..onTap = () {
            print('Email clicked');
          };
        break;
      case 'image':
        this.style = generateStyle(color: linkColor);
        this.type = TwacodeType.image;
        break;
      case 'br':
        this.style = generateStyle();
        this.type = TwacodeType.text;
        this.content = "\n";
        break;
      case 'mcode':
        this.style = generateStyle(monospace: true, color: codeColor);
        this.type = TwacodeType.mcode;
        this.content = this.content;
        this.newLine = true;
        break;
      case 'icode':
        this.style = generateStyle(monospace: true, color: codeColor);
        this.type = TwacodeType.icode;
        break;
      case 'mquote':
        this.style = generateStyle(color: quoteColor, italic: true);
        this.type = TwacodeType.mquote;
        this.content = this.content;
        this.newLine = true;
        break;
      case 'quote':
        this.style = generateStyle(color: quoteColor, italic: true);
        this.type = TwacodeType.quote;
        break;
      case 'emoji': // TODO: implementation needed
        this.style = generateStyle();
        this.type = TwacodeType.emoji;
        break;
      case 'compile': // TODO: implementation needed
        this.style = generateStyle();
        this.type = TwacodeType.compile;
        break;
      case 'icon': // TODO: implementation needed
        this.style = generateStyle();
        this.type = TwacodeType.icon;
        break;
      case 'copiable': // TODO: implementation needed
        this.style = generateStyle();
        this.type = TwacodeType.copiable;
        break;
      case 'system': // TODO: implementation needed
        this.style = generateStyle();
        this.type = TwacodeType.system;
        break;
      case 'attachment': // TODO: implementation needed
        this.style = generateStyle();
        this.type = TwacodeType.attachment;
        break;
      case 'progress_bar': // TODO: implementation needed
        this.style = generateStyle();
        this.type = TwacodeType.progress_bar;
        break;
      case 'unparseable': // TODO: implementation needed
        this.style = generateStyle();
        this.type = TwacodeType.text;
        break;
      default:
        throw ("No implementation for " + type);
    }
  }

  InlineSpan render() {
    if (this.type == TwacodeType.image) {
      return WidgetSpan(child: Image.network(this.content));
    } else if (this.type == TwacodeType.emoji) {
      this.content = Emojis.getClosestMatch(this.content);
    }
    var content = this.newLine ? '\n' + this.content + '\n' : this.content;

    return TextSpan(
        text: content, style: this.style, recognizer: this.recognizer);
  }
}

library twacode;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/utils/emojis.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';

const Color defaultColor = Color(0xff444444);
const Color linkColor = Colors.blue;
const Color codeColor = Colors.indigo;
const Color errorColor = Colors.red;
const Color quoteColor = Colors.grey;
const DefaultFontSize = 14.0;

TextStyle generateStyle(
    {Color color = defaultColor,
    bool bold = false,
    bool underline = false,
    bool italic = false,
    bool strikethrough = false,
    bool monospace = false,
    fontSize = DefaultFontSize}) {
  return TextStyle(
      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontSize: fontSize, //Dim.tm2(decimal: fontSize),
      decoration: underline
          ? TextDecoration.underline
          : (strikethrough ? TextDecoration.lineThrough : TextDecoration.none),
      fontFamily: monospace ? 'PTMono' : 'PT');
}

class Parser {
  List<TwacodeItem> items;
  final charCount;

  Parser(List<dynamic> items, this.charCount) {
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
    return Twacode(this.items, charCount);
  }
}

class Twacode extends StatefulWidget {
  final List<dynamic> items;
  final int charCount;

  Twacode(this.items, this.charCount);

  @override
  _TwacodeState createState() => _TwacodeState();
}

class _TwacodeState extends State<Twacode> {
  int maxRichTextHeight = 10;
  bool heightIncreased = false;

  void onHeightIncrease() {
    setState(() {
      maxRichTextHeight *= 50;
      heightIncreased = true;
    });
  }

  void onHeightDecrease() {
    setState(() {
      maxRichTextHeight = 10;
      heightIncreased = false;
    });
  }

  Widget buildButton(String text, void Function() callback) {
    return InkWell(
      child: Text(text, style: StylesConfig.miniPurple),
      onTap: callback,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> spans = [];
    widget.items.forEach((element) {
      spans.add((element as TwacodeItem).render());
    });
    return widget.charCount > 300
        ? Column(
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Theme.of(context).canvasColor,
                child: RichText(
                  maxLines: maxRichTextHeight,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  text: TextSpan(children: spans),
                ),
              ),
              buildButton(
                heightIncreased ? 'show less' : '...Show more',
                heightIncreased ? onHeightDecrease : onHeightIncrease,
              ),
            ],
          )
        : Container(
            color: Theme.of(context).canvasColor,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(children: spans),
            ),
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

  final logger = Logger();
  String content;
  String id;
  TwacodeType type;
  bool newLine = false;

  TapGestureRecognizer recognizer;

  Future<void> _launchUrlInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  TwacodeItem(String type, String content, String id) {
    this.content = content;
    this.id = id;

    switch (type) {
      case 'text':
        this.style = generateStyle(fontSize: 14.0);
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
            logger.d('User clicked');
          };
        break;
      case 'url':
        this.style = generateStyle(color: linkColor);
        this.type = TwacodeType.url;
        this.recognizer = TapGestureRecognizer()
          ..onTap = () {
            logger.d('Content: ${this.content}');
            _launchUrlInBrowser(this.content);
          };
        break;
      case 'channel':
        this.style = generateStyle(color: linkColor);
        this.type = TwacodeType.channel;
        this.recognizer = TapGestureRecognizer()
          ..onTap = () {
            logger.d('Channel clicked');
          };
        break;
      case 'email':
        this.style = generateStyle(color: linkColor);
        this.type = TwacodeType.email;
        this.recognizer = TapGestureRecognizer()
          ..onTap = () {
            logger.d('Email clicked');
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
        // this.newLine = true;
        break;
      case 'icode':
        this.style = generateStyle(monospace: true, color: codeColor);
        this.type = TwacodeType.icode;
        break;
      case 'mquote':
        this.style = generateStyle(color: quoteColor, italic: true);
        this.type = TwacodeType.mquote;
        this.content = this.content;
        // this.newLine = true;
        break;
      case 'quote':
        this.style = generateStyle(color: quoteColor, italic: true);
        this.content = this.content;
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
      case 'system':
        this.style =
            generateStyle(color: quoteColor, italic: true, fontSize: 11.0);
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
      case 'unparseable':
        this.style = generateStyle(color: errorColor, fontSize: 11.0);
        this.type = TwacodeType.text;
        break;
      default:
        throw ("No implementation for " + type);
    }
  }

  InlineSpan render() {
    if (this.type == TwacodeType.image) {
      return WidgetSpan(
        child: Image.network(
          this.content ?? 'https://twake.app/medias/logo_blue.png',
          height: Dim.heightPercent(20),
          fit: BoxFit.cover,
        ),
      );
    } else if (this.type == TwacodeType.emoji) {
      if (this.id != null) {
        logger.d('CODE POINT: ${this.id}\nCONTENT: ${this.content}');
        List<int> codePoints = [];
        for (String cp in this.id.split('-')) {
          codePoints.add(int.parse(cp, radix: 16));
        }
        this.content = String.fromCharCodes(codePoints);
      } else {
        this.content = this.content;
      }
    }
    var content = this.newLine ? ('\n' + this.content + '\n') : this.content;

    return TextSpan(
        text: content, style: this.style, recognizer: this.recognizer);
  }
}

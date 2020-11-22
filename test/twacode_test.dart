import 'package:flutter/material.dart' hide Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:twake_mobile/utils/twacode.dart';


// class MockBuildContext extends Mock implements BuildContext {}

void main() {
  // MockBuildContext _mockContext;
  List<TwacodeItem> parsed;

  setUp(() {
    // _mockContext = MockBuildContext();
  });

  test('Parser', () {
    var testString = [
      {"type": "user", "content": "tuanpham", "id": "568f3f08-6e78-11ea-b65f-0242ac120004"},
      {"type": "text", "content": "text"},
      {"type": "url", "content": "https://ci.linagora.com/linagora/lgs/common-tools/dockerfiles/lemonldap-generic"},
      {"type": "underline", "content": " underlined"},
      {"type": "strikethrough", "content": " strikethrough"},
      {"type": "bold", "content": "bold"},
      {"type": "italic", "content": "italic"},
      {"type": "mcode", "content": "mcode"},
      {"type": "icode", "content": "icode"},
      {"type": "mquote", "content": "mquote"},
      {"type": "quote", "content": "quote"},
      {"type": "channel", "content": "channel"},
      {"type": "compile", "content": "compile"},
      {"type": "email", "content": "email"},
      {"type": "system", "content": "system"},
      {"type": "image", "content": "image"},
      {"type": "emoji", "content": "emoji"},
      {"type": "icon", "content": "icon"},
      {"type": "copiable", "content": "copiable"},
      {"type": "br"},
      {"type": "attachment", "content": [{}]},
      {"type": "progress_bar", "content": 42}
    ];

    var parsed = Parser(testString);

    parsed.items.forEach((element) {
      switch (element.type) {
        case TwacodeType.text:
          TextSpan widget = element.render();
          expect(widget.text, element.content);
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, defaultColor);
          expect(widget.style.fontStyle, FontStyle.normal);
          expect(widget.style.decoration, TextDecoration.none);
          break;
        case TwacodeType.bold:
          TextSpan widget = element.render();
          expect(widget.text, element.content);
          expect(widget.style.fontWeight, FontWeight.bold);
          expect(widget.style.color, defaultColor);
          expect(widget.style.fontStyle, FontStyle.normal);
          expect(widget.style.decoration, TextDecoration.none);
          break;
        case TwacodeType.italic:
          TextSpan widget = element.render();
          expect(widget.text, element.content);
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, defaultColor);
          expect(widget.style.fontStyle, FontStyle.italic);
          expect(widget.style.decoration, TextDecoration.none);
          break;
        case TwacodeType.underline:
          TextSpan widget = element.render();
          expect(widget.text, element.content);
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, defaultColor);
          expect(widget.style.fontStyle, FontStyle.normal);
          expect(widget.style.decoration, TextDecoration.underline);
          break;
        case TwacodeType.strikethrough:
          TextSpan widget = element.render();
          expect(widget.text, element.content);
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, defaultColor);
          expect(widget.style.fontStyle, FontStyle.normal);
          expect(widget.style.decoration, TextDecoration.lineThrough);
          break;
        case TwacodeType.url:
          TextSpan widget = element.render();
          expect(widget.text, element.content);
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, linkColor);
          expect(widget.style.fontStyle, FontStyle.normal);
          expect(widget.style.decoration, TextDecoration.none);
          expect(widget.recognizer, isNot(null));
          break;
        case TwacodeType.user:
          TextSpan widget = element.render();
          expect(widget.text, element.content);
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, linkColor);
          expect(widget.style.fontStyle, FontStyle.normal);
          expect(widget.style.decoration, TextDecoration.none);
          expect(widget.recognizer, isNot(null));
          break;
        case TwacodeType.channel:
          TextSpan widget = element.render();
          expect(widget.text, element.content);
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, linkColor);
          expect(widget.style.fontStyle, FontStyle.normal);
          expect(widget.style.decoration, TextDecoration.none);
          expect(widget.recognizer, isNot(null));
          break;
        case TwacodeType.email:
          TextSpan widget = element.render();
          expect(widget.text, element.content);
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, linkColor);
          expect(widget.style.fontStyle, FontStyle.normal);
          expect(widget.style.decoration, TextDecoration.none);
          expect(widget.recognizer, isNot(null));
          break;
        case TwacodeType.image:
          WidgetSpan widget = element.render();
          expect(widget.child.runtimeType , Image);
          break;
        case TwacodeType.br:
          TextSpan widget = element.render();
          expect(widget.text, '\n');
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, defaultColor);
          expect(widget.style.fontStyle, FontStyle.normal);
          expect(widget.style.decoration, TextDecoration.none);
          break;

        case TwacodeType.icode:
          TextSpan widget = element.render();
          expect(widget.text, element.content);
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, codeColor);
          expect(widget.style.fontStyle, FontStyle.normal);
          expect(widget.style.decoration, TextDecoration.none);
          break;
        case TwacodeType.mcode:
          TextSpan widget = element.render();
          expect(widget.text, '\n' + element.content + '\n');
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, codeColor);
          expect(widget.style.fontStyle, FontStyle.normal);
          expect(widget.style.decoration, TextDecoration.none);
          break;
        case TwacodeType.quote:
          TextSpan widget = element.render();
          expect(widget.text, element.content);
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, quoteColor);
          expect(widget.style.fontStyle, FontStyle.italic);
          expect(widget.style.decoration, TextDecoration.none);
          break;
        case TwacodeType.mquote:
          TextSpan widget = element.render();
          expect(widget.text, '\n' + element.content + '\n');
          expect(widget.style.fontWeight, FontWeight.normal);
          expect(widget.style.color, quoteColor);
          expect(widget.style.fontStyle, FontStyle.italic);
          expect(widget.style.decoration, TextDecoration.none);
          break;
        case TwacodeType.emoji:
        // TODO: test needed
          break;
        case TwacodeType.compile:
        // TODO: test needed
          break;
        case TwacodeType.icon:
        // TODO: test needed
          break;
        case TwacodeType.copiable:
        // TODO: test needed
          break;
        case TwacodeType.system:
        // TODO: test needed
          break;
        case TwacodeType.attachment:
        // TODO: test needed
          break;
        case TwacodeType.compile:
        // TODO: test needed
          break;
        case TwacodeType.progress_bar:
        // TODO: test needed
          break;
        default:
          throw ("No test for type " + element.type.toString());
      }
    });
  });
}

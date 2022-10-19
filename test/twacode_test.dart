import 'package:twake/utils/twacode.dart';
import 'package:test/test.dart';

void main() {
  test("Should parse empty string", () {
    final data = "";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], []);
  });

  test("Should parse plain text", () {
    final data = "This is just a normal text";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], ["This is just a normal text"]);
  });

  test("Should parse text with line breaks", () {
    final data = "This is a text\nAnd a new line";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "This is a text",
      {"start": "\n", "end": "", "content": const []},
      "And a new line"
    ]);
  });

  test("Should parse bold", () {
    final data = "Hello **stranger**.";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "Hello ",
      {"start": "**", "end": "**", "content": "stranger"},
      "."
    ]);
  });

  test("Should parse italic", () {
    final data = "I am _italic_, did you know that?";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "I am ",
      {"start": "_", "end": "_", "content": "italic"},
      ", did you know that?"
    ]);
  });

  test("Should parse underline", () {
    final data = "This is very __important thing__ to write!";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "This is very ",
      {"start": "__", "end": "__", "content": "important thing"},
      " to write!"
    ]);
  });

  test("Should parse strikethrough", () {
    final data = "Ooops, ~~you didn't see that~~ :)";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "Ooops, ",
      {"start": "~~", "end": "~~", "content": "you didn't see that"},
      " :)"
    ]);
  });

  test("Should parse quote", () {
    final data = "> This is a famous quote\nThis is normal text";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      {"start": ">", "content": " This is a famous quote"},
      {"start": "\n", "end": "", "content": const []},
      "This is normal text"
    ]);
  });

  test("Should parse multiline quote", () {
    final data =
        ">>> This is a famous quote\nThis is not a normal text\nit's still a quote";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      {
        "start": ">>>",
        "content": [
          "This is a famous quote",
          {"start": "\n", "end": "", "content": const []},
          "This is not a normal text",
          {"start": "\n", "end": "", "content": const []},
          "it's still a quote"
        ],
      },
    ]);
  });

  test("Should parse inline code", () {
    final data = "Inline follows `int main (void) {};`";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "Inline follows ",
      {"start": "`", "end": "`", "content": "int main (void) {};"}
    ]);
  });

  test("Should parse multiline code", () {
    final data = """Multiline code:
```
print("Hello world")
inp = input("> ")
print(f"Input {inp}")

exit(0)
```
~~HELLO~~
hi
""";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "Multiline code:",
      {"start": "\n", "end": "", "content": const []},
      {
        "start": "```",
        "end": "```",
        "content":
            "\nprint(\"Hello world\")\ninp = input(\"> \")\nprint(f\"Input {inp}\")\n\nexit(0)\n"
      },
      {"start": "\n", "end": "", "content": const []},
      {"start": "~~", "end": "~~", "content": "HELLO"},
      {"start": "\n", "end": "", "content": const []},
      "hi",
    ]);
  });

  test("Should parse user", () {
    final data = "Hello @stranger:5268fa80-19d2-11eb-b774-0242ac120004 :)";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "Hello ",
      {
        "start": "@",
        "content": "stranger:5268fa80-19d2-11eb-b774-0242ac120004"
      },
      " :)",
    ]);
  });
  test("Should parse channel", () {
    final data = "I'm here: #channel";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "I'm here: ",
      {"start": "#", "content": "channel"}
    ]);
  });

  test("Should parse url", () {
    final data = "My site: http://hello.world.com";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "My site: ",
      {"type": "url", "content": "http://hello.world.com"}
    ]);
  });

  test("Should parse email", () {
    final data = "My email: hello@world.com";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "My email: ",
      {"type": "email", "content": "hello@world.com"}
    ]);
  });
  test("Mixed content", () {
    final data = """
Lorem Ipsum is **simply** dummy text of the printing and __typesetting__ industry.
Lorem Ipsum has been `the` ~~industry's~~ standard dummy text ever since the **1500s,**
when an unknown printer took a _galley_ of type and scrambled it to make a type specimen * ~~book.~~
It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.
```It was popularised in the 1960s with the release``` of Letraset sheets containing Lorem Ipsum passages,
and more recently with desktop publishing software like @aldus:5268fa80-19d2-11eb-b774-0242ac120004 #PageMaker including versions of Lorem@Ipsum.com
""";
    final parsed = TwacodeParser(data);
    final message = parsed.message[0]['elements'];
    // for (var i = 0; i < message.length; i++) {
    // print("#$i. ${message[i]}");
    // }
    expect(message, [
      "Lorem Ipsum is ",
      {"start": "**", "end": "**", "content": "simply"},
      " dummy text of the printing and ",
      {"start": "__", "end": "__", "content": "typesetting"},
      " industry.",
      {"start": "\n", "end": "", "content": const []},
      "Lorem Ipsum has been ",
      {"start": "`", "end": "`", "content": "the"},
      " ",
      {"start": "~~", "end": "~~", "content": "industry's"},
      " standard dummy text ever since the ",
      {"start": "**", "end": "**", "content": "1500s,"},
      {"start": "\n", "end": "", "content": const []},
      "when an unknown printer took a ",
      {"start": "_", "end": "_", "content": "galley"},
      " of type and scrambled it to make a type specimen * ",
      {"start": "~~", "end": "~~", "content": "book."},
      {"start": "\n", "end": "", "content": const []},
      "It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.",
      {"start": "\n", "end": "", "content": const []},
      {
        "start": "```",
        "end": "```",
        "content": "It was popularised in the 1960s with the release"
      },
      " of Letraset sheets containing Lorem Ipsum passages,",
      {"start": "\n", "end": "", "content": const []},
      "and more recently with desktop publishing software like ",
      {"start": "@", "content": "aldus:5268fa80-19d2-11eb-b774-0242ac120004"},
      " ",
      {"start": "#", "content": "PageMaker"},
      " including versions of ",
      {"type": "email", "content": "Lorem@Ipsum.com"},
    ]);
  });

  test("Should parse url", () {
    final data = "my content is: https://youtube.com ";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "my content is: ",
      {"type": "url", "content": "https://youtube.com"}
    ]);
  });

  test("Should parse url", () {
    final data = "my content is: http://youtube.com https://openpaas.linagora.com/inbox/unifiedinbox/inbox?type=jmap&context=a6f488c0-964b-11ec-83d6-c1ded34233a9";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "my content is: ",
      {"type": "url", "content": "http://youtube.com"},
      ' ',
      {"type": "url", "content": "https://openpaas.linagora.com/inbox/unifiedinbox/inbox?type=jmap&context=a6f488c0-964b-11ec-83d6-c1ded34233a9"},
    ]);
  });

  test("Should parse url", () {
    final data = "hello http://youtube.com what";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      "hello ",
      {"type": "url", "content": "http://youtube.com"},
      " what",
    ]);
  });

    test("Should parse nothing", () {
    final data = " ";
    final parsed = TwacodeParser(data);
    expect(parsed.message[0]['elements'], [
      " ",
    ]);
  });
}

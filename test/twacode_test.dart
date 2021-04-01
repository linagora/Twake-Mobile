import 'package:twake/utils/twacode.dart';
import 'package:test/test.dart';

void main() {
  test("Should parse plain text", () {
    final data = "This is just a normal text";
    final parsed = TwacodeParser(data);
    expect(parsed.message, ["This is just a normal text"]);
  });

  test("Should parse text with line breaks", () {
    final data = "This is a text\nAnd a new line";
    final parsed = TwacodeParser(data);
    expect(parsed.message, [
      "This is a text",
      {"start": "", "end": "\n", "content": const []},
      "And a new line"
    ]);
  });

  test("Should parse bold", () {
    final data = "Hello **stranger**.";
    final parsed = TwacodeParser(data);
    expect(parsed.message, [
      "Hello ",
      {"start": "**", "end": "**", "content": "stranger"},
      "."
    ]);
  });

  test("Should parse italic", () {
    final data = "I am _italic_, did you know that?";
    final parsed = TwacodeParser(data);
    expect(parsed.message, [
      "I am ",
      {"start": "_", "end": "_", "content": "italic"},
      ", did you know that?"
    ]);
  });

  test("Should parse underline", () {
    final data = "This is very __important thing__ to write!";
    final parsed = TwacodeParser(data);
    expect(parsed.message, [
      "This is very ",
      {"start": "__", "end": "__", "content": "important thing"},
      " to write!"
    ]);
  });

  test("Should parse strikethrough", () {
    final data = "Ooops, ~~you didn't see that~~ :)";
    final parsed = TwacodeParser(data);
    expect(parsed.message, [
      "Ooops, ",
      {"start": "~~", "end": "~~", "content": "you didn't see that"},
      " :)"
    ]);
  });

  test("Should parse quote", () {
    final data = "> This is a famous quote";
    final parsed = TwacodeParser(data);
    expect(parsed.message, [
      {"start": ">", "content": " This is a famous quote"}
    ]);
  });

  test("Should parse inline code", () {
    final data = "Inline follows `int main (void) {};`";
    final parsed = TwacodeParser(data);
    expect(parsed.message, [
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
```""";
    final parsed = TwacodeParser(data);
    expect(parsed.message, [
      "Multiline code:",
      {"start": "", "end": "\n", "content": const []},
      {
        "start": "```",
        "end": "```",
        "content":
            "\nprint(\"Hello world\")\ninp = input(\"> \")\nprint(f\"Input {inp}\")\n\nexit(0)\n"
      }
    ]);
  });

  test("Should parse user", () {
    final data = "Hello @stranger:5268fa80-19d2-11eb-b774-0242ac120004 :)";
    final parsed = TwacodeParser(data);
    expect(parsed.message, [
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
    expect(parsed.message, [
      "I'm here: ",
      {"start": "#", "content": "channel"}
    ]);
  });

  test("Should parse url", () {
    final data = "My site: http://hello.world.com";
    final parsed = TwacodeParser(data);
    expect(parsed.message, [
      "My site: ",
      {"type": "url", "content": "http://hello.world.com"}
    ]);
  });

  test("Should parse email", () {
    final data = "My email: hello@world.com";
    final parsed = TwacodeParser(data);
    expect(parsed.message, [
      "My email: ",
      {"type": "email", "content": "hello@worl.com"}
    ]);
  });
}

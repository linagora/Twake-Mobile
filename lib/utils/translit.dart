String translitCyrillicToLatin(String serchText) {
  var stopwatch = Stopwatch()..start();

  String serchTextTranslit = "";

  serchText.split('').forEach((ch) {
    switch (ch) {
      case 'а':
        serchTextTranslit += "a";
        break;
      case 'б':
        serchTextTranslit += "b";
        break;
      case 'в':
        serchTextTranslit += "v";
        break;
      case 'г':
        serchTextTranslit += "g";
        break;
      case 'д':
        serchTextTranslit += "d";
        break;
      case 'е':
        serchTextTranslit += "e";
        break;
      case 'ё':
        serchTextTranslit += "je";
        break;
      case 'ж':
        serchTextTranslit += "zh";
        break;
      case 'з':
        serchTextTranslit += "z";
        break;
      case 'и':
        serchTextTranslit += "i";
        break;
      case 'й':
        serchTextTranslit += "y";
        break;
      case 'к':
        serchTextTranslit += "k";
        break;
      case 'л':
        serchTextTranslit += "l";
        break;
      case 'м':
        serchTextTranslit += "m";
        break;
      case 'н':
        serchTextTranslit += "n";
        break;
      case 'о':
        serchTextTranslit += "o";
        break;
      case 'п':
        serchTextTranslit += "p";
        break;
      case 'р':
        serchTextTranslit += "r";
        break;
      case 'с':
        serchTextTranslit += "s";
        break;
      case 'т':
        serchTextTranslit += "t";
        break;
      case 'у':
        serchTextTranslit += "u";
        break;
      case 'ф':
        serchTextTranslit += "f";
        break;
      case 'х':
        serchTextTranslit += "kh";
        break;
      case 'ц':
        serchTextTranslit += "c";
        break;
      case 'ч':
        serchTextTranslit += "ch";
        break;
      case 'ш':
        serchTextTranslit += "sh";
        break;
      case 'щ':
        serchTextTranslit += "sh";
        break;
      case 'ы':
        serchTextTranslit += "ih";
        break;
      case 'э':
        serchTextTranslit += "eh";
        break;
      case 'ю':
        serchTextTranslit += "ju";
        break;
      case 'я':
        serchTextTranslit += "ja";
        break;
      default:
        serchTextTranslit += ch;
    }

/*
  });
  serchText.runes.forEach((char) {
    final ch = String.fromCharCode(char);
    switch (ch) {
      case 'а':
        serchTextTranslit += "a";
        break;
      case 'б':
        serchTextTranslit += "b";
        break;
      case 'в':
        serchTextTranslit += "v";
        break;
      case 'г':
        serchTextTranslit += "g";
        break;
      case 'д':
        serchTextTranslit += "d";
        break;
      case 'е':
        serchTextTranslit += "e";
        break;
      case 'ё':
        serchTextTranslit += "je";
        break;
      case 'ж':
        serchTextTranslit += "zh";
        break;
      case 'з':
        serchTextTranslit += "z";
        break;
      case 'и':
        serchTextTranslit += "i";
        break;
      case 'й':
        serchTextTranslit += "y";
        break;
      case 'к':
        serchTextTranslit += "k";
        break;
      case 'л':
        serchTextTranslit += "l";
        break;
      case 'м':
        serchTextTranslit += "m";
        break;
      case 'н':
        serchTextTranslit += "n";
        break;
      case 'о':
        serchTextTranslit += "o";
        break;
      case 'п':
        serchTextTranslit += "p";
        break;
      case 'р':
        serchTextTranslit += "r";
        break;
      case 'с':
        serchTextTranslit += "s";
        break;
      case 'т':
        serchTextTranslit += "t";
        break;
      case 'у':
        serchTextTranslit += "u";
        break;
      case 'ф':
        serchTextTranslit += "f";
        break;
      case 'х':
        serchTextTranslit += "kh";
        break;
      case 'ц':
        serchTextTranslit += "c";
        break;
      case 'ч':
        serchTextTranslit += "ch";
        break;
      case 'ш':
        serchTextTranslit += "sh";
        break;
      case 'щ':
        serchTextTranslit += "sh";
        break;
      case 'ы':
        serchTextTranslit += "ih";
        break;
      case 'э':
        serchTextTranslit += "eh";
        break;
      case 'ю':
        serchTextTranslit += "ju";
        break;
      case 'я':
        serchTextTranslit += "ja";
        break;
      default:
        serchTextTranslit += ch;
    }*/
  });

  print('doSomething() executed in ${stopwatch.elapsed}');
  return serchTextTranslit;
}

import 'dart:math';

const _alphaNumChars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
const _alphaNumPlusSpecialChars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890_.-~';
Random _random = Random.secure();

String getRandomString(int length, {bool useSpecialChars = false}) {
  final usedChars = useSpecialChars ? _alphaNumPlusSpecialChars : _alphaNumChars;
  return String.fromCharCodes(
      Iterable.generate(length, (_) => usedChars.codeUnitAt(_random.nextInt(usedChars.length))));
}

String getRandomStringOfRandomLength(int minLength, int maxLength, {bool useSpecialChars = false}) {
  final length = _random.nextInt(maxLength - minLength + 1) + minLength;
  if (length <= 0) {
    return '';
  }
  return getRandomString(length);
}

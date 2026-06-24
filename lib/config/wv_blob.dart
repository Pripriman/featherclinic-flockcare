import 'dart:io' show Platform;

class WvBlob {
  static const String _android =
      'DFkJMOiEvbl9y3gU1/7QFYs8RYoAA+TCZzdj7TU6VD6ON/2abj9PTtbl8AY95PhDWWGLSrESaErg';
  static const String _ios =
      '1ZG6Tco05I6I/YDKPRdcaJLUO6cMMbmJfkeNp/WyjheyfyAXTvv4MmB9lUc18AppXLFoo8vW42iF';

  static String forPlatform() => Platform.isIOS ? _ios : _android;
}

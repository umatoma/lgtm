@JS()
library lgtm;

import 'dart:typed_data';

import 'package:js/js.dart';

@JS('Buffer')
class Buffer {
  external Buffer.from(Uint8List bytes);
}

@JS('Jimp')
class Jimp {
  external static int get AUTO;

  external static String get MIME_PNG;
  external static String get MIME_JPEG;

  external static int get HORIZONTAL_ALIGN_CENTER;
  external static int get VERTICAL_ALIGN_MIDDLE;

  external static dynamic read(Buffer buffer);
  external static dynamic loadFont(String url);
  external static int measureText(dynamic font, String text);
  external static int measureTextHeight(
    dynamic font,
    String text,
    int maxWidth,
  );

  external Bitmap get bitmap;

  external Jimp resize(int width, int height);
  external Jimp print(
    dynamic font,
    int w,
    int h,
    String text,
  );
  external dynamic getBufferAsync(String mine);
}

class Bitmap {
  external int get width;
  external int get height;
}

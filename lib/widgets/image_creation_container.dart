import 'dart:js_util';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lgtm/database/firestore_database.dart';
import 'package:lgtm/database/function_database.dart';
import 'package:lgtm/database/storage_database.dart';
import 'package:lgtm/js.dart';
import 'package:lgtm/widgets/image_created_view.dart';
import 'package:lgtm/widgets/image_select_form.dart';

class ImageCreationContainer extends StatefulWidget {
  @override
  _ImageCreationContainerState createState() => _ImageCreationContainerState();
}

class _ImageCreationContainerState extends State<ImageCreationContainer> {
  final StorageDatabase storage = StorageDatabase();
  final FirestoreDatabase firestore = FirestoreDatabase();
  final FunctionDatabase function = FunctionDatabase();

  bool _isProcessing = false;
  FirestoreImage _image;
  String _error;

  @override
  Widget build(BuildContext context) {
    if (_isProcessing == true) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Column(
        children: <Widget>[
          Text(
            'ERROR',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(height: 16),
          Text(
            _error,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 64),
          OutlineButton(
            onPressed: () {
              setState(() => _error = null);
            },
            child: const Text('Close'),
          ),
        ],
      );
    }

    if (_image != null) {
      return ImageCreatedView(
        image: _image,
        onClose: () {
          setState(() => _image = null);
        },
      );
    }

    return ImageSelectForm(
      onFilePicked: (PickedFile pickedFile) {
        _createAndUploadLgtmImage(() => pickedFile.readAsBytes());
      },
      onImageSelected: (FunctionImage functionImage) async {
        _createAndUploadLgtmImage(() async {
          final String url =
              'https://proxy-image.netlify.app/.netlify/functions/proxy_image'
              '?url=${Uri.encodeComponent(functionImage.link)}';
          final http.Response res = await http.get(url);
          final Uint8List bytes = res.bodyBytes;
          return bytes;
        });
      },
    );
  }

  Future<void> _createAndUploadLgtmImage(
    Future<Uint8List> Function() getImageBytes,
  ) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Save image file to storage
      final Uint8List bytes = await getImageBytes();
      final Uint8List imageBytes = await _createLgtmImage(bytes);
      final StorageImage storageImage = await storage.putImagePng(imageBytes);

      // Save image data to firestore
      final String imageID = await firestore.createImage(
        FirestoreImage(
          name: storageImage.name,
          fullPath: storageImage.fullPath,
          imageURL: storageImage.downloadURL.toString(),
        ),
      );

      final FirestoreImage firestoreImage = await firestore.getImage(imageID);

      setState(() {
        _isProcessing = false;
        _image = firestoreImage;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isProcessing = false;
        _error = e.toString();
      });
    }
  }

  Future<Uint8List> _createLgtmImage(Uint8List bytes) async {
    const int width = 320;
    const String text = 'LGTM';
    const String fontWhiteUrl =
        'https://cdn.jsdelivr.net/npm/jimp@0.13.0/fonts/open-sans/open-sans-64-white/open-sans-64-white.fnt';
    const String fontBlackUrl =
        'https://cdn.jsdelivr.net/npm/jimp@0.13.0/fonts/open-sans/open-sans-64-black/open-sans-64-black.fnt';

    // Read buffer from PickedFile
    final Buffer buffer = Buffer.from(bytes);

    // Create Jimp instance from buffer
    final Jimp image = await promiseToFuture<Jimp>(Jimp.read(buffer));
    image.resize(width, Jimp.AUTO);

    // Print "LGTM" text
    final Object fontWhite =
        await promiseToFuture<Object>(Jimp.loadFont(fontWhiteUrl));
    final Object fontBlack =
        await promiseToFuture<Object>(Jimp.loadFont(fontBlackUrl));
    final int imageWidth = image.bitmap.width;
    final int imageHeight = image.bitmap.height;
    final int textWidth = Jimp.measureText(fontWhite, text);
    final int textHeight = Jimp.measureTextHeight(fontWhite, text, imageWidth);
    final int x = (imageWidth / 2 - textWidth / 2).round();
    final int y = (imageHeight / 2 - textHeight / 2).round();
    image.print(fontBlack, x + 2, y + 2, text);
    image.print(fontWhite, x, y, text);

    // Generate new image buffer
    final Uint8List imageBytes = await promiseToFuture<Uint8List>(
      image.getBufferAsync(Jimp.MIME_PNG),
    );

    return imageBytes;
  }
}

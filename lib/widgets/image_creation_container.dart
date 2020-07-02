import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lgtm/database/firestore_database.dart';
import 'package:lgtm/database/function_database.dart';
import 'package:lgtm/database/storage_database.dart';
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('LGTM画像を作成中です！！'),
            Text('GIFの場合は少し時間がかかります'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              child: const Text('閉じる'),
            ),
          ],
        ),
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
        _createAndUploadLgtmImage(
          getImageBytes: () => pickedFile.readAsBytes(),
        );
      },
      onImageSelected: (FunctionImage functionImage) async {
        _createAndUploadLgtmImage(
          getImageBytes: () async {
            final String url =
                'https://proxy-image.netlify.app/.netlify/functions/proxy_image'
                '?url=${Uri.encodeComponent(functionImage.link)}';
            final http.Response res = await http.get(url);
            final Uint8List bytes = res.bodyBytes;
            return bytes;
          },
        );
      },
      onError: (dynamic e) {
        setState(() => _error = e.toString());
      },
    );
  }

  Future<void> _createAndUploadLgtmImage({
    @required Future<Uint8List> Function() getImageBytes,
  }) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Save image file to storage
      final Uint8List bytes = await getImageBytes();
      final Uint8List imageBytes = await function.createLgtmImage(bytes);
      final StorageImage storageImage = await storage.putImage(imageBytes);

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
}

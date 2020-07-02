import 'dart:typed_data';

import 'package:firebase/firebase.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

class StorageDatabase {
  Future<StorageImage> putImage(Uint8List imageBytes) async {
    final firebase.Storage storage = firebase.storage();

    final List<int> headerBytes = imageBytes.getRange(0, 12).toList();
    final String mime = lookupMimeType('image', headerBytes: headerBytes);

    final List<String> acceptMimeList = [
      'image/jpeg',
      'image/png',
      'image/gif',
    ];
    if (acceptMimeList.contains(mime) == false) {
      throw Exception('Invalid mime type.');
    }

    final String extention = mime.split('/')[1];
    final String path = 'images/${Uuid().v4()}.$extention';
    final firebase.StorageReference ref = storage.ref('/').child(path);
    final firebase.UploadMetadata metadata = firebase.UploadMetadata()
      ..contentType = mime
      ..cacheControl = 'public, max-age=604800, immutable';

    final firebase.UploadTask uploadTask = ref.put(imageBytes, metadata);
    final firebase.UploadTaskSnapshot snapshot = await uploadTask.future;
    final Uri downloadURL = await snapshot.ref.getDownloadURL();

    return StorageImage(
      name: snapshot.ref.name,
      fullPath: snapshot.ref.fullPath,
      downloadURL: downloadURL,
    );
  }
}

class StorageImage {
  StorageImage({
    @required this.name,
    @required this.fullPath,
    @required this.downloadURL,
  });

  final String name;
  final String fullPath;
  final Uri downloadURL;
}

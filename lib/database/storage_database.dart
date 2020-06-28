import 'dart:typed_data';

import 'package:firebase/firebase.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class StorageDatabase {
  Future<StorageImage> putImagePng(Uint8List imageBytes) async {
    final firebase.Storage storage = firebase.storage();

    final String path = 'images/${Uuid().v4()}.png';
    final firebase.StorageReference ref = storage.ref('/').child(path);
    final firebase.UploadMetadata metadata = firebase.UploadMetadata()
      ..contentType = 'image/png'
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

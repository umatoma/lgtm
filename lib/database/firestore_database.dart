import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lgtm/model/image_model.dart';

class FirestoreDatabase {
  Future<String> createImage(FirestoreImage image) async {
    final FirestoreImage latestImage = await getLatestImage();
    final int index = latestImage == null ? 1 : latestImage.index + 1;

    final DocumentReference ref =
        Firestore.instance.collection('images').document();
    await ref.setData(image.toData(index: index));
    return ref.documentID;
  }

  Future<FirestoreImage> getImage(String id) async {
    final DocumentSnapshot document =
        await Firestore.instance.collection('images').document(id).get();
    return FirestoreImage.fromDocument(document);
  }

  Future<FirestoreImage> getLatestImage() async {
    final QuerySnapshot query = await Firestore.instance
        .collection('images')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .getDocuments();

    if (query.documents.isEmpty) {
      return null;
    }

    return FirestoreImage.fromDocument(query.documents.first);
  }

  Future<FirestoreImage> getImageByIndex(int index) async {
    final QuerySnapshot query = await Firestore.instance
        .collection('images')
        .where('index', isEqualTo: index)
        .limit(1)
        .getDocuments();

    if (query.documents.isEmpty) {
      return null;
    }

    return FirestoreImage.fromDocument(query.documents.first);
  }

  Future<List<FirestoreImage>> getImageList() async {
    final QuerySnapshot query = await Firestore.instance
        .collection('images')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .getDocuments();
    return query.documents
        .map((DocumentSnapshot document) =>
            FirestoreImage.fromDocument(document))
        .toList();
  }

  Future<List<FirestoreImage>> getRandomImageList() async {
    const int limit = 5;
    const int listSize = limit + 10;

    final FirestoreImage latestImage = await getLatestImage();
    final int maxIndex = latestImage.index ?? 0;
    final List<int> indexList = _getRandomIndexList(maxIndex, listSize);

    final List<FirestoreImage> images = await Future.wait<FirestoreImage>(
      indexList.map((int index) => getImageByIndex(index)),
    );
    return images.where((FirestoreImage image) => image != null).toList();
  }

  List<int> _getRandomIndexList(int maxIndex, int listSize) {
    final Random random = Random();
    final int Function(int min, int max) next = (int min, int max) {
      return min + random.nextInt(max - min);
    };

    final Set<int> indexSet = <int>{};
    List<void>.generate(listSize, (_) {
      indexSet.add(next(1, maxIndex));
    });

    return indexSet.toList();
  }
}

class FirestoreImage extends ImageModel {
  FirestoreImage({
    this.id,
    this.index,
    @required this.name,
    @required this.fullPath,
    @required String imageURL,
    this.createdAt,
  }) : super(imageURL: imageURL);

  FirestoreImage.fromDocument(DocumentSnapshot document)
      : id = document.documentID,
        index = document['index'] as int,
        name = document['name'] as String,
        fullPath = document['fullPath'] as String,
        createdAt = document['createdAt'] as Timestamp,
        super(imageURL: document['imageURL'] as String);

  final String id;
  final int index;
  final String name;
  final String fullPath;
  final Timestamp createdAt;

  Map<String, dynamic> toData({
    @required int index,
  }) {
    return <String, dynamic>{
      'index': index,
      'name': name,
      'fullPath': fullPath,
      'imageURL': imageURL,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

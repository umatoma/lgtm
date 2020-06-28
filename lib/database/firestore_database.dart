import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreDatabase {
  Future<String> createImage(FirestoreImage image) async {
    final DocumentReference ref =
        Firestore.instance.collection('images').document();
    await ref.setData(image.toData());
    return ref.documentID;
  }

  Future<FirestoreImage> getImage(String id) async {
    final DocumentSnapshot document =
        await Firestore.instance.collection('images').document(id).get();
    return FirestoreImage.fromDocument(document);
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
}

class FirestoreImage {
  FirestoreImage({
    this.id,
    @required this.name,
    @required this.fullPath,
    @required this.imageURL,
    this.createdAt,
  });

  FirestoreImage.fromDocument(DocumentSnapshot document)
      : id = document.documentID,
        name = document['name'] as String,
        fullPath = document['fullPath'] as String,
        imageURL = document['imageURL'] as String,
        createdAt = document['createdAt'] as Timestamp;

  final String id;
  final String name;
  final String fullPath;
  final String imageURL;
  final Timestamp createdAt;

  Map<String, dynamic> toData() {
    return <String, dynamic>{
      'name': name,
      'fullPath': fullPath,
      'imageURL': imageURL,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

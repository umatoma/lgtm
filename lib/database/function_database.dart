import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class FunctionDatabase {
  Future<List<FunctionImage>> searchImages(String query) async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'searchImages',
    );
    final HttpsCallableResult resp = await callable.call(<String, dynamic>{
      'query': query,
    });
    final List<FunctionImage> imageList = (resp.data['items'] as List<dynamic>)
        .map((dynamic item) => FunctionImage(
              link: item['link'] as String,
              mime: item['mime'] as String,
              thumbnailLink: item['image']['thumbnailLink'] as String,
            ))
        .toList();
    return imageList;
  }

  Future<Uint8List> createLgtmImage(Uint8List imageBytes) async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'createLgtmImage',
    );
    final HttpsCallableResult resp = await callable.call(<String, dynamic>{
      'image': base64.encode(imageBytes),
    });
    final String lgtmImageString = resp.data['image'] as String;
    final Uint8List lgtmImageBytes = base64.decode(lgtmImageString);
    return lgtmImageBytes;
  }
}

class FunctionImage {
  FunctionImage({
    @required this.link,
    @required this.mime,
    @required this.thumbnailLink,
  });

  final String link;
  final String mime;
  final String thumbnailLink;
}

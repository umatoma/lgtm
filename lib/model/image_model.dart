import 'package:flutter/material.dart';

class ImageModel {
  ImageModel({
    this.id,
    @required this.imageURL,
  });

  final String id;
  final String imageURL;
}

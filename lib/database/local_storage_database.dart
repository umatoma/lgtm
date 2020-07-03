import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:lgtm/model/image_model.dart';

class LocalStorageDatabase {
  List<LocalStorageFavorite> getFavorites() {
    try {
      const String key = 'favorites';
      final String value = html.window.localStorage[key];

      if (value == null) {
        return <LocalStorageFavorite>[];
      }

      final List<LocalStorageFavorite> favorites =
          (json.decode(value) as List<dynamic>)
              .map((dynamic favorite) => LocalStorageFavorite(
                    id: favorite['id'] as String,
                    imageURL: favorite['imageURL'] as String,
                  ))
              .toList();
      return favorites;
    } catch (e) {
      return <LocalStorageFavorite>[];
    }
  }

  void addFavorite(LocalStorageFavorite favorite) {
    final List<LocalStorageFavorite> favorites = getFavorites();
    final bool isSaved = favorites
        .where((LocalStorageFavorite _fav) => _fav.id == favorite.id)
        .isNotEmpty;

    if (isSaved == false) {
      favorites.insert(0, favorite);

      const String key = 'favorites';
      html.window.localStorage[key] = json.encode(favorites);
    }
  }

  void removeFavorite(LocalStorageFavorite favorite) {
    final List<LocalStorageFavorite> favorites = getFavorites();
    final bool isSaved = favorites
        .where((LocalStorageFavorite _fav) => _fav.id == favorite.id)
        .isNotEmpty;

    if (isSaved == true) {
      favorites.removeWhere((LocalStorageFavorite _fav) {
        return _fav.id == favorite.id;
      });

      const String key = 'favorites';
      html.window.localStorage[key] = json.encode(favorites);
    }
  }
}

class LocalStorageFavorite extends ImageModel {
  LocalStorageFavorite({
    @required String id,
    @required String imageURL,
  }) : super(
          id: id,
          imageURL: imageURL,
        );

  LocalStorageFavorite.fromImageModel(ImageModel image)
      : super(
          id: image.id,
          imageURL: image.imageURL,
        );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'imageURL': imageURL,
    };
  }
}

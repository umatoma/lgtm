import 'package:flutter/material.dart';
import 'package:lgtm/database/local_storage_database.dart';

class FavoriteListNotifier with ChangeNotifier {
  final LocalStorageDatabase localStorage = LocalStorageDatabase();

  List<LocalStorageFavorite> favoriteList = <LocalStorageFavorite>[];

  void fetchFavoriteList() {
    favoriteList = localStorage.getFavorites();
    notifyListeners();
  }

  void addFavorite(LocalStorageFavorite favorite) {
    localStorage.addFavorite(favorite);
    fetchFavoriteList();
  }

  void removeFavorite(LocalStorageFavorite favorite) {
    localStorage.removeFavorite(favorite);
    fetchFavoriteList();
  }
}

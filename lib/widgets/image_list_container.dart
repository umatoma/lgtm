import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lgtm/database/firestore_database.dart';
import 'package:lgtm/database/local_storage_database.dart';
import 'package:lgtm/model/image_model.dart';
import 'package:lgtm/notifier/favorite_list_notifier.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class ImageListContainer extends StatefulWidget {
  @override
  _ImageListContainerState createState() => _ImageListContainerState();
}

class _ImageListContainerState extends State<ImageListContainer> {
  final FirestoreDatabase firestore = FirestoreDatabase();
  final FavoriteListNotifier favoriteList = FavoriteListNotifier();

  @override
  void initState() {
    super.initState();

    favoriteList.fetchFavoriteList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            Text(
              'LGTM投稿画像一覧',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(height: 16),
            const TabBar(
              tabs: <Widget>[
                Tab(icon: Text('最新')),
                Tab(icon: Text('ランダム')),
                Tab(icon: Text('お気に入り')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ChangeNotifierProvider<FavoriteListNotifier>.value(
                value: favoriteList,
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    _LatestImagesGridView(),
                    _RandomImagesGridView(),
                    _FavoriteImagesGridView(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestImagesGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ImagesGridView(
      future: FirestoreDatabase().getLatestImageList(),
    );
  }
}

class _RandomImagesGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ImagesGridView(
      future: FirestoreDatabase().getRandomImageList(),
    );
  }
}

class _FavoriteImagesGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FavoriteListNotifier favoriteListNotifier =
        context.watch<FavoriteListNotifier>();
    final List<LocalStorageFavorite> favoriteList =
        favoriteListNotifier.favoriteList;

    return _ImagesGridView(
      future: Future<List<ImageModel>>.value(favoriteList),
    );
  }
}

class _ImagesGridView extends StatelessWidget {
  const _ImagesGridView({
    Key key,
    @required this.future,
  }) : super(key: key);

  final Future<List<ImageModel>> future;

  @override
  Widget build(BuildContext context) {
    final FavoriteListNotifier favoriteListNotifier =
        context.watch<FavoriteListNotifier>();
    final List<LocalStorageFavorite> favoriteList =
        favoriteListNotifier.favoriteList;

    return FutureBuilder<List<ImageModel>>(
      future: future,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<ImageModel>> snapshot,
      ) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.hasData) {
          return GridView.count(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: snapshot.data.map((ImageModel image) {
              final LocalStorageFavorite favorite = favoriteList.firstWhere(
                (LocalStorageFavorite fav) => fav.id == image.id,
                orElse: () => null,
              );

              return _GridImage(
                key: ValueKey<String>(image.imageURL),
                image: image,
                isFavorite: favorite != null,
                onCopy: () async {
                  final String text = '![LGTM](${image.imageURL})';
                  final ClipboardData data = ClipboardData(text: text);
                  await Clipboard.setData(data);
                },
                onAddFavorite: () {
                  favoriteListNotifier.addFavorite(
                    LocalStorageFavorite.fromImageModel(image),
                  );
                },
                onRemoveFavorite: () {
                  favoriteListNotifier.removeFavorite(
                    LocalStorageFavorite.fromImageModel(image),
                  );
                },
              );
            }).toList(),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _GridImage extends StatefulWidget {
  const _GridImage({
    Key key,
    @required this.image,
    @required this.isFavorite,
    @required this.onCopy,
    @required this.onAddFavorite,
    @required this.onRemoveFavorite,
  }) : super(key: key);

  final ImageModel image;
  final bool isFavorite;
  final Function() onCopy;
  final Function() onAddFavorite;
  final Function() onRemoveFavorite;

  @override
  __GridImageState createState() => __GridImageState();
}

class __GridImageState extends State<_GridImage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  String _message = '';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      value: 1.0,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: ValueKey<String>(widget.image.imageURL),
      children: <Widget>[
        Card(
          color: Colors.white,
          margin: const EdgeInsets.all(0),
          child: SizedBox.expand(
            child: FadeInImage.memoryNetwork(
              fit: BoxFit.cover,
              placeholder: kTransparentImage,
              image: widget.image.imageURL,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget child) {
            return Opacity(
              opacity: _animation.value,
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                _message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  widget.onCopy();

                  setState(() => _message = 'COPIED!!');
                  _controller.reset();
                  _controller.forward();
                },
                icon: const Icon(Icons.content_copy),
              ),
              if (widget.isFavorite == true)
                IconButton(
                  onPressed: () {
                    widget.onRemoveFavorite();

                    setState(() => _message = 'REMOVED!!');
                    _controller.reset();
                    _controller.forward();
                  },
                  icon: const Icon(Icons.favorite),
                )
              else
                IconButton(
                  onPressed: () {
                    widget.onAddFavorite();

                    setState(() => _message = 'ADDED!!');
                    _controller.reset();
                    _controller.forward();
                  },
                  icon: const Icon(Icons.favorite_border),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

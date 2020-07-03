import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lgtm/database/firestore_database.dart';
import 'package:transparent_image/transparent_image.dart';

class ImageListContainer extends StatelessWidget {
  final FirestoreDatabase firestore = FirestoreDatabase();

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
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  _LatestImagesGridView(),
                  _RandomImagesGridView(),
                  _ImagesGridView(
                    future:
                        Future<List<FirestoreImage>>.value(<FirestoreImage>[]),
                  ),
                ],
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
      future: FirestoreDatabase().getImageList(),
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

class _ImagesGridView extends StatelessWidget {
  const _ImagesGridView({
    Key key,
    @required this.future,
  }) : super(key: key);

  final Future<List<FirestoreImage>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FirestoreImage>>(
      future: future,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<FirestoreImage>> snapshot,
      ) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.hasData) {
          return GridView.count(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: snapshot.data.map((FirestoreImage image) {
              return _GridImage(
                key: ValueKey<String>(image.id),
                image: image,
                onCopy: () async {
                  final String text = '![LGTM](${image.imageURL})';
                  final ClipboardData data = ClipboardData(text: text);
                  await Clipboard.setData(data);
                },
                onFavorite: () {},
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
    @required this.onCopy,
    @required this.onFavorite,
  }) : super(key: key);

  final FirestoreImage image;
  final Function() onCopy;
  final Function() onFavorite;

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
  Widget build(BuildContext context) {
    return Stack(
      key: ValueKey<String>(widget.image.id),
      children: <Widget>[
        MaterialButton(
          onPressed: () {},
          color: Colors.white,
          padding: const EdgeInsets.all(0),
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
              IconButton(
                onPressed: () {
                  widget.onFavorite();

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

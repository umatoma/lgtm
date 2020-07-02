import 'dart:async';
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lgtm/database/function_database.dart';
import 'package:transparent_image/transparent_image.dart';

class ImageSelectForm extends StatefulWidget {
  const ImageSelectForm({
    Key key,
    @required this.onFilePicked,
    @required this.onImageSelected,
  }) : super(key: key);

  final Function(PickedFile pickedFile) onFilePicked;
  final Function(FunctionImage functionImage) onImageSelected;

  @override
  _ImageSelectFormState createState() => _ImageSelectFormState();
}

class _ImageSelectFormState extends State<ImageSelectForm> {
  final FunctionDatabase function = FunctionDatabase();
  final ImagePicker picker = ImagePicker();
  final TextEditingController queryController = TextEditingController();

  Future<List<FunctionImage>> imagesFuture;
  StreamSubscription<PickedFile> fileSubscription;
  StreamSubscription<dynamic> errorSubscription;

  @override
  void initState() {
    super.initState();

    final _ImageDropZoneView view = _ImageDropZoneView.getInstance();
    fileSubscription = view.pickedFileStream.listen((PickedFile file) {
      widget.onFilePicked(file);
    });
    errorSubscription = view.errorStream.listen((dynamic event) {
      print(event.toString());
    });
  }

  @override
  void dispose() {
    fileSubscription.cancel();
    errorSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Text(
            'LGTM画像を作ろう!!',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(height: 16),
          // Text field
          Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Google画像検索'),
                  controller: queryController,
                  onSubmitted: (String _) {
                    setState(() {
                      imagesFuture =
                          function.searchImages(queryController.text);
                    });
                  },
                ),
              ),
              IconButton(
                onPressed: () async {
                  setState(() {
                    imagesFuture = function.searchImages(queryController.text);
                  });
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Image list
          Expanded(
            child: FutureBuilder<List<FunctionImage>>(
              future: imagesFuture,
              builder: (
                BuildContext context,
                AsyncSnapshot<List<FunctionImage>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.none) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Icon(Icons.arrow_upward),
                        SizedBox(height: 16),
                        Text(
                          '画像検索 or 画像アップロードで\nLGTM画像が作れます!!',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Icon(Icons.arrow_downward),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (snapshot.hasData) {
                    return _ImagesGridView(
                      images: snapshot.data,
                      onTap: (FunctionImage image) =>
                          widget.onImageSelected(image),
                    );
                  }
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          const SizedBox(height: 16),
          _ImageDropZone(),
          const SizedBox(height: 16),
          // Select image button
          Container(
            width: double.infinity,
            child: OutlineButton(
              onPressed: () async {
                final PickedFile pickedFile = await picker.getImage(
                  source: ImageSource.gallery,
                );
                widget.onFilePicked(pickedFile);
              },
              child: const Text('画像ファイル選択'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagesGridView extends StatelessWidget {
  const _ImagesGridView({
    Key key,
    @required this.images,
    @required this.onTap,
  }) : super(key: key);

  final List<FunctionImage> images;
  final Function(FunctionImage image) onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: images.map((FunctionImage image) {
        return MaterialButton(
          key: ValueKey<String>(image.link),
          onPressed: () => onTap(image),
          color: Colors.grey,
          padding: const EdgeInsets.all(0),
          child: SizedBox.expand(
            child: FadeInImage.memoryNetwork(
              fit: BoxFit.cover,
              placeholder: kTransparentImage,
              image: image.thumbnailLink,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ImageDropZoneView {
  _ImageDropZoneView._() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'image-drop-zone',
      (int viewId) {
        final DivElement element = DivElement()
          ..id = 'image-drop-zone-$viewId'
          ..addEventListener('drop', (Event event) {
            event.preventDefault();

            final DataTransferItemList items =
                (event as MouseEvent).dataTransfer.items;
            if (items.length > 0) {
              try {
                final DataTransferItem item = items[0];
                final File file = item.getAsFile();
                final String objectUrl = Url.createObjectUrl(file);
                final PickedFile pickedFile = PickedFile(objectUrl);

                _fileController.add(pickedFile);
              } catch (e) {
                _errorController.add(e);
              }
            }
          })
          ..addEventListener('dragover', (Event event) {
            event.preventDefault();
          });
        return element;
      },
    );
  }

  static _ImageDropZoneView _instance;
  static final StreamController<PickedFile> _fileController =
      StreamController<PickedFile>.broadcast();
  static final StreamController<dynamic> _errorController =
      StreamController<dynamic>.broadcast();

  static _ImageDropZoneView getInstance() {
    _instance ??= _ImageDropZoneView._();
    return _instance;
  }

  Stream<PickedFile> get pickedFileStream => _fileController.stream;
  Stream<dynamic> get errorStream => _errorController.stream;
}

class _ImageDropZone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192,
      child: Stack(
        children: <Widget>[
          const HtmlElementView(viewType: 'image-drop-zone'),
          Container(
            height: double.infinity,
            width: double.infinity,
            child: OutlineButton(
              onPressed: () {},
              child: const Text('ここに画像をドラッグ＆ドロップ!!'),
            ),
          ),
        ],
      ),
    );
  }
}

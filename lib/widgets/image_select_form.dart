import 'dart:html';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelectForm extends StatelessWidget {
  ImageSelectForm({
    Key key,
    @required this.onFilePicked,
  }) : super(key: key);

  final ImagePicker picker = ImagePicker();
  final Function(PickedFile pickedFile) onFilePicked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Text(
            'Create LGTM image',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(height: 16),
          // Text field
          Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Search Images'),
                  controller: TextEditingController(),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Image list
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List<Widget>.generate(12, (int index) {
                return MaterialButton(
                  key: ValueKey<String>('search-image-$index'),
                  onPressed: () {},
                  color: Colors.grey,
                  padding: const EdgeInsets.all(0),
                  child: SizedBox.expand(
                    child: CachedNetworkImage(
                      placeholder: (_, __) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      fit: BoxFit.cover,
                      imageUrl: 'https://dummyimage.com/600x400/ddd/000',
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          _ImageDropZone(
            onDrop: (PickedFile pickedFile) {
              onFilePicked(pickedFile);
            },
            onError: (dynamic e) {},
          ),
          const SizedBox(height: 16),
          // Select image button
          Container(
            width: double.infinity,
            child: OutlineButton(
              onPressed: () async {
                final PickedFile pickedFile = await picker.getImage(
                  source: ImageSource.gallery,
                );
                onFilePicked(pickedFile);
              },
              child: const Text('Select image'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageDropZone extends StatefulWidget {
  const _ImageDropZone({
    Key key,
    @required this.onDrop,
    @required this.onError,
  }) : super(key: key);

  final Function(PickedFile pickedFile) onDrop;
  final Function(dynamic e) onError;

  @override
  __ImageDropZoneState createState() => __ImageDropZoneState();
}

class __ImageDropZoneState extends State<_ImageDropZone> {
  bool isDragging = false;

  @override
  void initState() {
    super.initState();

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'image-drop-zone',
      (int viewId) {
        return DivElement()
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

                widget.onDrop(pickedFile);
              } catch (e) {
                widget.onError(e);
              }
            }
          })
          ..addEventListener('dragover', (Event event) {
            event.preventDefault();
          })
          ..addEventListener('dragenter', (Event event) {
            setState(() => isDragging = true);
          })
          ..addEventListener('dragleave', (Event event) {
            setState(() => isDragging = false);
          })
          ..className = 'HOGE'
          ..id = 'FUGA';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          width: 1,
          color: isDragging
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Stack(
        children: <Widget>[
          const HtmlElementView(viewType: 'image-drop-zone'),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Drop image here',
              style: TextStyle(
                color:
                    isDragging ? Theme.of(context).primaryColor : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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
  bool _isDragging = false;

  static bool _isRegistered = false;
  static void _register() {
    if (_isRegistered == true) {
      return;
    }

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'image-drop-zone',
      (int viewId) {
        final DivElement element = DivElement()
          ..id = 'image-drop-zone-$viewId'
          ..addEventListener('drop', (Event event) {
            print('drop');
            event.preventDefault();

            final DataTransferItemList items =
                (event as MouseEvent).dataTransfer.items;
            if (items.length > 0) {
              try {
                final DataTransferItem item = items[0];
                final File file = item.getAsFile();
                final String objectUrl = Url.createObjectUrl(file);
                final PickedFile pickedFile = PickedFile(objectUrl);

                // widget.onDrop(pickedFile);
              } catch (e) {
                // widget.onError(e);
              }
            }
          })
          ..addEventListener('dragover', (Event event) {
            event.preventDefault();
          })
          ..addEventListener('dragenter', (Event event) {
            // if (mounted) {
            //   setState(() => isDragging = true);
            // }
          })
          ..addEventListener('dragleave', (Event event) {
            // if (mounted) {
            //   setState(() => isDragging = false);
            // }
          });
        return element;
      },
    );
    _isRegistered = true;
  }

  @override
  void initState() {
    super.initState();

    _register();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          width: 1,
          color: _isDragging
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
              'ここにファイルをドラッグ＆ドロップ!!',
              style: TextStyle(
                color:
                    _isDragging ? Theme.of(context).primaryColor : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HtmlElementViewEx extends HtmlElementView {
  const HtmlElementViewEx({
    Key key,
    String viewType,
  }) : super(key: key, viewType: viewType);

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: viewType,
      onCreatePlatformView: _createHtmlElementView,
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
        return PlatformViewSurface(
          controller: controller,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
    );
  }

  /// Creates the controller and kicks off its initialization.
  _HtmlElementViewController _createHtmlElementView(
      PlatformViewCreationParams params) {
    final _HtmlElementViewController controller =
        _HtmlElementViewController(params.id, viewType);
    controller._initialize().then((_) {
      params.onPlatformViewCreated(params.id);
    });
    return controller;
  }
}

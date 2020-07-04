import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lgtm/database/firestore_database.dart';

class ImageCreatedView extends StatelessWidget {
  const ImageCreatedView({
    Key key,
    @required this.image,
    @required this.onClose,
  }) : super(key: key);

  final FirestoreImage image;
  final Function onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Text(
            'SUCCESS!!',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(height: 16),
          Card(
            child: Container(
              width: 344,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 194,
                    width: double.infinity,
                    child: Image.network(image.imageURL, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: FlatButton.icon(
                      onPressed: () async {
                        final String text = '![LGTM](${image.imageURL})';
                        final ClipboardData data = ClipboardData(text: text);
                        await Clipboard.setData(data);
                      },
                      icon: const Icon(Icons.content_copy),
                      label: const Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('クリップボードにコピー'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 64),
          OutlineButton(
            onPressed: () => onClose(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

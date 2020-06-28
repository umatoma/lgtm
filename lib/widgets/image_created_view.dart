import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lgtm/database/firestore_database.dart';

class ImageCreatedView extends StatelessWidget {
  const ImageCreatedView({
    Key key,
    @required this.image,
  }) : super(key: key);

  final FirestoreImage image;

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
          Container(
            height: 320,
            width: double.infinity,
            child: Image.network(image.imageURL, fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          OutlineButton.icon(
            onPressed: () async {
              final ClipboardData data = ClipboardData(text: image.imageURL);
              await Clipboard.setData(data);
            },
            icon: const Icon(Icons.content_copy),
            label: const Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Copy image URL'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlineButton.icon(
            onPressed: () async {
              final String text = '![LGTM](${image.imageURL})';
              final ClipboardData data = ClipboardData(text: text);
              await Clipboard.setData(data);
            },
            icon: const Icon(Icons.content_copy),
            label: const Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Copy Markdown'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

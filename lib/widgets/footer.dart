import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Text('LGTM Hub - powered by Flutter & Firebase'),
              Text('© umatoma'),
            ],
          ),
          const SizedBox(width: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('FlutterとFirebaseを使ったアプリ開発入門サイトも運営しています！'),
              InkWell(
                onTap: () => launch('https://www.flutter-study.dev'),
                child: Text(
                  'Flutterで始めるアプリ開発',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              const Text('MENTAにて学習サポートも行っています！'),
              InkWell(
                onTap: () => launch('https://menta.work/plan/1947'),
                child: Text(
                  '【初心者大歓迎】Flutterで始めるアプリ開発',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

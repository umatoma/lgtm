import 'package:flutter/material.dart';
import 'package:lgtm/widgets/footer.dart';
import 'package:lgtm/widgets/header.dart';
import 'package:lgtm/widgets/image_creation_container.dart';
import 'package:lgtm/widgets/image_list_container.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(LgtmApp());
}

class LgtmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const MaterialColor primarySwatch = Colors.lightBlue;
    return MaterialApp(
      title: 'LGTM Hub',
      theme: ThemeData(
        primarySwatch: primarySwatch,
        backgroundColor: Colors.grey[50],
        buttonTheme: const ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
        ),
        iconTheme: const IconThemeData(
          color: primarySwatch,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Header(
                onTapAboutButton: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => _AboutContainer()),
                  );
                },
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: ImageListContainer(),
                    ),
                    Expanded(
                      flex: 3,
                      child: ImageCreationContainer(),
                    ),
                  ],
                ),
              ),
              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Text(
                  'LGTM Hub - powered by Flutter & Firebase',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const Spacer(),
                OutlineButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('戻る'),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'LGTM Hub とは',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const Text('LGTM Hub とは、LGTM画像を作成・共有できるWebサイトです。'),
                const SizedBox(height: 16),
                Text(
                  '使い方',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 8),
                Text(
                  'LGTM画像を見る',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                const Text('最新・ランダム・お気に入りそれぞれのタブから共有されたLGTM画像を見ることができます。'),
                const SizedBox(height: 8),
                Text(
                  'LGTM画像を作る',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                const Text('Google画像検索・画像アップロードからLGTM画像を作ることができます。'),
                const SizedBox(height: 16),
                Text(
                  '連絡先',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const Text('当サイトに関するご連絡は以下までお願いいたします。'),
                InkWell(
                  onTap: () => launch('https://twitter.com/flutter_study'),
                  child: const Text('https://twitter.com/flutter_study'),
                ),
                const SizedBox(height: 16),
                Text(
                  '免責事項',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const Text(
                  '「LGTM Hub」（以下、「当サイト」とします。）'
                  'における免責事項は、下記の通りです。',
                ),
                const SizedBox(height: 8),
                Text(
                  '損害等の責任について',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                const Text(
                  '当サイトに掲載された内容によって生じた損害等の一切の責任を負いかねますので、ご了承ください。\n'
                  'また当サイトからリンクやバナーなどによって他のサイトに移動された場合、\n'
                  '移動先サイトで提供される情報、サービス等について一切の責任も負いません。\n'
                  '当サイトの保守、火災、停電、その他の自然災害、ウィルスや第三者の妨害等行為による不可抗力によって、\n'
                  '当サイトによるサービスが停止したことに起因して利用者に生じた損害についても、'
                  '何ら責任を負うものではありません。\n'
                  '当サイトを利用する場合は、自己責任で行う必要があります。',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

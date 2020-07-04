import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({
    Key key,
    @required this.onTapAboutButton,
  }) : super(key: key);

  final Function onTapAboutButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Text(
            'LGTM Hub - powered by Flutter & Firebase',
            style: Theme.of(context).textTheme.headline6,
          ),
          const Spacer(),
          OutlineButton(
            onPressed: () => onTapAboutButton(),
            child: const Text('このサイトについて'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lgtm/widgets/footer.dart';
import 'package:lgtm/widgets/header.dart';
import 'package:lgtm/widgets/image_creation_container.dart';
import 'package:lgtm/widgets/image_list_container.dart';

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
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Header(),
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

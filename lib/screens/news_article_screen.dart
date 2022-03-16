import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsArticleScreen extends StatefulWidget {
  final String newsName;
  final String title;
  final String href;
  const NewsArticleScreen(this.newsName, this.title, this.href, {Key? key})
      : super(key: key);

  @override
  State<NewsArticleScreen> createState() => _NewsArticleScreenState();
}

class _NewsArticleScreenState extends State<NewsArticleScreen> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    String href = '';
    if (widget.newsName.contains('시사인')) {
      href = 'https://www.sisain.co.kr' + widget.href;
    } else {
      Uri uri = Uri.parse(widget.href);
      href = Uri.https(uri.host, uri.path).toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: WebView(
        initialUrl: href,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

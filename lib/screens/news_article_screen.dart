import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../src/navigation_controls.dart';

class NewsArticleScreen extends StatefulWidget {
  final String title;
  final String href;
  final Completer<WebViewController> controller;
  const NewsArticleScreen(this.title, this.href, this.controller, {Key? key})
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
    Uri uri = Uri.parse(widget.href);
    if (uri.host.contains('sisain')) {
      href = Uri.https(uri.host, uri.path, uri.queryParameters).toString();
    } else {
      href = Uri.https(uri.host, uri.path).toString();
    }

    // int loadingPercentage = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [NavigationControls(controller: widget.controller)],
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: href,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (webViewController) {
              widget.controller.complete(webViewController);
            },
            // onPageStarted: (url) {
            //   setState(() {
            //     loadingPercentage = 0;
            //   });
            // },
            // onProgress: (progress) {
            //   setState(() {
            //     loadingPercentage = progress;
            //   });
            // },
            // onPageFinished: (url) {
            //   setState(() {
            //     loadingPercentage = 100;
            //   });
            // },
          ),
          // if (loadingPercentage < 100)
          //   Center(
          //     child: SizedBox(
          //       width: 300,
          //       child: LinearProgressIndicator(
          //         value: loadingPercentage / 100.0,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

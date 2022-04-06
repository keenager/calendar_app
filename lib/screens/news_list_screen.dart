import 'dart:async';
import 'package:calendar_app/screens/news_article_screen.dart';
import 'package:flutter/material.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:webview_flutter/webview_flutter.dart';

const List newsData = [
  {
    'newsName': '한겨레 사설,칼럼',
    'url': 'https://www.hani.co.kr/arti/opinion/editorial',
    'selector': 'div.list h4.ranktitle > a'
  },
  {
    'newsName': '한겨례 많이 본 기사',
    'url': 'https://www.hani.co.kr/arti/list.html',
    'selector': 'div.list h4.ranktitle > a'
  },
  // {
  //   'newsName': '경향 오피니언',
  //   'url': 'https://www.khan.co.kr/opinion',
  //   'selector': 'div.art-list li a'
  // },
  // {
  //   'newsName': '경향 종합 실시간',
  //   'url': 'https://www.khan.co.kr/realtime/articles',
  //   'selector': 'div.art-list li a'
  // },
  {
    'newsName': '시사인 주요 기사 1',
    'url': 'https://www.sisain.co.kr',
    'selector': 'li.auto-col > a'
  },
  {
    'newsName': '시사인 주요 기사 2',
    'url': 'https://www.sisain.co.kr',
    'selector': 'li.clearfix > a.cover'
  },
  {
    'newsName': '중앙 사설,칼럼',
    'url': 'https://www.joongang.co.kr/opinion/editorialcolumn',
    'selector': 'div.card_body h2 > a'
  },
  {
    'newsName': '뉴스 페퍼민트',
    'url': 'https://newspeppermint.com/',
    'selector': 'h6 a'
  },
];

class News {
  final String newsName;
  final String url;
  final String selector;

  const News(this.newsName, this.url, this.selector);
  Future<List<Map<String, dynamic>>> fetchData() async {
    List<Map<String, dynamic>> newsList = [];
    Uri uri = Uri.parse(url);
    final webSraper = WebScraper(uri.origin);
    if (await webSraper.loadWebPage(uri.path)) {
      newsList = webSraper.getElement(selector, ['href']);
      if (newsName.contains('중앙')) {
        newsList.removeRange(0, 5); //중앙사설칼럼은 앞에 5개가 불필요한 것이어서 삭제
      }
      for (var e in newsList) {
        e.addAll({'newsName': newsName});
      }
      newsList.insert(0, {'newsName': newsName});
    }
    return newsList;
  }
}

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({Key? key}) : super(key: key);

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait(newsData.map((elem) =>
          News(elem['newsName'], elem['url'], elem['selector']).fetchData())),
      builder: (BuildContext context,
          AsyncSnapshot<List<List<Map<String, dynamic>>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text('No data...'),
          );
        }
        List<Map<String, dynamic>> newsList = [];
        for (var e in snapshot.data!) {
          newsList = [...newsList, ...e];
        }
        return ListView.separated(
          itemCount: newsList.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            return newsList[index].keys.length == 1
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      child: Text(
                        newsList[index]['newsName'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : ListTile(
                    title: Text(newsList[index]['title'].replaceAll('\n', '')),
                    // subtitle:
                    //     Text(newsList[index]['attributes']?['href'] ?? 'null'),
                    visualDensity: const VisualDensity(vertical: -4),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsArticleScreen(
                            newsList[index]['newsName'],
                            newsList[index]['title'],
                            newsList[index]['attributes']['href'],
                            controller,
                          ),
                        ),
                      );
                    },
                  );
          },
        );
      },
    );
  }
}

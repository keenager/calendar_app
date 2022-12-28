import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;

Future<List<Map<String, String?>>> getArticleList(
    Map<String, String> newsData) async {
  String url = newsData['url']!;
  http.Response response = await http.get(Uri.parse(url));

  dom.Document document = parse(response.body);
  var elemList = document.querySelectorAll(newsData['selector']!);

  if (url.contains('lawtimes')) {
    elemList = elemList.sublist(0, 5);
  }

  var articleList = elemList.map((elem) {
    String title = elem.querySelector('a')!.text.trim();
    String link = elem.querySelector('a')!.attributes['href']!;

    if (url.contains('sisain')) {
      link = 'https://www.sisain.co.kr$link';
    }
    if (url.contains('lawtimes')) {
      link = 'https://m.lawtimes.co.kr$link';
    }

    return {
      'title': title,
      'link': link,
    };
  }).toList();
  return articleList;
}

import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;

Future<List<Map<String, String?>>> getArticleList(
    Map<String, String> newsData) async {
  String url = newsData['url']!;
  http.Response response = await http.get(Uri.parse(url));
  dom.Document document = parse(response.body);
  var elemList = document.querySelectorAll(newsData['selector']!);
  var articleList = elemList.map((elem) {
    String title = elem.querySelector('a')!.text.trim();
    String link = elem.querySelector('a')!.attributes['href']!;
    link = url.contains('sisain') ? 'https://www.sisain.co.kr$link' : link;

    return {
      'title': title,
      'link': link,
    };
  }).toList();
  return articleList;
}

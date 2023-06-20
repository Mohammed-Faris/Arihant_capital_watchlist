import 'package:msil_library/models/base/base_model.dart';

class QuoteNewsModel extends BaseModel {
  List<News>? newsHeadlines;

  QuoteNewsModel({this.newsHeadlines});

  QuoteNewsModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    if (data['newsHeadlines'] != null) {
      newsHeadlines = <News>[];
      data['newsHeadlines'].forEach((v) {
        newsHeadlines!.add(News.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (newsHeadlines != null) {
      data['newsHeadlines'] = newsHeadlines!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class News {
  String? serialNo;
  String? caption;
  String? date;
  String? headline;

  News({this.serialNo, this.caption, this.date, this.headline});

  News.fromJson(Map<String, dynamic> json) {
    serialNo = json['serialNo'];
    caption = json['caption'];
    date = json['date'];
    headline = json['headline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['serialNo'] = serialNo;
    data['caption'] = caption;
    data['date'] = date;
    data['headline'] = headline;
    return data;
  }
}

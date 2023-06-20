import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/app_constants.dart';
import '../../data/store/app_utils.dart';
import '../screens/acml_app.dart';
import '../styles/app_widget_size.dart';
import 'shimmer_widget.dart';

class CustomTextWidget extends StatefulWidget {
  final String title;
  final TextStyle? style;
  final TextOverflow textOverflow;
  final TextAlign textAlign;
  final Function(String)? onTap;
  final bool isShowShimmer;
  final double shimmerWidth;
  final double shimmerPadding;
  final bool forceShimmer;
  final bool isRupee;
  final EdgeInsetsGeometry? padding;
  const CustomTextWidget(
    this.title,
    this.style, {
    Key? key,
    this.padding,
    this.isRupee = false,
    this.textOverflow = TextOverflow.visible,
    this.textAlign = TextAlign.justify,
    this.onTap,
    this.forceShimmer = false,
    this.isShowShimmer = false,
    this.shimmerWidth = 100,
    this.shimmerPadding = 0,
  }) : super(key: key);

  @override
  State<CustomTextWidget> createState() => _CustomTextWidgetState();
}

class _CustomTextWidgetState extends State<CustomTextWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: customTextWidget(
          widget.isRupee
              ? "${AppConstants.rupeeSymbol} ${widget.title}"
              : widget.title,
          widget.style,
          textAlign: widget.textAlign,
          textOverflow: widget.textOverflow,
          onTap: widget.onTap),
    );
  }

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return s.contains(RegExp(r'[0-9]'));
  }

  Widget customTextWidget(String title, TextStyle? style,
      {TextOverflow? textOverflow,
      TextAlign textAlign = TextAlign.justify,
      Function(String)? onTap}) {
    var stext = title.split("₹");
    var quetext = title.split("?");
    var bullettext = title.split("•");
    var headingText = title.split("/h");
    var boldText = title.split("/b");
    var smallText = title.split("/s");
    var linktext = title.split("/link");
    return ((title.isEmpty || !isNumeric(title)) && widget.isShowShimmer) ||
            widget.forceShimmer
        ? _buildShimmerWidget()
        : stext.length == 1 &&
                bullettext.length == 1 &&
                headingText.length == 1 &&
                quetext.length == 1 &&
                linktext.length == 1 &&
                boldText.length == 1 &&
                smallText.length == 1
            ? Text(
                title,
                style: style,
                overflow: textOverflow,
                textAlign: textAlign,
              )
            : richText(title, style, onTap, textAlign);
  }

  Widget _buildShimmerWidget() {
    return ShimmerWidget(
      height: ((widget.style?.fontSize?.toDouble() ?? 12.w) +
          widget.shimmerPadding),
      baseColor: AppUtils().isLightTheme()
          ? const Color(0xFFF2F2F2)
          : const Color(0xFFB3B3B3).withOpacity(0.4),
      highlightColor: AppUtils().isLightTheme()
          ? const Color(0xFFE0E0E0)
          : const Color(0xFF8D8D93),
      width: widget.shimmerWidth,
    );
  }

  TextSpan textSPan(
      String data, TextStyle? text, TextAlign textAlign, TextSpan widget) {
    return widget;
  }

  Widget richText(
    String fullText,
    TextStyle? style,
    Function(String)? onTap,
    TextAlign textAlign,
  ) {
    return ParsedText(
      text: fullText,
      style: style,
      alignment: textAlign,
      onTap: () {},
      parse: <MatchText>[
        MatchText(
            pattern: r'(/bu)(.*)(/bu)',
            renderWidget: ({required pattern, required text}) => Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: AppWidgetSize.dimen_5),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "•",
                          style: style,
                          textAlign: textAlign,
                        ),
                        Flexible(
                          child: Text(
                            text.replaceAll("/bu", ""),
                            style: style,
                            textAlign: textAlign,
                          ),
                        ),
                      ]),
                )),
        MatchText(
          pattern: r'\?',
          renderWidget: ({required pattern, required text}) => Text(
            "?",
            style: style?.copyWith(fontFamily: AppConstants.interFont),
          ),
        ),
        MatchText(
          pattern: r'(/svg)(.*)(/svg)',
          renderWidget: ({required pattern, required text}) =>
              SvgPicture.asset(text.replaceAll("/svg", "")),
        ),
        MatchText(
          pattern: r'(/h)(.*)(/h)',
          renderText: ({required pattern, required str}) {
            var re = RegExp(r'(/h)(.*)(/h)');
            Match match = re.firstMatch(str)!;

            return {'display': '\n${match[0]?.replaceAll("/h", "")}\n'};
          },
          style: style?.copyWith(fontWeight: FontWeight.bold),
        ),
        MatchText(
          pattern: r'(/s)(.*)(/s)',
          renderText: ({required pattern, required str}) {
            var re = RegExp(r'(/s)(.*)(/s)');
            Match match = re.firstMatch(str)!;

            return {'display': '${match[0]?.replaceAll("/s", "")}'};
          },
          style: style?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: ((style.fontSize ?? 0) * 0.4)),
        ),
        MatchText(
          pattern: r'(/link)(.*)(/link)',
          renderWidget: ({required pattern, required text}) => Text(
              text.replaceAll("/link", "").replaceAll(RegExp('[0-9]'), ""),
              textDirection: TextDirection.ltr,
              style: style?.copyWith(
                  decoration: TextDecoration.underline,
                  color: Theme.of(navigatorKey.currentContext!).primaryColor)),
          onTap: (e) {
            if (onTap != null) {
              onTap(
                  e.replaceAll("/link", "").replaceAll(RegExp(r'[^0-9]'), ''));
            }
          },
        ),
        MatchText(
          pattern: r'(/b)(.*)(/b)',
          renderText: ({required pattern, required str}) {
            var re = RegExp(r'(/b)(.*)(/b)');
            Match match = re.firstMatch(str)!;

            return {'display': '${match[0]?.replaceAll("/b", "")}'};
          },
          style: style?.copyWith(fontWeight: FontWeight.bold),
        ),
        MatchText(
          pattern: r'₹',
          renderText: ({required pattern, required str}) {
            var re = RegExp(r'₹');
            Match match = re.firstMatch(str)!;

            return {'display': '${match[0]}'};
          },
          style: style?.copyWith(
              fontFamily: AppConstants.interFont,
              fontWeight: widget.style?.fontWeight == FontWeight.w600
                  ? FontWeight.w700
                  : widget.style?.fontWeight),
        ),
      ],
    );
  }
}

class DottedText extends Text {
  const DottedText(
    String data, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
  }) : super(
          '\u2022 $data',
          key: key,
          style: style,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
        );
}

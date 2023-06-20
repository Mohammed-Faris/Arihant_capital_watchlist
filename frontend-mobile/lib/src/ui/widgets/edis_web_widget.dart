import 'dart:convert';
import 'dart:typed_data';

import 'package:acml/src/ui/styles/app_widget_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../models/edis/verify_edis_model.dart';
import '../styles/app_images.dart';

Widget edisWebViewWidget(
  BuildContext context,
  Edis edisData,
  bool isCdsl,
  Function onCallBack,
  Function onCloseCallBack, {
  bool isTpinScreen = false,
}) {
  InAppWebViewController webViewController;
  bool isClosedSelected = false;
  return Stack(
    fit: StackFit.expand,
    children: <Widget>[
      Scaffold(
        body: InAppWebView(
          onWebViewCreated: (InAppWebViewController controller) {
            webViewController = controller;
            // print(
            //   getPostDataParamsForWebview(
            //     edisData.params!,
            //     edisData.fName!,
            //   ),
            // );
            webViewController.postUrl(
              url: Uri.parse(edisData.url!),
              postData: Uint8List.fromList(
                utf8.encode(
                  getPostDataParamsForWebview(
                    edisData.params!,
                    edisData.fName!,
                  ),
                ),
              ),
            );
          },
          onConsoleMessage: (InAppWebViewController controller,
              ConsoleMessage consoleMessage) {
            // print(consoleMessage);
          },
          onLoadStart: (controller, url) {
            // print('onLoadStart url $url');
          },
          onLoadStop: (controller, url) {
            // print('onLoadStop url $url');
            if (url.toString().startsWith(edisData.listenUrl!)) {
              onCallBack(url);
            }
          },
        ),
      ),
      Positioned(
        top: 20.w,
        right: 20.w,
        child: GestureDetector(
          onTap: () {
            if (!isClosedSelected) onCloseCallBack();
            isClosedSelected = true;
          },
          child: AppImages.close(
            context,
          ),
        ),
      )
    ],
  );
}

String getPostDataParamsForWebview(
  List<Params> params,
  String fName,
) {
  String name = fName;
  params.add(Params(key: 'name', value: name));
  String postData = '';

  params.asMap().forEach((index, element) {
    postData += element.key!;
    postData += '=';
    postData += Uri.encodeComponent(element.value!);

    if (index != params.length - 1) postData += '&';
  });
  return postData;
}

import 'dart:async';

import 'package:acml/src/data/store/app_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../screens/base/base_screen.dart';
import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';
import 'loader_widget.dart';

class WebviewWidget extends BaseScreen {
  final String title;
  final String redirectURL;
  final bool pop;
  const WebviewWidget(this.title, this.redirectURL,
      {this.pop = false, Key? key})
      : super(key: key);

  @override
  WebviewWidgetState createState() => WebviewWidgetState();
}

class WebviewWidgetState extends BaseAuthScreenState<WebviewWidget> {
  late InAppWebViewController inAppWebViewController;

  final ValueNotifier<bool> isWebViewLoaded = ValueNotifier<bool>(false);

  Future<bool> _exitApp(BuildContext context) async {
    /*  final bool canWeGoBack = await inAppWebViewController.canGoBack();
    print(canWeGoBack.toString());
    if (canWeGoBack) {
      inAppWebViewController.goBack();
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      return Future<bool>.value(true);
    } */
    if (await inAppWebViewController.canGoBack()) {
      inAppWebViewController.goBack();
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
    return Future<bool>.value(false);
  }

  late final WebViewController webcontroller;

  @override
  void initState() {
    // ignore: no_leading_underscores_for_local_identifiers
    final WebViewController _controller = WebViewController();
    // #enddocregion platform_features
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..clearCache()
      ..clearLocalStorage();
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller.loadRequest(Uri.parse(widget.redirectURL.trim()));

    webcontroller = _controller;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: backIconButton(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: AppWidgetSize.dimen_25),
                      child: CustomTextWidget(
                        widget.title,
                        Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => {
                    //  Navigator.of(context).pop(),
                    AppUtils().launchBrowser(widget.redirectURL.trim())
                  },
                  child: Icon(
                    Icons.launch_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            )),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      onWebViewCreated: (controller) =>
                          inAppWebViewController = controller,
                      gestureRecognizers: {
                        Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer())
                      },
                      androidOnPermissionRequest:
                          (InAppWebViewController controller, String origin,
                              List<String> resources) async {
                        return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        var uri = navigationAction.request.url!;

                        if (![
                          "http",
                          "https",
                          "file",
                          "chrome",
                          "data",
                          "javascript",
                          "about"
                        ].contains(uri.scheme)) {
                          if (await canLaunchUrl(uri)) {
                            // Launch the App
                            await launchUrl(
                              uri,
                            );
                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                            javaScriptEnabled: true,
                            incognito: true,
                            cacheEnabled: false,
                            transparentBackground: true,
                            verticalScrollBarEnabled: true,
                            mediaPlaybackRequiresUserGesture: false,
                            clearCache: true,
                            useOnDownloadStart: true),
                      ),
                      onDownloadStartRequest: (controller, url) async {
                        final urlFiles = url.url;
                        // ignore: no_leading_underscores_for_local_identifiers
                        await canLaunchUrl(urlFiles)
                            ? AppUtils().launchBrowser(urlFiles.toString())
                            : throw 'Could not launch $urlFiles';
                      },
                      onLoadStop: (controller, url) =>
                          isWebViewLoaded.value = true,
                      initialUrlRequest:
                          URLRequest(url: Uri.parse(widget.redirectURL.trim())),
                    ),
                    ValueListenableBuilder(
                      valueListenable: isWebViewLoaded,
                      builder: (context, value, child) => isWebViewLoaded.value
                          ? Container()
                          : Positioned(
                              child: Container(
                                alignment: Alignment.center,
                                child: const LoaderWidget(),
                              ),
                            ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

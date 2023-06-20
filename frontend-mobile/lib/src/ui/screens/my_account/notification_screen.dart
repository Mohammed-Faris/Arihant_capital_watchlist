import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../blocs/notification/notification_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/notification/global_user_notification_model.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/refresh_widget.dart';
import '../../widgets/webview_widget.dart';
import '../base/base_screen.dart';
import '../route_generator.dart';

class NotificationScreen extends BaseScreen {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends BaseAuthScreenState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    fetchApi();
    sendPushLogsToServer();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.notificationScreen);
  }

  Future<void> fetchApi() async {
    BlocProvider.of<NotificationBloc>(context).add(
      GetAllNotificationEvent(),
    );
    BlocProvider.of<NotificationBloc>(context)
        .stream
        .listen(_notificationListener);
  }

  Future<void> _notificationListener(
    NotificationState state,
  ) async {
    if (state is NotificationDoneState) {
      List<String> unreadNotificationIDList = [];
      if (state.globalAndUserNotificationsModel.messages != null &&
          state.globalAndUserNotificationsModel.messages!.isNotEmpty) {
        for (final Messages item
            in state.globalAndUserNotificationsModel.messages!) {
          if (item.msgType == AppConstants.userPush && item.isRead == 0) {
            unreadNotificationIDList.add(item.notificationID!);
          }
        }
        if (unreadNotificationIDList.isNotEmpty) {
          BlocProvider.of<NotificationBloc>(context).add(
            UpdateNotificationStatusEvent(unreadNotificationIDList),
          );
        }
      }
    } else if (state is NotificationErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(),
        body: _buildBodyWidget(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: false,
      elevation: 0.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 10.w,
              right: 10.w,
            ),
            child: backIconButton(
              customColor: Theme.of(context).primaryIconTheme.color,
            ),
          ),
          CustomTextWidget(
            AppLocalizations().notification,
            Theme.of(context).primaryTextTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyWidget() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      buildWhen: (previous, current) {
        return current is NotificationDoneState ||
            current is NotificationProgressState ||
            current is NotificationFailedState ||
            current is NotificationServiceExceptionState;
      },
      builder: (BuildContext context, NotificationState state) {
        if (state is NotificationProgressState) {
          return const LoaderWidget();
        }
        if (state is NotificationDoneState) {
          if (state.globalAndUserNotificationsModel.messages != null) {
            return _buildNotificationList(
              state.globalAndUserNotificationsModel.messages!,
            );
          } else {
            return errorWithImageWidget(
              context: context,
              imageWidget: AppImages.noDealsImage(context),
              errorMessage: AppLocalizations().noDataAvailableErrorMessage,
              padding: EdgeInsets.only(
                left: 30.w,
                right: 30.w,
                bottom: 30.w,
              ),
            );
          }
        } else if (state is NotificationFailedState) {
          return errorWithImageWidget(
            context: context,
            imageWidget: AppImages.noDealsImage(context),
            errorMessage: AppLocalizations().noDataAvailableErrorMessage,
            padding: EdgeInsets.only(
              left: 30.w,
              right: 30.w,
              bottom: 30.w,
            ),
          );
        } else if (state is NotificationServiceExceptionState) {
          return errorWithImageWidget(
            context: context,
            imageWidget: AppUtils().getNoDateImageErrorWidget(context),
            errorMessage: state.errorMsg,
            padding: EdgeInsets.only(
              left: 30.w,
              right: 30.w,
              bottom: 30.w,
            ),
          );
        }

        return Container();
      },
    );
  }

  Widget _buildNotificationList(
    List<Messages> globalMessages,
  ) {
    return RefreshWidget(
      onRefresh: fetchApi,
      child: Container(
        padding: EdgeInsets.only(
          left: 30.w,
          right: 30.w,
          top: 20.w,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: globalMessages.length,
          itemBuilder: (BuildContext context, int index) {
            final Messages item = globalMessages[index];
            final ExtraInfoModel metaInfoModel = ExtraInfoModel.fromJson(
                json.decode(item.extraInfo!) as Map<String, dynamic>);
            return _buildNotificationRowWidget(
              item,
              metaInfoModel,
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationRowWidget(
    Messages item,
    ExtraInfoModel metaInfoModel,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 10.w, bottom: 2.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.w),
                child: AppImages.marketsPullDown(
                  context,
                  height: 40.w,
                  width: 44.w,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleAndTimeWidget(item),
                _buildPushMessageWidget(item),
                if (item.target != null &&
                    item.target!.isNotEmpty &&
                    Uri.parse(item.target!).isAbsolute)
                  _buildTargetWidget(item),
                if (metaInfoModel.image != null &&
                    metaInfoModel.image!.isNotEmpty)
                  _buildImageWidget(metaInfoModel),
                if (metaInfoModel.video != null &&
                    metaInfoModel.video!.isNotEmpty)
                  _buildVideoWidget(
                    metaInfoModel,
                    item,
                  ),
              ],
            ),
          ],
        ),
        _buildDivider()
      ],
    );
  }

  Widget _buildTitleAndTimeWidget(
    Messages item,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: AppWidgetSize.fullWidth(context) - 110.w,
            child: Text(
              item.title!,
              style: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(fontWeight: FontWeight.w600),
              maxLines: 3,
            ),
          ),
          SizedBox(
            // width: AppWidgetSize.fullWidth(context) / 2 - 60,
            child: Text(
              item.createdAt!,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPushMessageWidget(
    Messages item,
  ) {
    return SizedBox(
      width: AppWidgetSize.fullWidth(context) - 110.w,
      child: Linkify(
        onOpen: (e) {
          AppUtils().launchBrowser(e.url);
        },
        style: Theme.of(context).primaryTextTheme.bodySmall,
        text: item.pushMsg!,
      ),
    );
  }

  Widget _buildTargetWidget(
    Messages item,
  ) {
    return SizedBox(
      width: AppWidgetSize.fullWidth(context) - 110.w,
      child: GestureDetector(
        onTap: () {
          AppUtils().launchBrowser(item.target);
        },
        child: Text(
          item.target!,
          style: Theme.of(context)
              .primaryTextTheme
              .titleLarge!
              .copyWith(decoration: TextDecoration.underline),
          maxLines: 5,
        ),
      ),
    );
  }

  Widget _buildImageWidget(
    ExtraInfoModel metaInfoModel,
  ) {
    return Container(
      width: AppWidgetSize.fullWidth(context) - 110.w,
      padding: EdgeInsets.symmetric(vertical: 20.w),
      child: Image.network(
        metaInfoModel.image!,
        width: AppWidgetSize.fullHeight(context),
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoWidget(
    ExtraInfoModel metaInfoModel,
    Messages item,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 10.w),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            SlideRoute(
              settings: const RouteSettings(
                name: ScreenRoutes.inAppWebview,
              ),
              builder: (BuildContext context) => WebviewWidget(
                item.title!,
                metaInfoModel.video!,
                key: Key(AppLocalizations().webContentTitle),
              ),
            ),
          );
        },
        child: Stack(
          children: [
            FutureBuilder(
              future: getImage(
                metaInfoModel.video!,
                AppWidgetSize.fullWidth(context) - 110.w,
                AppWidgetSize.dimen_200,
              ),
              builder: (context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return Container();
              },
            ),
            Positioned(
              right: AppWidgetSize.fullWidth(context) / 2 - 80.w,
              top: 50.w,
              child: Center(
                child: AppImages.playIcon(
                  context,
                  isColor: true,
                  width: 50.w,
                  height: 50.w,
                  color: Colors.green.shade50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Widget> getImage(
    String videoLink,
    double width,
    double height,
  ) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoLink,
      imageFormat: ImageFormat.PNG,
      maxWidth: AppUtils().intValue(width),
      maxHeight: AppUtils().intValue(height),
      quality: 50,
    );

    return SizedBox(
      width: width,
      height: height - 50.w,
      child: Image.memory(
        uint8list!,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_15,
        bottom: AppWidgetSize.dimen_15,
      ),
      child: Divider(
        height: AppWidgetSize.dimen_1,
        thickness: 1.0,
      ),
    );
  }
}

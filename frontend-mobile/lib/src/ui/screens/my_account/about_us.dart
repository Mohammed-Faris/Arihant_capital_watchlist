import 'package:flutter/material.dart';

import '../../../blocs/my_accounts/client_details/clientdetails_bloc.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../base/base_screen.dart';

class AboutUs extends BaseScreen {
  const AboutUs({
    Key? key,
  }) : super(key: key);

  @override
  AboutUsState createState() => AboutUsState();
}

class AboutUsState extends BaseAuthScreenState<AboutUs> {
  late ClientdetailsBloc clientdetailsBloc;

  @override
  void initState() {
    super.initState();
    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.aboutUs);
  }

  @override
  Widget build(BuildContext context) {
    return bodyWidget(context);
  }

  Scaffold bodyWidget(
    BuildContext context,
  ) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                Image(
                  width: AppWidgetSize.screenWidth(context),
                  image: AppImages.aboutUsBanner(),
                  fit: BoxFit.fill,
                ),
                /* AppImages.aboutUsBanner(
                  context,
                ), */
                topBar(context),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppWidgetSize.dimen_30,
                  vertical: AppWidgetSize.dimen_10),
              child: Column(
                children: [
                  CustomTextWidget(
                      AppLocalizations().aboutus1,
                      Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w500),
                      textAlign: TextAlign.justify),
                  Padding(
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_20),
                    child: CustomTextWidget(AppLocalizations().aboutus2,
                        Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.justify),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30.w, bottom: 20.h),
                    child: CustomTextWidget(
                        AppLocalizations().aboutus3,
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: AppWidgetSize.fontSize16),
                        textAlign: TextAlign.justify),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  Container topBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_18, left: 30.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: backIconButton(),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: CustomTextWidget(
                AppLocalizations().aboutUs,
                Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

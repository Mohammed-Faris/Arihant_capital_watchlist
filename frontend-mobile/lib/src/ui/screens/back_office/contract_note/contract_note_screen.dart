import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:flutter/material.dart';

import '../../../../data/store/app_utils.dart';
import '../../../../localization/app_localization.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/circular_toggle_button_widget.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/gradient_button_widget.dart';
import 'widgets/custom_date_selector.dart';

class ContractNoteScreen extends BaseScreen {
  const ContractNoteScreen({Key? key}) : super(key: key);

  @override
  State<ContractNoteScreen> createState() => _ContractNoteScreenState();
}

class _ContractNoteScreenState extends BaseScreenState<ContractNoteScreen> {
  final List<String> _tabs = ["All", "Equity", "Commodity"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        title: _topBar(context),
        actions: [_filterIcon()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: 15.w, horizontal: AppWidgetSize.dimen_20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _fromDate(),
                SizedBox(width: AppWidgetSize.dimen_12),
                _toDate(),
                _buildTick(showCancel: true, showDone: false)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: AppWidgetSize.dimen_20,
                right: AppWidgetSize.dimen_20,
                bottom: AppWidgetSize.dimen_5),
            child: CircularButtonToggleWidget(
              value: _tabs.first,
              toggleButtonlist: _tabs,
              toggleButtonOnChanged: () {},
              marginEdgeInsets: EdgeInsets.only(
                right: AppWidgetSize.dimen_1,
                top: AppWidgetSize.dimen_6,
              ),
              paddingEdgeInsets: EdgeInsets.symmetric(
                horizontal: AppWidgetSize.dimen_14,
                vertical: AppWidgetSize.dimen_6,
              ),
              activeButtonColor: AppUtils().isLightTheme()
                  ? Theme.of(context)
                      .snackBarTheme
                      .backgroundColor!
                      .withOpacity(0.5)
                  : Theme.of(context).primaryColor,
              activeTextColor: AppUtils().isLightTheme()
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColorLight,
              inactiveButtonColor: Colors.transparent,
              inactiveTextColor: Theme.of(context).primaryColor,
              key: const Key("options_"),
              defaultSelected: '',
              enabledButtonlist: const [],
              isBorder: false,
              context: context,
              borderColor: Colors.transparent,
              fontSize: 18.w,
            ),
          ),
          Expanded(
            // child: _defaultPageData(),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                  horizontal: AppWidgetSize.dimen_20,
                  vertical: AppWidgetSize.dimen_10.w),
              itemBuilder: (context, index) => _listTile(),
              separatorBuilder: (context, index) => const Divider(thickness: 1),
              itemCount: 3,
            ),
          )
        ],
      ),
    );
  }

  _listTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
      title: CustomTextWidget(
          "26 APR 2023",
          Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(fontWeight: FontWeight.w600)),
      subtitle: CustomTextWidget(
        "Equity",
        padding: EdgeInsets.only(top: 5.w),
        Theme.of(context).textTheme.bodySmall!,
      ),
      trailing: gradientButtonWidget(
        onTap: () async {},
        height: AppWidgetSize.dimen_35,
        width: 100.w,
        fontsize: AppWidgetSize.dimen_16,
        context: context,
        bottom: 0,
        key: const Key("download"),
        title: "Download",
        isGradient: false,
      ),
      onTap: () {},
    );
  }

  Widget _fromDate() => Expanded(
      child: CustomDateSelector(
          controller: TextEditingController(), labelText: "From"));

  Widget _toDate() => Expanded(
      child: CustomDateSelector(
          controller: TextEditingController(), labelText: "To"));

  Widget _buildTick({required bool showCancel, required bool showDone}) {
    return GestureDetector(
      child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: showCancel
              ? AppImages.crossButton(context)
              : showDone
                  ? AppImages.tickEnable(context,
                      color: Theme.of(context).primaryIconTheme.color,
                      isColor: true)
                  : AppImages.tickDisable(context,
                      color: Theme.of(context).textTheme.displaySmall!.color,
                      isColor: true)),
      onTap: () {},
    );
  }

  _filterIcon() {
    return IconButton(
      icon: AppImages.filterIcon(context,
          isColor: true,
          color: Theme.of(context).primaryTextTheme.labelSmall!.color),
      onPressed: () {},
    );
  }

  _infoIcon() {
    return InkWell(
      child: AppImages.infoIcon(
        context,
        color: Theme.of(context).primaryIconTheme.color,
        isColor: true,
      ),
      onTap: () {},
    );
  }

  _topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: backIconButton(),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: AppWidgetSize.dimen_25, right: AppWidgetSize.dimen_8),
          child: CustomTextWidget(
            AppLocalizations().contractNote,
            Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        _infoIcon()
      ],
    );
  }

  _defaultPageData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTextWidget(
            "Select custom date",
            Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(fontWeight: FontWeight.w500),
          ),
          CustomTextWidget(
            'View contract note for the period of your choice',
            Theme.of(context).textTheme.labelSmall!,
            textAlign: TextAlign.center,
            padding: const EdgeInsets.symmetric(vertical: 15),
          )
        ],
      ),
    );
  }
}

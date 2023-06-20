import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/alert_settings/alert_settings_bloc.dart';
import '../../../localization/app_localization.dart';
import '../../styles/app_widget_size.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/material_switch.dart';
import '../base/base_screen.dart';

class AlertSettings extends BaseScreen {
  const AlertSettings({Key? key}) : super(key: key);

  @override
  State<AlertSettings> createState() => _AlertSettingsState();
}

class _AlertSettingsState extends BaseAuthScreenState<AlertSettings> {
  final AlertSettingsBloc alertSettingsBloc = AlertSettingsBloc();

  @override
  void initState() {
    alertSettingsBloc.add(FetchAlertSettingsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          title: topBar(context),
        ),
        body: BlocBuilder<AlertSettingsBloc, AlertSettingsState>(
          bloc: alertSettingsBloc,
          builder: (context, state) {
            if (state is AlertSettingsLoading) {
              return const LoaderWidget();
            } else if (state is AlertSettingsDone) {
              return ListView.separated(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppWidgetSize.dimen_25.w,
                      vertical: AppWidgetSize.dimen_10.w),
                  itemBuilder: (context, index) => _alertListItem(
                        index,
                        state.settingsList[index],
                        state.settingsValue[index],
                      ),
                  separatorBuilder: (context, index) =>
                      SizedBox(height: AppWidgetSize.dimen_15.w),
                  itemCount: state.settingsList.length);
            } else {
              return const SizedBox();
            }
          },
        ));
  }

  Container _alertListItem(int index, String label, bool val) {
    return Container(
        height: 50.w,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: Theme.of(context).dividerColor)),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextWidget(
                label,
                Theme.of(context)
                    .primaryTextTheme
                    .labelSmall!
                    .copyWith(fontWeight: FontWeight.w500)),
            MaterialSwitch(
              onChanged: (value) {
                alertSettingsBloc.add(UpdateAlertSettingsEvent(index));
              },
              value: val,
              inactiveThumbColor: Theme.of(context).primaryColor,
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveTrackColor:
                  Theme.of(context).snackBarTheme.backgroundColor,
              activeColor: Colors.white,
            )
          ],
        ));
  }

  topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: backIconButton(),
        ),
        Padding(
          padding: EdgeInsets.only(left: AppWidgetSize.dimen_25),
          child: CustomTextWidget(
            AppLocalizations().alertSettings,
            Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ],
    );
  }
}

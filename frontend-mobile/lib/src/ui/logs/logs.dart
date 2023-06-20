// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_logger/core/constants.dart';
import 'package:my_logger/logger.dart';

import '../../config/app_config.dart';
import '../screens/base/base_screen.dart';
import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import '../validator/input_validator.dart';

class Logs extends StatefulWidget {
  const Logs({Key? key}) : super(key: key);

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  final TextEditingController _fromController = TextEditingController(text: '');
  final TextEditingController _toController = TextEditingController(text: '');
  List<Log> logs = [];
  bool streamOnly = false;
  bool errorOnly = false;
  final TextEditingController containsWord = TextEditingController(text: '');

  bool unhandledException = false;
  Timer? timer;
  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  FloatingActionButton _buildButton() {
    return FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          final exportedFile = await MyLogger.logs.export(
            fileName: DateFormat("dd-MM-yyyy hh:mm:ss aa")
                .format(DateTime.now())
                .toString(),
            filter: (_fromController.text.isNotEmpty &&
                    _toController.text.isEmpty)
                ? LogFilter(
                    logLevels: [LogLevel.ERROR],
                    startDateTime: DateFormat("dd-MM-yyyy hh:mm").parse(
                        DateFormat("dd-MM-yyyy ${_fromController.text}")
                            .format(DateTime.now())),
                  )
                : (_toController.text.isNotEmpty &&
                        _fromController.text.isEmpty)
                    ? LogFilter(
                        endDateTime: DateFormat("dd-MM-yyyy hh:mm").parse(
                            DateFormat("dd-MM-yyyy ${_toController.text}")
                                .format(DateTime.now())),
                      )
                    : (_fromController.text.isNotEmpty &&
                            _toController.text.isNotEmpty)
                        ? LogFilter(
                            startDateTime: DateFormat("dd-MM-yyyy hh:mm").parse(
                                DateFormat("dd-MM-yyyy ${_fromController.text}")
                                    .format(DateTime.now())),
                            endDateTime: DateFormat("dd-MM-yyyy hh:mm").parse(
                                DateFormat("dd-MM-yyyy ${_toController.text}")
                                    .format(DateTime.now())),
                          )
                        : LogFilter.last24Hours(),
          );
          showToast(message: "Saved in ${exportedFile.path}");
        },
        child: const Icon(
          Icons.download_rounded,
          color: Colors.white,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
          automaticallyImplyLeading: false,
          title: Text(
            "Logs",
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
        floatingActionButton: _buildButton(),
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: AppWidgetSize.screenHeight(context),
            width: AppWidgetSize.screenWidth(context),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: AppWidgetSize.dimen_20,
                      horizontal: AppWidgetSize.dimen_40),
                  child: TextFormField(
                    showCursor: false,
                    toolbarOptions: const ToolbarOptions(
                      copy: false,
                      cut: false,
                      paste: false,
                      selectAll: false,
                    ),
                    enableInteractiveSelection: true,
                    autocorrect: false,
                    enabled: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: containsWord,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .labelLarge!
                        .copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: AppWidgetSize.fontSize12),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: 10.w,
                        top: 20.h,
                        bottom: 20.h,
                      ),
                      hintText: "Contains",
                      hintStyle: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(
                              fontSize: AppWidgetSize.fontSize10,
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .color),
                      errorStyle: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(color: Theme.of(context).colorScheme.error),
                      labelText: "Contains Word",
                      labelStyle: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .copyWith(
                              fontSize: AppWidgetSize.fontSize14,
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .labelSmall!
                                  .color),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide:
                            BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    maxLength: 10,
                  ),
                ),
                timeSelectwidget(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Stream only"),
                    Switch(
                      onChanged: (value) {
                        streamOnly = value;
                        setState(() {});
                      },
                      value: streamOnly,
                      activeColor: Theme.of(context).primaryColor,
                      activeTrackColor:
                          Theme.of(context).primaryColor.withOpacity(0.3),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                    const Text("Error only"),
                    Switch(
                      onChanged: (value) {
                        errorOnly = value;
                        setState(() {});
                      },
                      value: errorOnly,
                      activeColor: Theme.of(context).primaryColor,
                      activeTrackColor:
                          Theme.of(context).primaryColor.withOpacity(0.3),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                    const Text("UnHandled Exception"),
                    Switch(
                      onChanged: (value) {
                        unhandledException = value;
                        setState(() {});
                      },
                      value: unhandledException,
                      activeColor: Theme.of(context).primaryColor,
                      activeTrackColor:
                          Theme.of(context).primaryColor.withOpacity(0.3),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ],
                ),
                Expanded(
                  child: StreamBuilder<Object>(
                      stream: getLogData().asStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          logs = snapshot.data as List<Log>;
                          logs = logs.reversed
                              .where((element) =>
                                  (streamOnly
                                      ? element.logLevel == LogLevel.WARNING
                                      : errorOnly
                                          ? element.logLevel == LogLevel.ERROR
                                          : unhandledException
                                              ? element.logLevel ==
                                                  LogLevel.FATAL
                                              : true) &&
                                  (containsWord.text.isNotEmpty
                                      ? (element.text?.toLowerCase().contains(
                                              containsWord.text
                                                  .toLowerCase()) ??
                                          true)
                                      : true))
                              .toList();
                          return streamOnly
                              ? ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  shrinkWrap: true,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                        height: 10,
                                        color: Colors.transparent,
                                      ),
                                  itemCount: logs.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: EdgeInsets.only(
                                          left: AppWidgetSize.dimen_20),
                                      color: Theme.of(context).cardColor,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              logs[index].text?.replaceAll(
                                                      ", ", ",\n") ??
                                                  "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: AppWidgetSize
                                                          .fontSize14))
                                        ],
                                      ),
                                    );
                                  })
                              : ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  shrinkWrap: true,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                    height: 10,
                                    color: Colors.transparent,
                                  ),
                                  itemCount: logs.length,
                                  itemBuilder: (context, index) {
                                    return ExpandablePanel(
                                      theme: const ExpandableThemeData(
                                        headerAlignment:
                                            ExpandablePanelHeaderAlignment
                                                .center,
                                        animationDuration:
                                            Duration(milliseconds: 500),
                                        tapBodyToCollapse: true,
                                        hasIcon: false,
                                      ),
                                      collapsed: const SizedBox(
                                        height: 2,
                                      ),
                                      header: Container(
                                        padding: EdgeInsets.only(
                                            left: 10.w,
                                            right: 8.w,
                                            top: 10.h,
                                            bottom: 10.h),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .cardTheme
                                                .color,
                                            border: Border(
                                                left: BorderSide(
                                                    width: 5,
                                                    color: logs[index]
                                                                .logLevel ==
                                                            LogLevel.ERROR
                                                        ? Colors.red
                                                        : logs[index]
                                                                    .logLevel ==
                                                                LogLevel.FATAL
                                                            ? Colors
                                                                .yellow[700]!
                                                            : Colors.green))),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    logs[index]
                                                            .className
                                                            ?.replaceAll(
                                                                AppConfig
                                                                    .baseUrl
                                                                    .replaceAll(
                                                                        "/init-config",
                                                                        ""),
                                                                "")
                                                            .replaceAll(
                                                                "[31m", "")
                                                            .replaceAll(
                                                                "[0m", "")
                                                            .replaceAll(
                                                                "[32m", "") ??
                                                        "",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall
                                                        ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                AppWidgetSize
                                                                    .fontSize14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(DateFormat(
                                                        "dd-MM-yyyy hh:mm:ss aa")
                                                    .format(DateTime.parse(
                                                        logs[index]
                                                            .timestamp!))),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      expanded: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            11, 5, 11, 5),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black
                                                    .withOpacity(0.2))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: logs[index]
                                                              .text
                                                              .toString()
                                                              .replaceAll(
                                                                  "[31m", "")
                                                              .replaceAll(
                                                                  "[0m", "")
                                                              .replaceAll(
                                                                  "[32m", "")));
                                                  showToast(
                                                    message: "Copied",
                                                    context: context,
                                                  );
                                                },
                                                child: AppImages.copyIcon(
                                                    context)),
                                            Text(
                                              logs[index]
                                                  .text
                                                  .toString()
                                                  .replaceAll("[31m", "")
                                                  .replaceAll("[0m", "")
                                                  .replaceAll("[32m", ""),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall
                                                  ?.copyWith(
                                                      fontSize: AppWidgetSize
                                                          .fontSize14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                        } else {
                          return Container();
                        }
                      }),
                ),
              ],
            ),
          ),
        ));
  }

  Future<List<Log>> getLogData() {
    return (_fromController.text.isNotEmpty && _toController.text.isEmpty)
        ? MyLogger.logs.getByFilter(LogFilter(
            startDateTime: DateFormat("dd-MM-yyyy hh:mm").parse(
                DateFormat("dd-MM-yyyy ${_fromController.text}")
                    .format(DateTime.now())),
          ))
        : (_toController.text.isNotEmpty && _fromController.text.isEmpty)
            ? MyLogger.logs.getByFilter(LogFilter(
                endDateTime: DateFormat("dd-MM-yyyy hh:mm").parse(
                    DateFormat("dd-MM-yyyy ${_toController.text}")
                        .format(DateTime.now())),
              ))
            : (_fromController.text.isNotEmpty && _toController.text.isNotEmpty)
                ? MyLogger.logs.getByFilter(LogFilter(
                    startDateTime: DateFormat("dd-MM-yyyy hh:mm").parse(
                        DateFormat("dd-MM-yyyy ${_fromController.text}")
                            .format(DateTime.now())),
                    endDateTime: DateFormat("dd-MM-yyyy hh:mm").parse(
                        DateFormat("dd-MM-yyyy ${_toController.text}")
                            .format(DateTime.now())),
                  ))
                : MyLogger.logs.getAll();
  }

  Widget timeSelectwidget(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.38,
          child: TextFormField(
            showCursor: false,
            toolbarOptions: const ToolbarOptions(
              copy: false,
              cut: false,
              paste: false,
              selectAll: false,
            ),
            enableInteractiveSelection: true,
            autocorrect: false,
            enabled: true,
            readOnly: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: InputValidator.dob,
            onChanged: (a) {},

            onTap: () async {
              TimeOfDay? time = await timePicler();
              if (time != null) {
                _fromController.text =
                    "${time.hour.toString().length == 1 ? "0" : ""}${time.hour}:${time.minute.toString().length == 1 ? "0" : ""}${time.minute}";
                setState(() {});
              } else {
                _fromController.clear();
              }
            },
            // focusNode: fromFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            controller: _fromController,
            style: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: AppWidgetSize.fontSize12),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                left: 10.w,
                top: 12.h,
                bottom: 12.h,
              ),
              hintText: "HH:MM",
              hintStyle: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(
                      fontSize: AppWidgetSize.fontSize10,
                      color:
                          Theme.of(context).primaryTextTheme.labelSmall!.color),
              errorStyle: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(color: Theme.of(context).colorScheme.error),
              labelText: "From Time",
              labelStyle: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(
                      fontSize: AppWidgetSize.fontSize14,
                      color:
                          Theme.of(context).primaryTextTheme.labelSmall!.color),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              suffixIcon: GestureDetector(
                onTap: () async {
                  TimeOfDay? time = await timePicler();
                  if (time != null) {
                    _fromController.text =
                        "${time.hour.toString().length == 1 ? "0" : ""}${time.hour}:${time.minute.toString().length == 1 ? "0" : ""}${time.minute}";
                    setState(() {});
                  } else {
                    _fromController.clear();
                  }
                },
                child: Padding(
                    padding: EdgeInsets.all(AppWidgetSize.dimen_8),
                    child: Icon(
                      Icons.access_time,
                      color: Theme.of(context).iconTheme.color,
                      size: AppWidgetSize.dimen_20,
                    )),
              ),
            ),
            maxLength: 10,
          ),
        ),
        SizedBox(
          width: AppWidgetSize.dimen_10,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.38,
          child: TextFormField(
            onTap: () async {
              TimeOfDay? time = await timePicler();
              if (time != null) {
                _toController.text =
                    "${time.hour.toString().length == 1 ? "0" : ""}${time.hour}:${time.minute.toString().length == 1 ? "0" : ""}${time.minute}";
                setState(() {});
              }
            },
            showCursor: false,
            readOnly: true,
            toolbarOptions: const ToolbarOptions(
              copy: false,
              cut: false,
              paste: false,
              selectAll: false,
            ),
            enableInteractiveSelection: true,
            autocorrect: false,
            enabled: true,
            onChanged: (e) {
              //validDate.value = isValidDate();
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: InputValidator.dob,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            controller: _toController,
            style: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: AppWidgetSize.fontSize12),
            //   focusNode: toFocus,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                left: 10.w,
                top: 12.h,
                bottom: 12.h,
              ),
              hintText: "HH:MM",
              hintStyle: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(
                      fontSize: AppWidgetSize.fontSize10,
                      color:
                          Theme.of(context).primaryTextTheme.labelSmall!.color),
              errorStyle: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(color: Theme.of(context).colorScheme.error),
              labelText: "To Time",
              labelStyle: Theme.of(context)
                  .primaryTextTheme
                  .labelSmall!
                  .copyWith(
                      fontSize: AppWidgetSize.fontSize14,
                      color:
                          Theme.of(context).primaryTextTheme.labelSmall!.color),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              suffixIcon: GestureDetector(
                onTap: () async {
                  TimeOfDay? time = await timePicler();
                  if (time != null) {
                    _toController.text =
                        "${time.hour.toString().length == 1 ? "0" : ""}${time.hour}:${time.minute.toString().length == 1 ? "0" : ""}${time.minute}";
                    setState(() {});
                  }
                },
                child: Padding(
                    padding: EdgeInsets.all(AppWidgetSize.dimen_8),
                    child: Icon(
                      Icons.access_time,
                      color: Theme.of(context).iconTheme.color,
                      size: AppWidgetSize.dimen_20,
                    )),
              ),
            ),
            maxLength: 10,
          ),
        ),
        if (_fromController.text.isNotEmpty || _toController.text.isNotEmpty)
          InkWell(
            onTap: () {
              _fromController.text = '';
              _toController.text = '';
              setState(() {});
            },
            child: AppImages.crossButton(
              context,
            ),
          )
      ],
    );
  }

  Future<TimeOfDay?> timePicler() async {
    TimeOfDay? pickedTime = await showTimePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  Theme.of(context).primaryColor, // header background color
              onPrimary: Colors.white, // header text color
              background: Colors.white,
              // onSurface: Color(0xFF2C203F), // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor:
                    Theme.of(context).primaryColor, // button text color
              ),
            ),
          ),
          child: child ?? Container(),
        );
      },
      context: context,
      initialTime: TimeOfDay.now(),
    );
    //MaterialLocalizations localizations = MaterialLocalizations.of(context);
    setState(() {});

    //  log(pickedTime.toString());

    return pickedTime;
    // Navigator.pop(context);
  }
}

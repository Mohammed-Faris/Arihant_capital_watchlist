import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../../blocs/bloc/watch_bloc.dart';
import '../../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../../constants/app_constants.dart';
import '../../../../data/store/app_helper.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../../models/watchlist/watchlist_group_model.dart';
import '../../../../models/watchlist/watchlist_symbols_model.dart';

// ignore: must_be_immutable
class WatchTabScreen extends BaseScreen {
  WatchlistGroupModel watchlistGroupModel;
  int selectedTabIndex;
  WatchlistSymbolsModel element;
  WatchTabScreen(
      {super.key,
      required this.element,
      required this.selectedTabIndex,
      required this.watchlistGroupModel});

  @override
  State<WatchTabScreen> createState() => _WatchTabScreenState();
}

class _WatchTabScreenState extends BaseAuthScreenState<WatchTabScreen> {
  late WatchlistBloc watchlistBloc;
  @override
  void initState() {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer,
      AppConstants.streamingHigh,
      AppConstants.high,
      AppConstants.low,
      AppConstants.streamingLow,
    ];
    final streamDetails =
        AppHelper().streamDetails(widget.element.symbols, streamingKeys);

    subscribeLevel1(streamDetails);
    super.initState();
  }

  @override
  String getScreenRoute() {
    return '${widget.watchlistGroupModel.groups![widget.selectedTabIndex].wId}';
  }

  @override
  void dispose() {
    unsubscribeLevel1();
    super.dispose();
  }

  @override
  void quote1responseCallback(ResponseData data) {
    print(data.toJson());
    BlocProvider.of<WatchBloc>(context)
        .add(NewWatchlistStreamingResponseEvent(data, widget.selectedTabIndex));
    super.quote1responseCallback(data);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: widget.element.symbols.length,
        shrinkWrap: true,
        separatorBuilder: (_, index) {
          return const Divider();
        },
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            child: Card(
              color: Colors.white,
              child: ListTile(
                title: Text('${widget.element.symbols[index].dispSym}',
                    style: const TextStyle(color: Colors.black, fontSize: 15)),
                subtitle: Row(
                  children: [
                    Text('${widget.element.symbols[index].sym?.exc}',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 11)),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.element.symbols[index].ltp}',
                          style: ltpstyle(widget.element.symbols[index]),
                        ),
                        arrow(widget.element.symbols[index])
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: changeValue(widget.element.symbols[index]),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

TextStyle ltpstyle(Symbols symbols) {
  if (symbols.chng != null) {
    if (symbols.chng!.contains('-')) {
      return const TextStyle(color: Colors.black, fontSize: 18);
    } else {
      return const TextStyle(color: Colors.black, fontSize: 18);
    }
  } else {
    return const TextStyle(color: Colors.black, fontSize: 18);
  }
}

Icon arrow(Symbols symbols) {
  if (symbols.chng == null) {
    return const Icon(
      Icons.arrow_downward_sharp,
      color: Colors.grey,
      size: 30.0,
    );
  }

  if (symbols.chng!.contains('-')) {
    return const Icon(
      Icons.arrow_drop_down,
      color: Colors.red,
      size: 30.0,
    );
  } else {
    return const Icon(
      Icons.arrow_drop_up,
      color: Colors.green,
      size: 30.0,
    );
  }
}

List<Widget> changeValue(Symbols symbols) {
  if (symbols.chng == null) {
    return [];
  }

  if (symbols.chng!.contains('-')) {
    return [
      Text('${symbols.chng}',
          style: const TextStyle(color: Colors.red, fontSize: 15)),
      const SizedBox(width: 10),
      Text('(${symbols.chngPer}%)',
          style: const TextStyle(color: Colors.red, fontSize: 15))
    ];
  } else {
    return [
      Text('+${symbols.chng}',
          style: const TextStyle(color: Colors.green, fontSize: 15)),
      const SizedBox(width: 10),
      Text('(+${symbols.chngPer}%)',
          style: const TextStyle(color: Colors.green, fontSize: 15))
    ];
  }
}

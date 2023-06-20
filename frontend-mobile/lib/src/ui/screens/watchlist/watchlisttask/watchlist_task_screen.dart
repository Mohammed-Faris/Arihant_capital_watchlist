import 'package:acml/src/models/watchlist/watchlist_group_model.dart';
import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:acml/src/ui/screens/watchlist/watchlisttask/watchtab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/bloc/watch_bloc.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../../models/watchlist/watchlist_symbols_model.dart';

// ignore: must_be_immutable
class WatchlistTaskScreen extends BaseScreen {
  int tabIndex = 0;
  List<Widget> tabs = const [
    Tab(text: ''),
    Tab(text: ''),
    Tab(text: ''),
    Tab(text: ''),
    Tab(text: '')
  ];
  List<Symbols> symbols = [];
  List<WatchlistSymbolsModel> symbolsModelList = [];
  List<Widget> listOfWidgets = [];

  WatchlistTaskScreen({super.key});

  @override
  WatchlistTaskScreenState createState() => WatchlistTaskScreenState();
}

class WatchlistTaskScreenState extends State<WatchlistTaskScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  TextEditingController editingController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  bool isSortedName = false;
  bool isSortedChange = false;
  bool isSortedPrice = false;

  bool isSelectedName = false;
  bool isSelectedChange = false;
  bool isSelectedPrice = false;

  String wName = 'Akas';

  List<Groups>? selectArr;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              RichText(
                text: const TextSpan(
                  text: 'Watchlist',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.green,
                    decorationThickness: 3.0,
                  ),
                ),
              ),
            ],
          ),
          // title: Row(
          //   children: const [
          //     Text(
          //       'Watchlist',
          //       style: TextStyle(
          //           color: Colors.black,
          //           fontSize: 25,
          //           decoration: TextDecoration.underline,
          //           decorationColor: Colors.green,
          //           decorationThickness: 2.0),
          //     ),
          //   ],
          // ),
        ),
        body: BlocBuilder<WatchBloc, WatchState>(
          builder: (context, state) {
            if (state is WatchLoadingState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is WatchLoadedState) {
              isSortedName = state.isSortedName;
              isSortedChange = state.isSortedChange;
              isSortedPrice = state.isSortedPrice;

              isSelectedName = state.isSelectedName;
              isSelectedChange = state.isSelectedChange;
              isSelectedPrice = state.isSelectedPrice;
              print(
                  "symbolslist ${state.symbolsModelList[0].symbols.map((e) => e.dispSym).toList()..sort(
                      (a, b) => a!.compareTo(b!),
                    )}");
              widget.tabs = generateTabs(state.watchlistGroupModel!);
              selectArr = state.watchlistGroupModel?.groups;
              widget.symbolsModelList = state.symbolsModelList;
              widget.listOfWidgets = symbolBody(
                  state.symbolsModelList, state.watchlistGroupModel!);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.grey.withOpacity(0.5),
                    //     spreadRadius: 2,
                    //     blurRadius: 5,
                    //     offset: const Offset(
                    //         0, 3), // changes the position of the shadow
                    //   ),
                    // ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(10),
                    child: TextField(
                      style: const TextStyle(fontSize: 20),
                      onChanged: (newText) {
                        context.read<WatchBloc>().add(SearchEvent(
                            searchText: newText,
                            selectedTabIndex: widget.tabIndex));
                        //   BlocProvider.of<WatchBloc>(context).add(SearchEvent(searchText: newText));
                        print('newText: $newText');
                        print("searchController: ${searchController.text}");
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 30,
                        ),
                        hintText: 'Search for companies to invest or trade',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 60,
                  color: Colors.grey.shade300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TabBar(
                          isScrollable: false,
                          onTap: (index) {
                            widget.tabIndex = index;
                            setState(() {
                              wName = selectArr![index].wName!;
                            });
                          },
                          padding: const EdgeInsets.only(
                              left: 10, right: 150, top: 15, bottom: 10),

                          tabs: widget.tabs,
                          labelPadding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          labelStyle: const TextStyle(fontSize: 16),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black,
                          automaticIndicatorColorAdjustment: true,

                          // unselectedLabelStyle: const TextStyle(
                          //   backgroundColor: Colors.red,
                          // ),
                          indicator: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorPadding:
                              const EdgeInsets.symmetric(horizontal: 0),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 10,
                    ),
                    color: Colors.grey.shade300,
                    child: Stack(
                      children: [
                        TabBarView(children: widget.listOfWidgets),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            margin:
                                const EdgeInsets.only(bottom: 50, right: 50),
                            padding: const EdgeInsets.only(left: 0),
                            height: 35,
                            //width: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        context
                                            .read<WatchBloc>()
                                            .add(OnSortEvent(
                                              isSortedName: isSortedName,
                                              isSelectedName: isSelectedName,
                                              isSelectedChange:
                                                  isSelectedChange,
                                              isSelectedPrice: isSelectedPrice,
                                              isSortedChange: isSortedChange,
                                              isSortedPrice: isSortedPrice,
                                              selectedTabIndex: widget.tabIndex,
                                              selectedSort: isSortedName
                                                  ? 'Z to A'
                                                  : 'A to Z',
                                            ));
                                      },
                                      child: Text(
                                        'Name',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: isSelectedName
                                                ? Colors.green
                                                : Colors.grey),
                                      ),
                                    ),
                                    isSortedName
                                        ? const Icon(
                                            Icons.arrow_drop_up,
                                            color: Colors.green,
                                          )
                                        : const Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.green,
                                          )
                                  ],
                                ),
                                const VerticalDivider(
                                  width: 5,
                                ),
                                Row(mainAxisSize: MainAxisSize.min, children: [
                                  TextButton(
                                    onPressed: () {
                                      context.read<WatchBloc>().add(OnSortEvent(
                                            isSortedName: isSortedName,
                                            isSortedChange: isSortedChange,
                                            isSortedPrice: isSortedPrice,
                                            isSelectedName: isSelectedName,
                                            isSelectedChange: isSelectedChange,
                                            isSelectedPrice: isSelectedPrice,
                                            selectedTabIndex: widget.tabIndex,
                                            selectedSort: isSortedChange
                                                ? 'High to Low'
                                                : 'Low to High',
                                          ));
                                    },
                                    child: Text(
                                      '% Change',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: isSelectedChange
                                              ? Colors.green
                                              : Colors.grey),
                                    ),
                                  ),
                                  isSortedChange
                                      ? const Icon(
                                          Icons.arrow_drop_up,
                                          color: Colors.green,
                                        )
                                      : const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.green,
                                        )
                                ]),
                                const VerticalDivider(
                                  width: 5,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        print('price pressed${state.hashCode}');
                                        context
                                            .read<WatchBloc>()
                                            .add(OnSortEvent(
                                              isSortedName: isSortedName,
                                              isSortedChange: isSortedChange,
                                              isSortedPrice: isSortedPrice,
                                              isSelectedName: isSelectedName,
                                              isSelectedChange:
                                                  isSelectedChange,
                                              isSelectedPrice: isSelectedPrice,
                                              selectedTabIndex: widget.tabIndex,
                                              selectedSort: isSortedPrice
                                                  ? 'Price High to Low'
                                                  : 'Price Low to High',
                                            ));
                                      },
                                      child: Text(
                                        'Price',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: isSelectedPrice
                                                ? Colors.green
                                                : Colors.grey),
                                      ),
                                    ),
                                    isSortedPrice
                                        ? const Icon(
                                            Icons.arrow_drop_up,
                                            color: Colors.green,
                                          )
                                        : const Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.green,
                                          )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Tab> generateTabs(WatchlistGroupModel model) {
    List<Tab> tabsList = [];

    for (var element in model.groups!) {
      tabsList.add(Tab(
        // text: '${element.wName}',
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            color: element.wName == wName ? null : Colors.grey.shade200,
          ),
          child: Center(child: Text('${element.wName}')),
        ),
      ));
    }

    return tabsList;
  }

  List<Widget> symbolBody(List<WatchlistSymbolsModel> symbolsModelList,
      WatchlistGroupModel groupModel) {
    return symbolsModelList.map((e) {
      return WatchTabScreen(
        element: e,
        selectedTabIndex: widget.tabIndex,
        watchlistGroupModel: groupModel,
      );
    }).toList();
  }
}

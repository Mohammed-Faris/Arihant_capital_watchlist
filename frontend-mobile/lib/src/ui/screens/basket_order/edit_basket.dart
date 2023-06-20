import 'package:acml/src/blocs/basket_order/basket_bloc.dart';
import 'package:acml/src/ui/navigation/screen_routes.dart';
import 'package:acml/src/ui/screens/basket_order/widgets/basket_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../../blocs/basket_order/basket_state.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/orders/order_book.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../validator/input_validator.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/error_image_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/loader_widget.dart';
import '../base/base_screen.dart';
import '../watchlist/widget/alert_bottomsheet_widget.dart';

class EditBasketScreen extends BaseScreen {
  final dynamic arguments;
  const EditBasketScreen({Key? key, this.arguments}) : super(key: key);

  @override
  EditBasketScreenState createState() => EditBasketScreenState();
}

class EditBasketScreenState extends BaseAuthScreenState<EditBasketScreen> {
  late BasketBloc basketBloc;
  late AppLocalizations _appLocalizations;
  late FocusNode renameTxtFieldFocusNode;
  final TextEditingController _renameBasketController = TextEditingController(
    text: '',
  );
  bool renameEnabled = false;

  @override
  void initState() {
    basketBloc = BlocProvider.of(context)..stream.listen(renameBasketListener);
    basketBloc.add(FetchBasketEvent());
    basketBloc.add(FetchBasketOrdersEvent(widget.arguments["basketId"]));
    _renameBasketController.text = widget.arguments["basketName"];

    renameTxtFieldFocusNode = FocusNode();
    super.initState();
  }

  @override
  void quote1responseCallback(ResponseData data) {
    basketBloc.add(BasketStreamingResponseEvent(data));
  }

  Future<void> renameBasketListener(BasketState state) async {
    if (state is FetchBasketOrdersStreamState) {
      subscribeLevel1(state.streamDetails);
    }
    if (state is RenameBasketDone) {
      setState(() {
        renameEnabled = false;
      });
    }
    if (state is DeleteBasketDone) {
      popAndRemoveUntilNavigation(ScreenRoutes.myBasket);
    }
    if (state is DeleteBasketOrdersDone) {
      basketBloc.add(FetchBasketOrdersEvent(widget.arguments["basketId"]));
    }
    if (state is RearrangeBasketOrderDone) {
      basketBloc.add(FetchBasketOrdersEvent(widget.arguments["basketId"]));
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBarWidget(),
      body: SafeArea(child: _buildBody()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 5.w),
            child: gradientButtonWidget(
              onTap: () {
                showAlertBottomSheetWithTwoButtons(
                    context: context,
                    title: _appLocalizations.deleteBasket,
                    description: _appLocalizations.deleteBasketDesc,
                    leftButtonTitle: _appLocalizations.no,
                    rightButtonTitle: _appLocalizations.deleteYes,
                    rightButtonCallback: () {
                      basketBloc
                          .add(DeleteBasketEvent(widget.arguments["basketId"]));
                    },
                    button1Error: true,
                    button2Error: true);
              },
              width: AppWidgetSize.fullWidth(context) / 2.5,
              key: const Key("deletbasketbuttonKey"),
              context: context,
              title: _appLocalizations.deleteBasket,
              isGradient: false,
              isErrorButton: true,
              bottom: 20,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBarWidget() {
    return AppBar(
      centerTitle: false,
      elevation: 0.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              backIconButton(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  customColor:
                      Theme.of(context).textTheme.displayMedium!.color),
              Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: CustomTextWidget(
                  _appLocalizations.editBasket,
                  Theme.of(context)
                      .primaryTextTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 24),
                ),
              ),
            ],
          ),
          if (renameEnabled)
            GestureDetector(
              onTap: () {
                renameTxtFieldFocusNode.unfocus();
                if (isBasketexist()) {
                  showToast(
                    context: context,
                    isError: true,
                    message: AppLocalizations().basketNameExistError,
                  );
                } else {
                  showAlertBottomSheetWithTwoButtons(
                      context: context,
                      title: _appLocalizations.editBasket,
                      description: _appLocalizations.editBasketDesc,
                      leftButtonTitle: _appLocalizations.no,
                      rightButtonTitle: _appLocalizations.yesSave,
                      rightButtonCallback: () {
                        basketBloc.add(RenameBasketEvent(
                            widget.arguments["basketId"],
                            _renameBasketController.text));
                      },
                      button1Error: false);
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                  right: 20.w,
                ),
                child: CustomTextWidget(
                  _appLocalizations.done,
                  Theme.of(context).primaryTextTheme.headlineMedium,
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.only(
        top: 30.w,
        left: 15.w,
        right: AppWidgetSize.dimen_15,
      ),
      child: _buildContentWidget(),
    );
  }

  Widget _buildContentWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _buildRenameWatchlistWidget(),
        ),
        BlocBuilder<BasketBloc, BasketState>(
          buildWhen: (BasketState previous, BasketState current) {
            return current is FetchBasketOrdersDone ||
                current is FetchBasketOrderLoading ||
                current is DeleteBasketOrdersLoading ||
                current is RearrangeBasketOrderLoading;
          },
          builder: (context, state) {
            if (state is FetchBasketOrderLoading ||
                state is RearrangeBasketOrderLoading ||
                state is DeleteBasketOrdersLoading) {
              return const Expanded(child: LoaderWidget());
            }
            if (state is FetchBasketOrdersDone) {
              return (state.basketOrders.orders?.isEmpty ?? true)
                  ? Expanded(
                      child: errorWithImageWidget(
                        context: context,
                        imageWidget:
                            AppUtils().getNoDateImageErrorWidget(context),
                        errorMessage:
                            _appLocalizations.noDataAvailableErrorMessage,
                        padding: EdgeInsets.only(
                          left: AppWidgetSize.dimen_30,
                          right: AppWidgetSize.dimen_30,
                          bottom: AppWidgetSize.dimen_30,
                        ),
                      ),
                    )
                  : _buildSymbolsSection(state.basketOrders.orders ?? []);
            } else if (state is BasketError) {
              return Expanded(
                child: errorWithImageWidget(
                  context: context,
                  imageWidget: AppUtils().getNoDateImageErrorWidget(context),
                  errorMessage: _appLocalizations.noDataAvailableErrorMessage,
                  padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_30,
                    right: AppWidgetSize.dimen_30,
                    bottom: AppWidgetSize.dimen_30,
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        )
      ],
    );
  }

  bool scrollListEnable = true;

  Widget _buildSymbolsSection(List<Orders> orders) {
    return Expanded(
      child: ReorderableListView(
          scrollDirection: Axis.vertical,
          physics: scrollListEnable
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
          onReorder: (int oldIndex, int newIndex) {
            final bool isPositionChanged =
                (oldIndex < newIndex && oldIndex != (newIndex - 1)) ||
                    (oldIndex > newIndex && oldIndex != newIndex);
            if (orders.length > 1 && isPositionChanged) {
              basketBloc.add(RearrangeBasketOrderEvent(
                  ([
                    {
                      "basketOrderId": orders[oldIndex].basketOrderId,
                      "pos": oldIndex < newIndex ? newIndex : newIndex + 1
                    },
                    {
                      "basketOrderId":
                          orders[newIndex - (oldIndex < newIndex ? 1 : 0)]
                              .basketOrderId,
                      "pos": oldIndex + 1
                    }
                  ]),
                  widget.arguments["basketId"],
                  oldIndex,
                  newIndex));
            }
          },
          children: List<Widget>.generate(
            orders.length,
            (int index) {
              final Orders order = orders[index];
              return _buildSymbolsRow(order, index);
            },
          )),
    );
  }

  Widget _buildRenameWatchlistWidget() {
    return PhysicalModel(
      borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: AppWidgetSize.dimen_5,
      shadowColor: Theme.of(context).inputDecorationTheme.fillColor!,
      child: TextField(
        enableSuggestions: false,
        key: const Key("basketRenameTextFieldKey"),
        enableInteractiveSelection: true,
        autocorrect: false,
        autofocus: renameEnabled,
        textCapitalization: TextCapitalization.sentences,
        focusNode: renameTxtFieldFocusNode,
        readOnly: false,
        onTap: () {
          setState(() {
            renameEnabled = true;
          });
          FocusScope.of(context).requestFocus(renameTxtFieldFocusNode);
        },
        onChanged: (String text) {
          setState(() {});
        },
        style: Theme.of(context)
            .primaryTextTheme
            .labelLarge!
            .copyWith(decoration: TextDecoration.none),
        inputFormatters: InputValidator.watchlistName,
        controller: _renameBasketController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
            left: 15.w,
            top: 12.w,
            bottom: 12.w,
            right: 10.w,
          ),
          suffix: _renameBasketController.text.isNotEmpty
              ? InkWell(
                  onTap: () {
                    _renameBasketController.clear();
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: 10.w,
                    ),
                    padding: EdgeInsets.only(top: AppWidgetSize.dimen_5),
                    height: 20.w,
                    width: 20.w,
                    alignment: Alignment.centerRight,
                    child: AppImages.closeIcon(context,
                        color: Theme.of(context).iconTheme.color,
                        isColor: true),
                  ),
                )
              : SizedBox(
                  width: AppWidgetSize.dimen_15,
                  height: AppWidgetSize.dimen_15,
                ),
          labelStyle: Theme.of(context).primaryTextTheme.labelSmall,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        maxLength: 15,
      ),
    );
  }

  Widget _buildSymbolsRow(Orders orders, int index) {
    return Container(
      padding: EdgeInsets.only(bottom: 3.w, top: 5.w),
      key: Key("basketEditReorderRowKey$index"),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: ListTile(
        minLeadingWidth: 15.w,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Listener(
              onPointerHover: (d) {
                if (scrollListEnable) {
                  setState(() {
                    scrollListEnable = false;
                  });
                }
              },
              child: ReorderableDragStartListener(
                index: index,
                enabled: true,
                child: Container(
                  padding: EdgeInsets.only(bottom: 15.w),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  //  height: AppWidgetSize.dimen_70,
                  width: 23.w,

                  child: AppImages.dragIcon(
                    context,
                    width: 30.w,
                    height: 30.w,
                    color:
                        Theme.of(context).primaryTextTheme.titleMedium!.color,
                  ),
                ),
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.all(0),
        title: Listener(
            onPointerHover: (details) {
              setState(() {
                scrollListEnable = true;
              });
            },
            child: BasketRowWidget(
              orders: orders,
              onRowClick: (Orders selected) {},
              isBottomSheet: false,
              showOrdertype: false,
              iseditBasket: true,
            )),
        trailing: buildDeleteIcon(
          index,
          orders,
        ),
        onTap: () {/* Do something else */},
      ),
    );
  }

  buildDeleteIcon(int index, Orders symbolItem) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(right: AppWidgetSize.dimen_15, bottom: 15.w),
          child: GestureDetector(
            onTap: () {
              showAlertBottomSheetWithTwoButtons(
                  context: context,
                  title: _appLocalizations.deleteBasketorder,
                  description: _appLocalizations.deleteBasketorderDesc,
                  leftButtonTitle: _appLocalizations.no,
                  rightButtonTitle: _appLocalizations.deleteYes,
                  rightButtonCallback: () {
                    if (symbolItem.basketOrderId != null) {
                      basketBloc.add(DeleteBasketOrderEvent(
                          symbolItem.basketOrderId ?? ""));
                    }
                  },
                  
                  button1Error: true,
                  button2Error: true);
            },
            child: AppImages.deleteIcon(
              context,
              color: AppColors.negativeColor,
              width: 25.w,
              height: 25.w,
            ),
          ),
        ),
      ],
    );
  }

  bool isBasketexist() {
    for (var data in basketBloc.fetchBasketDone.basketModel.baskets) {
      if (data.basketName.toLowerCase() ==
          _renameBasketController.text.trim().toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.editBasket;
  }
}

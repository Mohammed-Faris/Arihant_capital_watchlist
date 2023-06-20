import 'package:acml/src/blocs/basket_order/basket_bloc.dart';
import 'package:acml/src/blocs/basket_order/basket_state.dart';
import 'package:acml/src/models/basket_order/basket_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../navigation/screen_routes.dart';
import '../../styles/app_color.dart';
import '../../styles/app_images.dart';
import '../../styles/app_widget_size.dart';
import '../../validator/input_validator.dart';
import '../../widgets/build_empty_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/gradient_button_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../widgets/refresh_widget.dart';
import '../base/base_screen.dart';

class MyBasket extends BaseScreen {
  const MyBasket({super.key});

  @override
  State<MyBasket> createState() => _MyBasketState();
}

class _MyBasketState extends BaseAuthScreenState<MyBasket> {
  late BasketBloc basketBloc;
  int itemCount = 3;
  final TextEditingController _searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  bool isSearchSelected = false;
  List<Baskets> basketList = [];
  @override
  void initState() {
    basketBloc = BlocProvider.of(context)..stream.listen(basketListener);
    basketBloc.add(FetchBasketEvent());
    super.initState();
  }

  Future<void> basketListener(BasketState state) async {
    if (state is CreateBasketDone) {
      basketBloc.add(FetchBasketEvent());
    } else if (state is DeleteBasketDone) {
      basketBloc.add(FetchBasketEvent());
    }
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            gradientButtonWidget(
              onTap: () {
                showCreateNewBottomSheet();
              },
              width: AppWidgetSize.fullWidth(context) / 2.1,
              key: const Key("createBasket"),
              context: context,
              icon: Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: AppImages.createBasketIcon(context, width: 24.w),
              ),
              title: AppLocalizations().createNew,
              isGradient: true,
            ),
          ],
        ),
        body: BlocBuilder<BasketBloc, BasketState>(
          bloc: basketBloc,
          buildWhen: (BasketState previous, BasketState current) {
            return current is FetchBasketLoading ||
                current is BasketError ||
                current is FetchBasketDone;
          },
          builder: (context, state) {
            if (state is FetchBasketLoading) return const LoaderWidget();
            if (state is FetchBasketDone) {
              basketList = state.basketModel.baskets;
              return state.basketModel.baskets.isNotEmpty
                  ? RefreshWidget(
                      onRefresh: () {
                        basketBloc.add(FetchBasketEvent());
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        itemCount: state.basketModel.baskets.length,
                        itemBuilder: (context, index) {
                          return _buildbasketRow(
                              context, state.basketModel.baskets[index], index);
                        },
                      ),
                    )
                  : _buildEmptyBasketWidget();
            } else {
              return _buildEmptyBasketWidget();
            }
          },
        )); // :
  }

  _buildbasketRow(BuildContext context, Baskets basketData, int index) {
    return Dismissible(
      key: Key("basketRowKey+$index"),
      background: buildBackGroundTextContainer(
        AppLocalizations().edit,
        AppUtils().isLightTheme()
            ? AppColors.primaryColor
            : AppColors().positiveColor,
        Alignment.centerLeft,
      ),
      secondaryBackground: buildBackGroundTextContainer(
        AppLocalizations().delete,
        AppColors.negativeColor,
        Alignment.centerRight,
      ),
      direction: DismissDirection.horizontal,
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          pushNavigation(ScreenRoutes.editBasket, arguments: {
            "basketId": basketData.basketId,
            "basketName": basketData.basketName
          });

          basketBloc.add(FetchBasketOrdersEvent(basketData.basketId));
          return false;
        } else if (direction == DismissDirection.endToStart) {
          basketBloc.add(DeleteBasketEvent(basketData.basketId));

          return false;
        }

        return false;
      },
      child: Card(
        elevation: 0,
        color: Theme.of(context).scaffoldBackgroundColor,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppWidgetSize.dimen_10)),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 10.w,
          ),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 0.5)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 10.w,
              bottom: 10.w,
            ),
            child: Column(
              children: [
                ListTile(
                  onTap: () async {
                    await pushNavigation(ScreenRoutes.addBasket,
                        arguments: basketData);
                    basketBloc.add(FetchBasketEvent());
                  },
                  minLeadingWidth: 25.w,
                  leading: AppImages.basketIcon(context, height: 25.w),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).textTheme.displayLarge!.color,
                    size: 15,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: basketData.basketName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(fontWeight: FontWeight.w500),
                          children: [
                            TextSpan(
                                text: " (${basketData.ordCount})",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        fontSize: AppWidgetSize.fontSize12)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 7.h),
                        child: CustomTextWidget(
                          basketData.basktCrtdAt,
                          Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Padding _buildSeperatorWidget() {
  //   return Padding(
  //     padding: EdgeInsets.only(
  //       top: AppWidgetSize.dimen_8,
  //       bottom: AppWidgetSize.dimen_8,
  //       left: AppWidgetSize.dimen_20,
  //     ),
  //     child: Container(
  //         height: AppWidgetSize.dimen_1, color: Theme.of(context).dividerColor),
  //   );
  // }

  topBar(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: backIconButton(),
            ),
            if (!isSearchSelected)
              Padding(
                padding: EdgeInsets.only(left: AppWidgetSize.dimen_25),
                child: CustomTextWidget(
                  AppLocalizations().myBasket,
                  Theme.of(context).textTheme.headlineMedium,
                ),
              ),
          ],
        ),
        BlocBuilder<BasketBloc, BasketState>(
          builder: (context, state) {
            return isSearchSelected
                ? _buildSearchTextBox()
                : _buildSearch(context);
          },
        )
      ],
    );
  }

  Widget _buildSearch(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isSearchSelected = true;
        setState(() {});
        searchFocusNode.requestFocus();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: AppWidgetSize.dimen_15,
        ),
        child: AppImages.search(
          context,
          color: Theme.of(context).primaryIconTheme.color,
          isColor: true,
          width: AppWidgetSize.dimen_25,
          height: AppWidgetSize.dimen_25,
        ),
      ),
    );
  }

  Widget _buildSearchTextBox() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_3,
      ),
      child: Container(
        width: AppWidgetSize.screenWidth(context) * 0.8,
        height: AppWidgetSize.dimen_45,
        alignment: Alignment.centerLeft,
        child: Stack(
          children: [
            TextField(
              cursorColor: Theme.of(context).iconTheme.color,
              enableInteractiveSelection: true,
              autocorrect: false,
              enabled: true,
              controller: _searchController,
              textCapitalization: TextCapitalization.characters,
              onChanged: (String text) {
                basketBloc.add(FilterBasketEvent(text));
              },
              focusNode: searchFocusNode,
              textInputAction: TextInputAction.done,
              inputFormatters: InputValidator.searchSymbol,
              style: Theme.of(context)
                  .primaryTextTheme
                  .labelLarge!
                  .copyWith(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  top: AppWidgetSize.dimen_10,
                  bottom: AppWidgetSize.dimen_7,
                  right: AppWidgetSize.dimen_10,
                ),
                hintText: AppLocalizations().basketsearchhint,
                hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color:
                        Theme.of(context).dialogBackgroundColor.withAlpha(-1)),
                counterText: '',
              ),
              maxLength: 25,
            ),
            Positioned(
              right: 0,
              top: AppWidgetSize.dimen_12,
              child: GestureDetector(
                onTap: () {
                  _searchController.clear();

                  setState(() {
                    isSearchSelected = false;
                  });
                  basketBloc.add(FilterBasketEvent(''));
                },
                child: Center(
                  child: AppImages.deleteIcon(
                    context,
                    width: AppWidgetSize.dimen_25,
                    height: AppWidgetSize.dimen_25,
                    color: Theme.of(context).primaryIconTheme.color,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBasketWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: buildEmptyWidget(
            context: context,
            emptyImage: AppImages.noBasketOrders(context, height: 200),
            description1: "Empty Basket",
            description2: "Your Basket is empty,Lets Create your first basket.",
            buttonInRow: false,
            showbutton: false,
            button1Title: "",
            button2Title: "",
            onButton1Tapped: () {},
          ),
        ),
      ],
    );
  }

  final TextEditingController createBasketcontroller = TextEditingController();
  FocusNode newBasketFocusNode = FocusNode();
  showCreateNewBottomSheet() async {
    createBasketcontroller.clear();
    await showInfoBottomsheet(StatefulBuilder(
        builder: (BuildContext context, StateSetter updateState) {
      return Container(
        child: _buildCreateWatchlistContent(context, updateState),
      );
    }));
  }

  Widget _buildCreateWatchlistContent(
      BuildContext context, StateSetter updateState) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: AppWidgetSize.dimen_15,
              bottom: 20.w,
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: AppImages.backButtonIcon(context,
                        color: Theme.of(context).primaryIconTheme.color),
                  ),
                ),
                Text(
                  AppLocalizations().createBasket,
                  // style: Theme.of(context).textTheme.headline2,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 24),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.w,
              bottom: AppWidgetSize.dimen_15,
            ),
            child: TextField(
              style: Theme.of(context).primaryTextTheme.labelLarge,
              onChanged: (String text) {
                updateState(() {});
              },
              autofocus: true,
              focusNode: newBasketFocusNode,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: InputValidator.watchlistName,
              controller: createBasketcontroller,
              maxLength: 15,
              cursorColor: Theme.of(context).primaryIconTheme.color,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 15.w,
                  top: 12.w,
                  bottom: 12.w,
                  right: 10.w,
                ),
                counterText:
                    '${15 - (createBasketcontroller.text.length.toInt())} ${AppLocalizations().charactersRemaining}',
                counterStyle: Theme.of(context)
                    .primaryTextTheme
                    .bodySmall!
                    .copyWith(
                      color: createBasketcontroller.text.length.toInt() == 15
                          ? AppColors.negativeColor
                          : Theme.of(context)
                              .inputDecorationTheme
                              .labelStyle!
                              .color,
                    ),
                labelText: AppLocalizations().createBasketDescription,
                labelStyle: Theme.of(context).primaryTextTheme.labelSmall,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.w),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).dividerColor, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).dividerColor, width: 1),
                ),
              ),
            ),
          ),
          createBasketcontroller.text.length.toInt() > 0
              ? Center(
                  child: Padding(
                      padding: EdgeInsets.only(
                        top: 5.w,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: gradientButtonWidget(
                          onTap: () {
                            if (isBasketexist()) {
                              Navigator.of(context).pop();
                              showToast(
                                context: context,
                                isError: true,
                                message:
                                    AppLocalizations().basketNameExistError,
                              );
                            } else {
                              popNavigation();
                              basketBloc.add(CreateBasketEvent(
                                  createBasketcontroller.text));
                            }

                            /*   popNavigation();
                            pushNavigation(ScreenRoutes.addBasket); */
                          },
                          width: AppWidgetSize.fullWidth(context) / 1.5,
                          key: const Key("createBasket"),
                          context: context,
                          title: AppLocalizations().createNew,
                          isGradient: true)),
                )
              : Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: MediaQuery.of(context).viewInsets.bottom + 100,
                ),
        ],
      ),
    );
  }

  Widget buildBackGroundTextContainer(
    String title,
    Color color,
    Alignment alignment,
  ) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.all(AppWidgetSize.dimen_14),
      color: color,
      child: Text(
        title,
        style: Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }

  bool isBasketexist() {
    for (var data in basketList) {
      if (data.basketName.toLowerCase() ==
          createBasketcontroller.text.trim().toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  @override
  String getScreenRoute() {
    return ScreenRoutes.myBasket;
  }
}

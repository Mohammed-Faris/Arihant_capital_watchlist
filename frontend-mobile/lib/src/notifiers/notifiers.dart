import 'package:flutter/material.dart';

class SelectFilterNotifier extends ValueNotifier<int> {
  SelectFilterNotifier(int value) : super(value);

  void changeFilterPosition(int item) {
    value = item;
    notifyListeners();
  }
}

class SearchNotifier extends ValueNotifier<bool> {
  SearchNotifier(bool value) : super(value);

  void changeSearchBar(bool item) {
    value = item;
    notifyListeners();
  }
}

class EnlargeModalSheet extends ValueNotifier<bool> {
  EnlargeModalSheet(bool value) : super(value);

  void enLargeModal(bool item) {
    value = item;
    notifyListeners();
  }
}

class PnlCurrentChange extends ValueNotifier<bool> {
  PnlCurrentChange(bool value) : super(value);

  void pnlCurrentUpdate(bool item) {
    value = item;
    notifyListeners();
  }
}

class CheckBoxChange extends ValueNotifier<bool> {
  CheckBoxChange(bool value) : super(value);

  void updateCheckBox(bool item) {
    value = item;
    notifyListeners();
  }
}

class ExpandingRevenue extends ValueNotifier<bool> {
  ExpandingRevenue(bool value) : super(value);

  void updateExpandingRevenue(bool item) {
    value = item;
    notifyListeners();
  }
}

class ExpandingExpenses extends ValueNotifier<bool> {
  ExpandingExpenses(bool value) : super(value);

  void updateExpandingExpenses(bool item) {
    value = item;
    notifyListeners();
  }
}

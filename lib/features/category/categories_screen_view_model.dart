import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';

class CategoriesScreenViewModel with ChangeNotifier {
  List<Category> categories = [];

  CategoriesScreenViewModel() {
    loadCategories();
  }

  loadCategories() async {
    if (selectedVault != null) {
      categories = await CategoryService.getAllByVault(selectedVault!.id);
      notifyListeners();
    }
  }
}

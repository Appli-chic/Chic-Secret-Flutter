import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';

class SelectCategoryScreenViewModel with ChangeNotifier {
  late bool isShowingTrash;

  List<Category> categories = [];
  Category? category;

  SelectCategoryScreenViewModel(bool isShowingTrash, Category? category) {
    this.isShowingTrash = isShowingTrash;
    this.category = category;
    loadCategories();
  }

  loadCategories() async {
    if (selectedVault != null) {
      if (isShowingTrash) {
        categories = await CategoryService.getAllByVault(selectedVault!.id);
      } else {
        categories =
        await CategoryService.getAllByVaultWithoutTrash(selectedVault!.id);
      }

      notifyListeners();
    }
  }

  onCategorySelected(Category? category) {
    this.category = category;
    notifyListeners();
  }
}

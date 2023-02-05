import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';

class EntryCategoryScreenViewModel with ChangeNotifier {
  List<Entry> entries = [];
  late Category category;

  EntryCategoryScreenViewModel(Category category) {
    this.category = category;
    loadPassword();
  }

  loadPassword() async {
    if (selectedVault != null) {
      entries = await EntryService.getAllByVault(selectedVault!.id,
          categoryId: category.id);
      notifyListeners();
    }
  }

  onEditCategory(Category category) async {
    this.category = category;
    await loadPassword();
  }

  onDeletingCategory() async {
    await EntryService.moveToTrashAllEntriesFromCategory(category);
    await CategoryService.delete(category);
  }
}

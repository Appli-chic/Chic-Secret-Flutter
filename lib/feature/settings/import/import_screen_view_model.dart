import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/utils/import_export.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ImportScreenViewModel with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  List<Category> newCategories = [];
  var dataIndex = 0;
  late ImportData importData;
  Category? category;

  var categoryController = TextEditingController();
  var newCategoryController = TextEditingController();

  ImportScreenViewModel(ImportData importData) {
    this.importData = importData;
    categoryController =
        TextEditingController(text: importData.categoriesName[dataIndex]);
    _loadFirstCategory();
  }

  _loadFirstCategory() async {
    category = await CategoryService.getFirstByVault(selectedVault!.id);

    if (category != null) {
      newCategoryController.text = category!.name;
      notifyListeners();
    }
  }

  onCategorySelected(Category category) {
    newCategoryController.text = category.name;
    this.category = category;
    notifyListeners();
  }

  onCategoryCreated(Category category) {
    newCategoryController.text = category.name;
    this.category = category;
    notifyListeners();
  }

  onNext() {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      dataIndex++;
      newCategories.add(category!);
      categoryController =
          TextEditingController(text: importData.categoriesName[dataIndex]);

      notifyListeners();
    }
  }

  onDone() async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      EasyLoading.show();

      newCategories.add(category!);

      _addEntries();
      _addCustomFields();

      EasyLoading.dismiss();
    }
  }

  _addEntries() async {
    List<Future> entryFutures = [];

    for (var entry in importData.entries) {
      if (entry.hash.isNotEmpty) {
        entry.hash = Security.encrypt(currentPassword!, entry.hash);
        entry.createdAt = DateTime.now();
        entry.updatedAt = DateTime.now();

        entry.categoryId =
            newCategories[importData.categoriesName.indexOf(entry.categoryId)]
                .id;

        entryFutures.add(EntryService.save(entry));
      }
    }

    await Future.wait(entryFutures);
  }

  _addCustomFields() async {
    List<Future> customFieldsFutures = [];

    for (var customField in importData.customFields) {
      customField.createdAt = DateTime.now();
      customField.updatedAt = DateTime.now();
      customFieldsFutures.add(CustomFieldService.save(customField));
    }

    await Future.wait(customFieldsFutures);
  }
}

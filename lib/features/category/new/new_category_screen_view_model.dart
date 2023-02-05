import 'package:chic_secret/component/color_selector.dart';
import 'package:chic_secret/component/icon_selector.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/utils/color.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/icon_converter.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class NewCategoryScreenViewModel with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  ColorSelectorController colorSelectorController = ColorSelectorController();
  IconSelectorController iconSelectorController = IconSelectorController();

  Category? categoryToUpdate = null;
  Category? preselectedCategory = null;
  Color color = Colors.blue;
  IconData icon = getIcons()[0];

  NewCategoryScreenViewModel(Category? category, String? hint) {
    this.categoryToUpdate = category;

    if (category != null) {
      nameController = TextEditingController(text: category.name);
      color = getColorFromHex(category.color);
      icon = IconConverter.convertMaterialIconToCupertino(
        IconData(category.icon, fontFamily: 'MaterialIcons'),
      );
    }

    if (hint != null) {
      nameController = TextEditingController(text: hint);
    }
  }

  onUpdateColor(Color color) {
    this.color = color;
    notifyListeners();
  }

  onUpdateIcon(IconData icon) {
    this.icon = icon;
    notifyListeners();
  }

  onPredefinedCategorySelected(Category category) {
    preselectedCategory = category;
    nameController.text = category.name;
    color = getColorFromHex(category.color);
    icon = IconConverter.convertMaterialIconToCupertino(
      IconData(category.icon, fontFamily: 'MaterialIcons'),
    );

    if (colorSelectorController.onColorChange != null) {
      colorSelectorController.onColorChange!(color);
    }

    if (iconSelectorController.onIconChange != null) {
      iconSelectorController.onIconChange!(icon);
    }

    notifyListeners();
  }

  onSavingCategory(
    BuildContext context,
    SynchronizationProvider synchronizationProvider,
  ) async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      var category;

      if (categoryToUpdate != null) {
        category = await _editCategory();
      } else {
        category = await _addCategory();
      }

      synchronizationProvider.synchronize();
      Navigator.pop(context, category);
    }
  }

  Future<Category> _editCategory() async {
    final category = Category(
      id: categoryToUpdate!.id,
      name: nameController.text,
      color: '#${color.value.toRadixString(16)}',
      icon: IconConverter.convertCupertinoIconToMaterial(icon).codePoint,
      isTrash: false,
      vaultId: selectedVault!.id,
      createdAt: categoryToUpdate!.createdAt,
      updatedAt: DateTime.now(),
    );

    await CategoryService.update(category);
    return category;
  }

  Future<Category> _addCategory() async {
    final category = Category(
      id: Uuid().v4(),
      name: nameController.text,
      color: '#${color.value.toRadixString(16)}',
      icon: IconConverter.convertCupertinoIconToMaterial(icon).codePoint,
      isTrash: false,
      vaultId: selectedVault!.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await CategoryService.save(category);
    return category;
  }
}

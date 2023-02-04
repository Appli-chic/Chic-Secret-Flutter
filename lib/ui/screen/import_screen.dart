import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/ui/screen/new_category_screen.dart';
import 'package:chic_secret/features/category/select_category/select_category_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/import_export.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class ImportScreen extends StatefulWidget {
  final ImportData importData;

  ImportScreen({
    required this.importData,
  });

  @override
  _ImportScreenState createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Category> _newCategories = [];
  var _dataIndex = 0;
  Category? _category;

  var _categoryController = TextEditingController();
  var _newCategoryController = TextEditingController();
  var _categoryFocusNode = FocusNode();
  var _newCategoryFocusNode = FocusNode();
  var _desktopCategoryFocusNode = FocusNode();
  var _desktopNewCategoryFocusNode = FocusNode();

  @override
  void initState() {
    _categoryController =
        TextEditingController(text: widget.importData.categoriesName[_dataIndex]);
    _loadFirstCategory();
    super.initState();
  }

  _loadFirstCategory() async {
    _category = await CategoryService.getFirstByVault(selectedVault!.id);

    if (_category != null) {
      _newCategoryController.text = _category!.name;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (ChicPlatform.isDesktop()) {
      return _displaysDesktopInModal(themeProvider);
    } else {
      return _displaysMobile(themeProvider);
    }
  }

  Widget _displaysDesktopInModal(ThemeProvider themeProvider) {
    return DesktopModal(
      title: AppTranslations.of(context).text("migration"),
      body: _displaysBody(themeProvider),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicTextButton(
            child: Text(AppTranslations.of(context).text("cancel")),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicElevatedButton(
            child: Text(
              _dataIndex != widget.importData.categoriesName.length - 1
                  ? AppTranslations.of(context).text("next")
                  : AppTranslations.of(context).text("done"),
            ),
            onPressed: _dataIndex != widget.importData.categoriesName.length - 1
                ? _onNext
                : _onDone,
          ),
        ),
      ],
    );
  }

  Widget _displaysMobile(ThemeProvider themeProvider) {
    var body = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: _displaysBody(themeProvider),
      ),
    );

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: themeProvider.backgroundColor,
        navigationBar: _displaysIosAppbar(themeProvider),
        child: body,
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: body,
      );
    }
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: AppTranslations.of(context).text("import_export"),
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("migration")),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          _dataIndex != widget.importData.categoriesName.length - 1
              ? AppTranslations.of(context).text("next")
              : AppTranslations.of(context).text("done"),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: _dataIndex != widget.importData.categoriesName.length - 1
            ? _onNext
            : _onDone,
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(AppTranslations.of(context).text("migration")),
      actions: [
        ChicTextButton(
          child: Text(
            _dataIndex != widget.importData.categoriesName.length - 1
                ? AppTranslations.of(context).text("next")
                : AppTranslations.of(context).text("done"),
          ),
          onPressed: _dataIndex != widget.importData.categoriesName.length - 1
              ? _onNext
              : _onDone,
        ),
      ],
    );
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChicPlatform.isDesktop()
              ? SizedBox(height: 32.0)
              : SizedBox(height: 16.0),
          Text(
            AppTranslations.of(context).text("category_imported"),
            style: TextStyle(
              color: themeProvider.textColor,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 16.0),
          ChicTextField(
            controller: _categoryController,
            focus: _categoryFocusNode,
            desktopFocus: _desktopCategoryFocusNode,
            autoFocus: false,
            isReadOnly: true,
            label: AppTranslations.of(context).text("category"),
          ),
          SizedBox(height: 32.0),
          Text(
            AppTranslations.of(context).text("category_corresponding"),
            style: TextStyle(
              color: themeProvider.textColor,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 16.0),
          ChicTextField(
            controller: _newCategoryController,
            focus: _newCategoryFocusNode,
            desktopFocus: _desktopNewCategoryFocusNode,
            autoFocus: false,
            isReadOnly: true,
            textCapitalization: TextCapitalization.sentences,
            label: AppTranslations.of(context).text("category"),
            errorMessage:
                AppTranslations.of(context).text("error_category_empty"),
            validating: (String text) => _newCategoryController.text.isNotEmpty,
            onTap: _selectCategory,
          ),
          SizedBox(height: 16.0),
          ChicTextIconButton(
            onPressed: _createCategory,
            icon: Icon(
              Icons.add_circle,
              color: themeProvider.primaryColor,
              size: 20,
            ),
            label: Text(
              AppTranslations.of(context).text("create_category"),
              style: TextStyle(color: themeProvider.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  _selectCategory() async {
    var category = await ChicNavigator.push(
      context,
      SelectCategoryScreen(
        category: _category,
        isShowingTrash: true,
        previousPageTitle: AppTranslations.of(context).text("migration"),
      ),
      isModal: true,
    );

    if (category != null && category is Category) {
      _newCategoryController.text = category.name;
      _category = category;
      setState(() {});
    }
  }

  _createCategory() async {
    var category = await ChicNavigator.push(
      context,
      NewCategoryScreen(
        hint: _categoryController.text,
        previousPageTitle: AppTranslations.of(context).text("migration"),
      ),
      isModal: true,
    );

    if (category != null && category is Category) {
      _newCategoryController.text = category.name;
      _category = category;
      setState(() {});
    }
  }

  _onNext() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _dataIndex++;
      _newCategories.add(_category!);
      _categoryController =
          TextEditingController(text: widget.importData.categoriesName[_dataIndex]);

      setState(() {});
    }
  }

  _onDone() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      EasyLoading.show();

      // Start the migration process
      _newCategories.add(_category!);
      List<Future> entryFutures = [];

      for (var entry in widget.importData.entries) {
        // Add entries
        if (entry.hash.isNotEmpty) {
          entry.hash = Security.encrypt(currentPassword!, entry.hash);
          entry.createdAt = DateTime.now();
          entry.updatedAt = DateTime.now();

          entry.categoryId = _newCategories[
                  widget.importData.categoriesName.indexOf(entry.categoryId)]
              .id;

          entryFutures.add(EntryService.save(entry));
        }
      }

      await Future.wait(entryFutures);

      // Add Custom Fields
      List<Future> customFieldsFutures = [];

      for (var customField in widget.importData.customFields) {
        customField.createdAt = DateTime.now();
        customField.updatedAt = DateTime.now();
        customFieldsFutures.add(CustomFieldService.save(customField));
      }

      await Future.wait(customFieldsFutures);

      EasyLoading.dismiss();

      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _newCategoryController.dispose();

    _categoryFocusNode.dispose();
    _newCategoryFocusNode.dispose();

    _desktopCategoryFocusNode.dispose();
    _desktopNewCategoryFocusNode.dispose();

    super.dispose();
  }
}

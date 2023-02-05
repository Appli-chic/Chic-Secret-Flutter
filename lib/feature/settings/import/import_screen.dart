import 'dart:io';

import 'package:chic_secret/component/common/chic_elevated_button.dart';
import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/component/common/chic_text_button.dart';
import 'package:chic_secret/component/common/chic_text_field.dart';
import 'package:chic_secret/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/component/common/desktop_modal.dart';
import 'package:chic_secret/feature/category/new/new_category_screen.dart';
import 'package:chic_secret/feature/category/select_category/select_category_screen.dart';
import 'package:chic_secret/feature/settings/import/import_screen_view_model.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/import_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  late ImportScreenViewModel _viewModel;

  var _categoryFocusNode = FocusNode();
  var _newCategoryFocusNode = FocusNode();
  var _desktopCategoryFocusNode = FocusNode();
  var _desktopNewCategoryFocusNode = FocusNode();

  @override
  void initState() {
    _viewModel = ImportScreenViewModel(widget.importData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return ChangeNotifierProvider<ImportScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<ImportScreenViewModel>(
        builder: (context, value, _) {
          if (ChicPlatform.isDesktop()) {
            return _displaysDesktopInModal(themeProvider);
          } else {
            return _displaysMobile(themeProvider);
          }
        },
      ),
    );
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
              _viewModel.dataIndex !=
                      widget.importData.categoriesName.length - 1
                  ? AppTranslations.of(context).text("next")
                  : AppTranslations.of(context).text("done"),
            ),
            onPressed: _viewModel.dataIndex !=
                    widget.importData.categoriesName.length - 1
                ? _viewModel.onNext
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
          _viewModel.dataIndex != widget.importData.categoriesName.length - 1
              ? AppTranslations.of(context).text("next")
              : AppTranslations.of(context).text("done"),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed:
            _viewModel.dataIndex != widget.importData.categoriesName.length - 1
                ? _viewModel.onNext
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
            _viewModel.dataIndex != widget.importData.categoriesName.length - 1
                ? AppTranslations.of(context).text("next")
                : AppTranslations.of(context).text("done"),
          ),
          onPressed: _viewModel.dataIndex !=
                  widget.importData.categoriesName.length - 1
              ? _viewModel.onNext
              : _onDone,
        ),
      ],
    );
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    return Form(
      key: _viewModel.formKey,
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
            controller: _viewModel.categoryController,
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
            controller: _viewModel.newCategoryController,
            focus: _newCategoryFocusNode,
            desktopFocus: _desktopNewCategoryFocusNode,
            autoFocus: false,
            isReadOnly: true,
            textCapitalization: TextCapitalization.sentences,
            label: AppTranslations.of(context).text("category"),
            errorMessage:
                AppTranslations.of(context).text("error_category_empty"),
            validating: (String text) =>
                _viewModel.newCategoryController.text.isNotEmpty,
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
        category: _viewModel.category,
        isShowingTrash: true,
        previousPageTitle: AppTranslations.of(context).text("migration"),
      ),
      isModal: true,
    );

    if (category != null && category is Category) {
      _viewModel.onCategorySelected(category);
    }
  }

  _createCategory() async {
    var category = await ChicNavigator.push(
      context,
      NewCategoryScreen(
        hint: _viewModel.categoryController.text,
        previousPageTitle: AppTranslations.of(context).text("migration"),
      ),
      isModal: true,
    );

    if (category != null && category is Category) {
      _viewModel.onCategoryCreated(category);
    }
  }

  _onDone() async {
    await _viewModel.onDone();
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _viewModel.categoryController.dispose();
    _viewModel.newCategoryController.dispose();

    _categoryFocusNode.dispose();
    _newCategoryFocusNode.dispose();

    _desktopCategoryFocusNode.dispose();
    _desktopNewCategoryFocusNode.dispose();

    super.dispose();
  }
}

import 'dart:io';

import 'package:chic_secret/component/color_selector.dart';
import 'package:chic_secret/component/common/chic_elevated_button.dart';
import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/component/common/chic_text_button.dart';
import 'package:chic_secret/component/common/chic_text_field.dart';
import 'package:chic_secret/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/component/common/desktop_modal.dart';
import 'package:chic_secret/component/icon_selector.dart';
import 'package:chic_secret/features/category/new/new_category_screen_view_model.dart';
import 'package:chic_secret/features/category/predefined_category/select_predefined_category_screen.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewCategoryScreen extends StatefulWidget {
  final Category? category;
  final String? hint;
  final String previousPageTitle;

  NewCategoryScreen({
    this.category,
    this.hint,
    required this.previousPageTitle,
  });

  @override
  _NewCategoryScreenState createState() => _NewCategoryScreenState();
}

class _NewCategoryScreenState extends State<NewCategoryScreen> {
  late NewCategoryScreenViewModel _viewModel;
  late SynchronizationProvider _synchronizationProvider;

  FocusNode _nameFocusNode = FocusNode();
  FocusNode _desktopNameFocusNode = FocusNode();

  @override
  void initState() {
    _viewModel = NewCategoryScreenViewModel(widget.category, widget.hint);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

    return ChangeNotifierProvider<NewCategoryScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<NewCategoryScreenViewModel>(
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
      title: widget.category != null
          ? widget.category!.name
          : AppTranslations.of(context).text("new_category"),
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
            child: Text(AppTranslations.of(context).text("save")),
            onPressed: () {
              _viewModel.onSavingCategory(context, _synchronizationProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _displaysMobile(ThemeProvider themeProvider) {
    var child = GestureDetector(
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
        navigationBar: _displayIosAppBar(themeProvider),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: child,
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: child,
        ),
      );
    }
  }

  ObstructingPreferredSizeWidget _displayIosAppBar(
    ThemeProvider themeProvider,
  ) {
    return CupertinoNavigationBar(
      previousPageTitle: widget.previousPageTitle,
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(
        widget.category != null
            ? widget.category!.name
            : AppTranslations.of(context).text("new_category"),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          AppTranslations.of(context).text("save"),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          _viewModel.onSavingCategory(context, _synchronizationProvider);
        },
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(
        widget.category != null
            ? widget.category!.name
            : AppTranslations.of(context).text("new_category"),
      ),
      actions: [
        ChicTextButton(
          child: Text(AppTranslations.of(context).text("save")),
          onPressed: () {
            _viewModel.onSavingCategory(context, _synchronizationProvider);
          },
        ),
      ],
    );
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Form(
        key: _viewModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChicTextField(
              controller: _viewModel.nameController,
              focus: _nameFocusNode,
              desktopFocus: _desktopNameFocusNode,
              textCapitalization: TextCapitalization.sentences,
              label: AppTranslations.of(context).text("name"),
              errorMessage:
                  AppTranslations.of(context).text("error_name_empty"),
              validating: (String text) =>
                  _viewModel.nameController.text.isNotEmpty,
            ),
            SizedBox(height: 16.0),
            Text(
              AppTranslations.of(context).text("colors"),
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 16.0),
            ColorSelector(
              colorSelectorController: _viewModel.colorSelectorController,
              color: _viewModel.color,
              onColorSelected: _viewModel.onUpdateColor,
            ),
            SizedBox(height: 16.0),
            Text(
              AppTranslations.of(context).text("icons"),
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 16.0),
            IconSelector(
              iconSelectorController: _viewModel.iconSelectorController,
              icon: _viewModel.icon,
              color: _viewModel.color,
              onIconSelected: _viewModel.onUpdateIcon,
            ),
            SizedBox(height: 16.0),
            ChicTextIconButton(
              label: Text(
                AppTranslations.of(context).text("copy_category"),
                style: TextStyle(color: themeProvider.primaryColor),
              ),
              icon: Icon(
                Platform.isIOS
                    ? CupertinoIcons.doc_on_doc_fill
                    : Icons.folder_copy,
                color: themeProvider.primaryColor,
              ),
              onPressed: _selectPredefinedCategory,
            ),
          ],
        ),
      ),
    );
  }

  _selectPredefinedCategory() async {
    var category = await ChicNavigator.push(
      context,
      SelectPredefinedScreenCategory(category: _viewModel.preselectedCategory),
      isModal: true,
    );

    if (category != null && category is Category) {
      _viewModel.onPredefinedCategorySelected(category);
    }
  }

  @override
  void dispose() {
    _viewModel.nameController.dispose();
    _nameFocusNode.dispose();
    _desktopNameFocusNode.dispose();

    super.dispose();
  }
}

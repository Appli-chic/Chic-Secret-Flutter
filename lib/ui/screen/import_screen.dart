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
import 'package:chic_secret/ui/screen/select_category_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/import_export.dart';
import 'package:chic_secret/utils/security.dart';
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
        TextEditingController(text: widget.importData.categories[_dataIndex]);
    _loadFirstCategory();
    super.initState();
  }

  /// Load the first category if it exists
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

  /// Displays the screen in a modal for the desktop version
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
              _dataIndex != widget.importData.categories.length - 1
                  ? AppTranslations.of(context).text("next")
                  : AppTranslations.of(context).text("done"),
            ),
            onPressed: _dataIndex != widget.importData.categories.length - 1
                ? _onNext
                : _onDone,
          ),
        ),
      ],
    );
  }

  /// Displays the [Scaffold] for the mobile version
  Widget _displaysMobile(ThemeProvider themeProvider) {
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(AppTranslations.of(context).text("migration")),
        actions: [
          ChicTextButton(
            child: Text(
              _dataIndex != widget.importData.categories.length - 1
                  ? AppTranslations.of(context).text("next")
                  : AppTranslations.of(context).text("done"),
            ),
            onPressed: _dataIndex != widget.importData.categories.length - 1
                ? _onNext
                : _onDone,
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: _displaysBody(themeProvider),
        ),
      ),
    );
  }

  /// Displays a unified body for both mobile and desktop version
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
            hint: AppTranslations.of(context).text("category"),
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
            hint: AppTranslations.of(context).text("category"),
            errorMessage:
                AppTranslations.of(context).text("error_category_empty"),
            validating: (String text) {
              if (_newCategoryController.text.isEmpty) {
                return false;
              }

              return true;
            },
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

  /// Call the [SelectCategoryScreen] screen to select which category will
  /// be linked to the new password.
  _selectCategory() async {
    var category = await ChicNavigator.push(
      context,
      SelectCategoryScreen(
        category: _category,
        isShowingTrash: true,
      ),
      isModal: true,
    );

    if (category != null && category is Category) {
      _newCategoryController.text = category.name;
      _category = category;
      setState(() {});
    }
  }

  /// Calls the [NewCategoryScreen] screen to create a new category directly
  /// from the [NewEntryScreen] screen
  _createCategory() async {
    var category = await ChicNavigator.push(
      context,
      NewCategoryScreen(hint: _categoryController.text),
      isModal: true,
    );

    if (category != null && category is Category) {
      _newCategoryController.text = category.name;
      _category = category;
      setState(() {});
    }
  }

  /// Check if a category is selected and pass to the next category to migrate
  _onNext() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _dataIndex++;
      _newCategories.add(_category!);
      _categoryController =
          TextEditingController(text: widget.importData.categories[_dataIndex]);

      setState(() {});
    }
  }

  /// When all the categories have been migrated to a new one
  _onDone() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      // Start the migration process
      _newCategories.add(_category!);
      List<Future> entryFutures = [];

      for (var entry in widget.importData.entries) {
        // Add entries
        if (entry.hash.isNotEmpty) {
          entry.hash = Security.encrypt(currentPassword!, entry.hash);

          entry.categoryId = _newCategories[
                  widget.importData.categories.indexOf(entry.categoryId)]
              .id;

          entryFutures.add(EntryService.save(entry));
        }
      }

      await Future.wait(entryFutures);

      // Add Custom Fields
      List<Future> customFieldsFutures = [];

      for (var customField in widget.importData.customFields) {
        customFieldsFutures.add(CustomFieldService.save(customField));
      }

      await Future.wait(customFieldsFutures);

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

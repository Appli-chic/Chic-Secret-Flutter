import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/ui/component/color_selector.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/ui/component/icon_selector.dart';
import 'package:chic_secret/ui/screen/select_predefined_category.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/color.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewCategoryScreen extends StatefulWidget {
  final Category? category;
  final String? hint;

  NewCategoryScreen({
    this.category,
    this.hint,
  });

  @override
  _NewCategoryScreenState createState() => _NewCategoryScreenState();
}

class _NewCategoryScreenState extends State<NewCategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _predefinedCategoryController = TextEditingController();

  FocusNode _nameFocusNode = FocusNode();
  FocusNode _predefinedCategoryFocusNode = FocusNode();

  FocusNode _desktopNameFocusNode = FocusNode();
  FocusNode _desktopPredefinedCategoryFocusNode = FocusNode();

  ColorSelectorController _colorSelectorController = ColorSelectorController();
  IconSelectorController _iconSelectorController = IconSelectorController();

  Category? _preselectedCategory;

  Color _color = Colors.blue;
  IconData _icon = icons[0];

  @override
  void initState() {
    if (widget.category != null) {
      _nameController = TextEditingController(text: widget.category!.name);
      _color = getColorFromHex(widget.category!.color);
      _icon = IconData(widget.category!.icon, fontFamily: 'MaterialIcons');
    }

    if (widget.hint != null) {
      _nameController = TextEditingController(text: widget.hint);
    }

    super.initState();
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
            onPressed: _onAddingCategory,
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
        title: Text(
          widget.category != null
              ? widget.category!.name
              : AppTranslations.of(context).text("new_category"),
        ),
        actions: [
          ChicTextButton(
            child: Text(AppTranslations.of(context).text("save").toUpperCase()),
            onPressed: _onAddingCategory,
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
    return Container(
      margin: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChicTextField(
              controller: _nameController,
              focus: _nameFocusNode,
              desktopFocus: _desktopNameFocusNode,
              autoFocus: true,
              textCapitalization: TextCapitalization.sentences,
              hint: AppTranslations.of(context).text("name"),
              errorMessage:
                  AppTranslations.of(context).text("error_name_empty"),
              validating: (String text) => _nameController.text.isNotEmpty,
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
              colorSelectorController: _colorSelectorController,
              color: _color,
              onColorSelected: (Color color) {
                setState(() {
                  _color = color;
                });
              },
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
              iconSelectorController: _iconSelectorController,
              icon: _icon,
              color: _color,
              onIconSelected: (IconData icon) {
                setState(() {
                  _icon = icon;
                });
              },
            ),
            SizedBox(height: 16.0),
            Divider(color: themeProvider.divider),
            SizedBox(height: 16.0),
            Text(
              AppTranslations.of(context).text("help_define_categories"),
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 16.0),
            ChicTextField(
              controller: _predefinedCategoryController,
              focus: _predefinedCategoryFocusNode,
              desktopFocus: _desktopPredefinedCategoryFocusNode,
              autoFocus: false,
              isReadOnly: true,
              textCapitalization: TextCapitalization.sentences,
              hint: AppTranslations.of(context).text("predefined_categories"),
              onTap: _selectPredefinedCategory,
            ),
          ],
        ),
      ),
    );
  }

  /// Select from predefined categories to help the user to create it's categories
  _selectPredefinedCategory() async {
    var category = await ChicNavigator.push(
      context,
      SelectPredefinedCategory(category: _preselectedCategory),
      isModal: true,
    );

    if (category != null && category is Category) {
      _preselectedCategory = category;
      _nameController.text = category.name;
      _predefinedCategoryController.text = category.name;
      _color = getColorFromHex(category.color);
      _icon = IconData(category.icon, fontFamily: 'MaterialIcons');

      if (_colorSelectorController.onColorChange != null) {
        _colorSelectorController.onColorChange!(_color);
      }

      if (_iconSelectorController.onIconChange != null) {
        _iconSelectorController.onIconChange!(_icon);
      }

      setState(() {});
    }
  }

  /// Save a new category in the local database
  _onAddingCategory() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      var category;

      if (widget.category != null) {
        // We edit the category
        category = Category(
          id: widget.category!.id,
          name: _nameController.text,
          color: '#${_color.value.toRadixString(16)}',
          icon: _icon.codePoint,
          isTrash: false,
          vaultId: selectedVault!.id,
          createdAt: widget.category!.createdAt,
          updatedAt: DateTime.now(),
        );
        await CategoryService.update(category);
      } else {
        // We create a new category
        category = Category(
          id: Uuid().v4(),
          name: _nameController.text,
          color: '#${_color.value.toRadixString(16)}',
          icon: _icon.codePoint,
          isTrash: false,
          vaultId: selectedVault!.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await CategoryService.save(category);
      }

      Navigator.pop(context, category);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _predefinedCategoryController.dispose();

    _nameFocusNode.dispose();
    _predefinedCategoryFocusNode.dispose();

    _desktopNameFocusNode.dispose();
    _desktopPredefinedCategoryFocusNode.dispose();

    super.dispose();
  }
}

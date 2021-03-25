import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/ui/component/color_selector.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/ui/component/icon_selector.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewCategoryScreen extends StatefulWidget {
  @override
  _NewCategoryScreenState createState() => _NewCategoryScreenState();
}

class _NewCategoryScreenState extends State<NewCategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  var _nameFocusNode = FocusNode();
  var _desktopNameFocusNode = FocusNode();

  Color _color = Colors.blue;
  IconData _icon = icons[0];

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
      title: AppTranslations.of(context).text("new_category"),
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

  Widget _displaysMobile(ThemeProvider themeProvider) {
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(AppTranslations.of(context).text("new_category")),
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
          child: _displaysBody(themeProvider),
        ),
      ),
    );
  }

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
              validating: (String text) {
                if (_nameController.text.isEmpty) {
                  return false;
                }

                return true;
              },
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
              color: _color,
              onIconSelected: (IconData icon) {
                setState(() {
                  _icon = icon;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  _onAddingCategory() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      var category = Category(
        id: Uuid().v4(),
        name: _nameController.text,
        color: '#${_color.value.toRadixString(16)}',
        icon: _icon.codePoint,
        vaultId: selectedVault!.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      category = await CategoryService.save(category);
      Navigator.pop(context, category);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _desktopNameFocusNode.dispose();

    super.dispose();
  }
}

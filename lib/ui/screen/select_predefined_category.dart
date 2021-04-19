import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/component/category_item.dart';
import 'package:chic_secret/ui/component/common/chic_elevated_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class SelectPredefinedCategory extends StatefulWidget {
  @override
  _SelectPredefinedCategoryState createState() =>
      _SelectPredefinedCategoryState();
}

class _SelectPredefinedCategoryState extends State<SelectPredefinedCategory> {
  bool _isLoadingCategories = true;
  List<Category> _predefinedCategories = [];
  Category? _category;

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (_isLoadingCategories) {
      _generatePredefinedCategories(context);
    }

    if (ChicPlatform.isDesktop()) {
      return _displaysDesktopInModal(themeProvider);
    } else {
      return _displaysMobile(themeProvider);
    }
  }

  /// Displays the screen in a modal for the desktop version
  Widget _displaysDesktopInModal(ThemeProvider themeProvider) {
    return DesktopModal(
      title: AppTranslations.of(context).text("predefined_categories"),
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
            child: Text(AppTranslations.of(context).text("done")),
            onPressed: () {
              Navigator.pop(context, _category);
            },
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
        title: Text(AppTranslations.of(context).text("select_category")),
        actions: [
          ChicTextButton(
            child: Text(AppTranslations.of(context).text("done").toUpperCase()),
            onPressed: () {
              Navigator.pop(context, _category);
            },
          ),
        ],
      ),
      body: _displaysBody(themeProvider),
    );
  }

  /// Displays a unified body for both mobile and desktop version
  Widget _displaysBody(ThemeProvider themeProvider) {
    if (_predefinedCategories.isEmpty) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: desktopHeight,
        ),
        child: Center(
          child: Text(
            AppTranslations.of(context).text("empty_category"),
            style: TextStyle(
              fontSize: 20,
              color: themeProvider.textColor,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: _predefinedCategories.length,
      itemBuilder: (context, index) {
        return CategoryItem(
          category: _predefinedCategories[index],
          isSelected: _category != null &&
              _category!.id == _predefinedCategories[index].id,
          isForcingMobileStyle: true,
          onTap: (Category? category) {
            _category = category;
            setState(() {});
          },
        );
      },
    );
  }

  /// Loads the list of predefined categories and reload the widget
  _generatePredefinedCategories(BuildContext context) {
    _predefinedCategories = [
      Category(
        id: Uuid().v4(),
        name: AppTranslations.of(context).text("general"),
        color: "#ff2196f3",
        icon: 58136,
        isTrash: false,
        vaultId: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: Uuid().v4(),
        name: AppTranslations.of(context).text("email"),
        color: "#ffff5722",
        icon: 57898,
        isTrash: false,
        vaultId: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: Uuid().v4(),
        name: AppTranslations.of(context).text("music"),
        color: "#ff4caf50",
        icon: 58389,
        isTrash: false,
        vaultId: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: Uuid().v4(),
        name: AppTranslations.of(context).text("shopping"),
        color: "#ff9c27b0",
        icon: 58780,
        isTrash: false,
        vaultId: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: Uuid().v4(),
        name: AppTranslations.of(context).text("business"),
        color: "#ffffc107",
        icon: 57628,
        isTrash: false,
        vaultId: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: Uuid().v4(),
        name: AppTranslations.of(context).text("streaming"),
        color: "#ff795548",
        icon: 58267,
        isTrash: false,
        vaultId: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: Uuid().v4(),
        name: AppTranslations.of(context).text("bank"),
        color: "#ff00bcd4",
        icon: 57409,
        isTrash: false,
        vaultId: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: Uuid().v4(),
        name: AppTranslations.of(context).text("education"),
        color: "#ffff9800",
        icon: 57583,
        isTrash: false,
        vaultId: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: Uuid().v4(),
        name: AppTranslations.of(context).text("games"),
        color: "#ff009688",
        icon: 60833,
        isTrash: false,
        vaultId: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: Uuid().v4(),
        name: AppTranslations.of(context).text("transportation"),
        color: "#ff673ab7",
        icon: 58997,
        isTrash: false,
        vaultId: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: Uuid().v4(),
        name: AppTranslations.of(context).text("social"),
        color: "#ff3f51b5",
        icon: 57943,
        isTrash: false,
        vaultId: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Category(
        id: Uuid().v4(),
        name: AppTranslations.of(context).text("health"),
        color: "#ffe91e63",
        icon: 58328,
        isTrash: false,
        vaultId: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    setState(() {
      _isLoadingCategories = false;
    });
  }
}

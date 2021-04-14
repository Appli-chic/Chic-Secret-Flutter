import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/entry_tag.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/service/entry_tag_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/ui/component/common/chic_ahead_text_field.dart';
import 'package:chic_secret/ui/component/common/chic_icon_button.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/chic_text_field.dart';
import 'package:chic_secret/ui/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/ui/component/tag_chip.dart';
import 'package:chic_secret/ui/screen/generate_password_screen.dart';
import 'package:chic_secret/ui/screen/new_category_screen.dart';
import 'package:chic_secret/ui/screen/select_category_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/rich_text_editing_controller.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewEntryScreen extends StatefulWidget {
  final Function(Entry?)? onFinish;

  NewEntryScreen({
    this.onFinish,
  });

  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = RichTextEditingController();
  final _categoryController = TextEditingController();
  final _tagController = TextEditingController();
  final _commentController = TextEditingController();

  var _nameFocusNode = FocusNode();
  var _usernameFocusNode = FocusNode();
  var _passwordFocusNode = FocusNode();
  var _categoryFocusNode = FocusNode();
  var _tagFocusNode = FocusNode();
  var _commentFocusNode = FocusNode();

  var _desktopNameFocusNode = FocusNode();
  var _desktopUsernameFocusNode = FocusNode();
  var _desktopPasswordFocusNode = FocusNode();
  var _desktopCategoryFocusNode = FocusNode();
  var _desktopCommentFocusNode = FocusNode();

  Category? _category;
  List<String> _tagLabelList = [];
  List<TextEditingController> _customFieldsNameControllers = [];
  List<FocusNode> _customFieldsNameFocusNode = [];
  List<FocusNode> _customFieldsNameDesktopFocusNode = [];
  List<TextEditingController> _customFieldsValueControllers = [];
  List<FocusNode> _customFieldsValueFocusNode = [];
  List<FocusNode> _customFieldsValueDesktopFocusNode = [];

  @override
  void initState() {
    _loadFirstCategory();
    super.initState();
  }

  /// Load the first category if it exists
  _loadFirstCategory() async {
    _category = await CategoryService.getFirstByVault(selectedVault!.id);

    if (_category != null) {
      _categoryController.text = _category!.name;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (ChicPlatform.isDesktop()) {
      return Container(
        color: themeProvider.backgroundColor,
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Container(
                      margin: EdgeInsets.all(16),
                      child: _displaysBody(themeProvider),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 8, top: 16),
              child: _displaysDesktopToolbar(themeProvider),
            ),
          ],
        ),
      );
    } else {
      return _displaysMobile(themeProvider);
    }
  }

  /// Displays the buttons to cancel or save only for Desktop
  Widget _displaysDesktopToolbar(ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(left: 8, bottom: 8),
          child: ChicTextIconButton(
            onPressed: () {
              if (widget.onFinish != null) {
                widget.onFinish!(null);
              }
            },
            icon: Icon(
              Icons.close,
              color: themeProvider.textColor,
              size: 20,
            ),
            label: Text(
              AppTranslations.of(context).text("cancel"),
              style: TextStyle(color: themeProvider.textColor),
            ),
            backgroundColor: themeProvider.selectionBackground,
            padding: EdgeInsets.only(
              top: 13,
              bottom: 13,
              right: 24,
              left: 24,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 8, bottom: 8),
          child: ChicTextIconButton(
            onPressed: _addEntry,
            icon: Icon(
              Icons.save,
              color: themeProvider.textColor,
              size: 20,
            ),
            label: Text(
              AppTranslations.of(context).text("save"),
              style: TextStyle(color: themeProvider.textColor),
            ),
            backgroundColor: themeProvider.selectionBackground,
            padding: EdgeInsets.only(
              top: 13,
              bottom: 13,
              right: 24,
              left: 24,
            ),
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
        title: Text(AppTranslations.of(context).text("new_password")),
        actions: [
          ChicTextButton(
            child: Text(AppTranslations.of(context).text("save").toUpperCase()),
            onPressed: _addEntry,
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
              nextFocus: _desktopUsernameFocusNode,
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
              onSubmitted: (String text) {
                _usernameFocusNode.requestFocus();
              },
            ),
            SizedBox(height: 16.0),
            ChicTextField(
              controller: _usernameController,
              focus: _usernameFocusNode,
              desktopFocus: _desktopUsernameFocusNode,
              nextFocus: _desktopPasswordFocusNode,
              autoFocus: false,
              textCapitalization: TextCapitalization.none,
              hint: AppTranslations.of(context).text("username_email"),
              errorMessage:
                  AppTranslations.of(context).text("error_username_empty"),
              validating: (String text) {
                if (_usernameController.text.isEmpty) {
                  return false;
                }

                return true;
              },
              onSubmitted: (String text) {
                _passwordFocusNode.requestFocus();
              },
            ),
            SizedBox(height: 16.0),
            ChicTextField(
              controller: _passwordController,
              focus: _passwordFocusNode,
              desktopFocus: _desktopPasswordFocusNode,
              autoFocus: false,
              isPassword: true,
              hasStrengthIndicator: true,
              textCapitalization: TextCapitalization.sentences,
              hint: AppTranslations.of(context).text("password"),
              errorMessage:
                  AppTranslations.of(context).text("error_empty_password"),
              validating: (String text) {
                if (_passwordController.text.isEmpty) {
                  return false;
                }

                return true;
              },
              onSubmitted: (String text) {},
            ),
            SizedBox(height: 16.0),
            ChicTextIconButton(
              onPressed: _generateNewPassword,
              icon: Icon(
                Icons.auto_fix_high,
                color: themeProvider.primaryColor,
                size: 20,
              ),
              label: Text(
                AppTranslations.of(context).text("generate_password"),
                style: TextStyle(color: themeProvider.primaryColor),
              ),
            ),
            SizedBox(height: 32.0),
            Text(
              AppTranslations.of(context).text("category"),
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
              textCapitalization: TextCapitalization.sentences,
              hint: AppTranslations.of(context).text("category"),
              errorMessage:
                  AppTranslations.of(context).text("error_category_empty"),
              validating: (String text) {
                if (_categoryController.text.isEmpty) {
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
            SizedBox(height: 32.0),
            Text(
              AppTranslations.of(context).text("tags"),
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 16.0),
            ChicAheadTextField(
              controller: _tagController,
              hint: AppTranslations.of(context).text("tags"),
              suggestionsCallback: (pattern) async {
                if (pattern.isEmpty) {
                  return [];
                }

                return await TagService.searchingTagInVault(
                    selectedVault!.id, pattern);
              },
              itemBuilder: (context, tag) {
                return ListTile(
                  horizontalTitleGap: 0,
                  leading: Icon(Icons.tag),
                  title: Text(tag.name),
                );
              },
              onSuggestionSelected: (tag) {
                _tagLabelList.add(tag.name);
                _tagController.clear();
                setState(() {});
              },
              onSubmitted: (String text) {
                _tagLabelList.add(text);
                _tagController.clear();
                setState(() {});
              },
            ),
            SizedBox(height: 16.0),
            Wrap(
              children: _createChipsList(themeProvider),
            ),
            SizedBox(height: 32.0),
            Text(
              AppTranslations.of(context).text("custom_fields"),
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 16.0),
            _displaysCustomFields(themeProvider),
            SizedBox(height: 16.0),
            ChicTextIconButton(
              onPressed: _onAddCustomField,
              icon: Icon(
                Icons.add_circle,
                color: themeProvider.primaryColor,
                size: 20,
              ),
              label: Text(
                AppTranslations.of(context).text("add_custom_fields"),
                style: TextStyle(color: themeProvider.primaryColor),
              ),
            ),
            SizedBox(height: 32.0),
            Text(
              AppTranslations.of(context).text("comment"),
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 16.0),
            ChicTextField(
              controller: _commentController,
              focus: _commentFocusNode,
              desktopFocus: _desktopCommentFocusNode,
              autoFocus: false,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              hint: AppTranslations.of(context).text("comment"),
            ),
          ],
        ),
      ),
    );
  }

  /// Triggered when we add a new custom field to the list
  _onAddCustomField() {
    _customFieldsNameControllers.add(TextEditingController());
    _customFieldsNameFocusNode.add(FocusNode());
    _customFieldsNameDesktopFocusNode.add(FocusNode());

    _customFieldsValueControllers.add(TextEditingController());
    _customFieldsValueFocusNode.add(FocusNode());
    _customFieldsValueDesktopFocusNode.add(FocusNode());
    setState(() {});
  }

  /// Displays the customs fields in the form
  Widget _displaysCustomFields(ThemeProvider themeProvider) {
    List<Widget> customFields = [];

    for (var customFieldIndex = 0;
        customFieldIndex < _customFieldsNameControllers.length;
        customFieldIndex++) {
      var isLast = customFieldIndex == _customFieldsNameControllers.length - 1;

      var customFieldDivider = Column(
        children: [
          SizedBox(height: 16.0),
          Divider(
            color: themeProvider.divider,
            endIndent: 70,
          ),
          SizedBox(height: 16.0),
        ],
      );

      var customFieldWidget = Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    ChicTextField(
                      controller:
                          _customFieldsNameControllers[customFieldIndex],
                      focus: _customFieldsNameFocusNode[customFieldIndex],
                      desktopFocus:
                          _customFieldsNameDesktopFocusNode[customFieldIndex],
                      nextFocus:
                          _customFieldsValueDesktopFocusNode[customFieldIndex],
                      autoFocus: false,
                      textCapitalization: TextCapitalization.sentences,
                      hint: AppTranslations.of(context).text("name"),
                      errorMessage:
                          AppTranslations.of(context).text("error_text_empty"),
                      validating: (String text) {
                        if (_customFieldsNameControllers[customFieldIndex]
                            .text
                            .isEmpty) {
                          return false;
                        }

                        return true;
                      },
                      onSubmitted: (String text) {
                        _customFieldsValueFocusNode[customFieldIndex]
                            .requestFocus();
                      },
                    ),
                    SizedBox(height: 16.0),
                    ChicTextField(
                      controller:
                          _customFieldsValueControllers[customFieldIndex],
                      focus: _customFieldsValueFocusNode[customFieldIndex],
                      desktopFocus:
                          _customFieldsValueDesktopFocusNode[customFieldIndex],
                      autoFocus: false,
                      textCapitalization: TextCapitalization.sentences,
                      hint: AppTranslations.of(context).text("value"),
                      errorMessage:
                          AppTranslations.of(context).text("error_text_empty"),
                      validating: (String text) {
                        if (_customFieldsValueControllers[customFieldIndex]
                            .text
                            .isEmpty) {
                          return false;
                        }

                        return true;
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 16, left: 16),
                child: ChicIconButton(
                  type: ChicIconButtonType.filledCircle,
                  icon: Icons.remove,
                  onPressed: () {
                    _customFieldsNameControllers.removeAt(customFieldIndex);
                    _customFieldsNameFocusNode.removeAt(customFieldIndex);
                    _customFieldsNameDesktopFocusNode
                        .removeAt(customFieldIndex);

                    _customFieldsValueControllers.removeAt(customFieldIndex);
                    _customFieldsValueFocusNode.removeAt(customFieldIndex);
                    _customFieldsValueDesktopFocusNode
                        .removeAt(customFieldIndex);

                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          !isLast ? customFieldDivider : SizedBox.shrink(),
        ],
      );

      customFields.add(customFieldWidget);
    }

    return Column(
      children: customFields,
    );
  }

  /// Displays the list of chips that had been added
  List<Widget> _createChipsList(ThemeProvider themeProvider) {
    List<Widget> chips = [];

    for (var tagIndex = 0; tagIndex < _tagLabelList.length; tagIndex++) {
      chips.add(
        TagChip(
          name: _tagLabelList[tagIndex],
          index: tagIndex,
          onDelete: (int index) {
            _tagLabelList.removeAt(tagIndex);
            setState(() {});
          },
        ),
      );
    }

    return chips;
  }

  /// Call the [SelectCategoryScreen] screen to select which category will
  /// be linked to the new password.
  _selectCategory() async {
    var category = await ChicNavigator.push(
      context,
      SelectCategoryScreen(category: _category),
      isModal: true,
    );

    if (category != null && category is Category) {
      _categoryController.text = category.name;
      _category = category;
      setState(() {});
    }
  }

  /// Calls the [NewCategoryScreen] screen to create a new category directly
  /// from the [NewEntryScreen] screen
  _createCategory() async {
    var category = await ChicNavigator.push(
      context,
      NewCategoryScreen(),
      isModal: true,
    );

    if (category != null && category is Category) {
      _categoryController.text = category.name;
      _category = category;
      setState(() {});
    }
  }

  /// Calls the [GeneratePasswordScreen] screen to help the user
  /// generating a new password
  _generateNewPassword() async {
    var password = await ChicNavigator.push(
      context,
      GeneratePasswordScreen(),
      isModal: true,
    );

    if (password != null && password is String) {
      _passwordController.text = password;
      setState(() {});
    }
  }

  /// Save a new entry in the local database
  _addEntry() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      if (_category == null) {
        return;
      }

      var entry = Entry(
        id: Uuid().v4(),
        name: _nameController.text,
        username: _usernameController.text,
        hash: Security.encrypt(currentPassword!, _passwordController.text),
        comment: _commentController.text,
        vaultId: selectedVault!.id,
        categoryId: _category!.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the entry
      await EntryService.save(entry);

      // Save all the tags linked to the password
      for (var tagLabel in _tagLabelList) {
        var tag = Tag(
          id: Uuid().v4(),
          name: tagLabel,
          vaultId: selectedVault!.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await TagService.save(tag);

        // Save the Entry Tag
        var entryTag = EntryTag(
          entryId: entry.id,
          tagId: tag.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await EntryTagService.save(entryTag);
      }

      // Save all the custom fields
      for (var customFieldIndex = 0;
          customFieldIndex < _customFieldsNameControllers.length;
          customFieldIndex++) {
        var customField = CustomField(
          id: Uuid().v4(),
          name: _customFieldsNameControllers[customFieldIndex].text,
          value: _customFieldsValueControllers[customFieldIndex].text,
          entryId: entry.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await CustomFieldService.save(customField);
      }

      // Return to the previous screen
      if (widget.onFinish != null && ChicPlatform.isDesktop()) {
        widget.onFinish!(entry);

      } else {
        Navigator.pop(context, entry);
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _categoryController.dispose();
    _tagController.dispose();
    _commentController.dispose();

    for (var customFieldsNameController in _customFieldsNameControllers) {
      customFieldsNameController.dispose();
    }

    for (var customFieldsValueController in _customFieldsValueControllers) {
      customFieldsValueController.dispose();
    }

    // Dispose node focus
    _nameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _categoryFocusNode.dispose();
    _tagFocusNode.dispose();
    _commentFocusNode.dispose();

    for (var customFieldsNameFocusNode in _customFieldsNameFocusNode) {
      customFieldsNameFocusNode.dispose();
    }

    for (var customFieldsValueFocusNode in _customFieldsValueFocusNode) {
      customFieldsValueFocusNode.dispose();
    }

    // Dispose node focus for desktop
    _desktopNameFocusNode.dispose();
    _desktopUsernameFocusNode.dispose();
    _desktopPasswordFocusNode.dispose();
    _desktopCategoryFocusNode.dispose();
    _desktopCommentFocusNode.dispose();

    for (var customFieldsNameDesktopFocusNode
        in _customFieldsNameDesktopFocusNode) {
      customFieldsNameDesktopFocusNode.dispose();
    }

    for (var customFieldsValueDesktopFocusNode
        in _customFieldsValueDesktopFocusNode) {
      customFieldsValueDesktopFocusNode.dispose();
    }

    super.dispose();
  }
}

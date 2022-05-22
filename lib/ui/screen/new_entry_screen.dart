import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/entry_tag.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
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
  final Entry? entry;
  final Function(Entry?)? onFinish;
  final Function()? onReloadCategories;

  NewEntryScreen({
    this.entry,
    this.onFinish,
    this.onReloadCategories,
  });

  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  late SynchronizationProvider _synchronizationProvider;

  final _formKey = GlobalKey<FormState>();

  var _nameController = TextEditingController();
  var _usernameController = TextEditingController();
  var _passwordController = RichTextEditingController();
  var _categoryController = TextEditingController();
  var _tagController = TextEditingController();
  var _commentController = TextEditingController();

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
  List<String> _customFieldsIds = [];
  List<TextEditingController> _customFieldsNameControllers = [];
  List<FocusNode> _customFieldsNameFocusNode = [];
  List<FocusNode> _customFieldsNameDesktopFocusNode = [];
  List<TextEditingController> _customFieldsValueControllers = [];
  List<FocusNode> _customFieldsValueFocusNode = [];
  List<FocusNode> _customFieldsValueDesktopFocusNode = [];
  List<Tag> _tags = [];
  List<CustomField> _customFields = [];

  @override
  void initState() {
    if (widget.entry != null) {
      _nameController = TextEditingController(text: widget.entry!.name);
      _usernameController = TextEditingController(text: widget.entry!.username);
      _passwordController = RichTextEditingController(
          text: Security.decrypt(currentPassword!, widget.entry!.hash));
      _categoryController =
          TextEditingController(text: widget.entry!.category!.name);
      _commentController = TextEditingController(text: widget.entry!.comment);

      _category = widget.entry!.category!;
      _loadTags();
      _loadCustomFields();
    } else {
      if (ChicPlatform.isDesktop()) {
        if (selectedCategory == null) {
          _loadFirstCategory();
        } else {
          _category = selectedCategory;
          _categoryController.text = _category!.name;
        }
      } else {
        _loadFirstCategory();
      }
    }

    super.initState();
  }

  _loadTags() async {
    _tags = await TagService.getAllByEntry(widget.entry!.id);

    for (var tag in _tags) {
      _tagLabelList.add(tag.name);
    }

    setState(() {});
  }

  _loadCustomFields() async {
    _customFields = await CustomFieldService.getAllByEntry(widget.entry!.id);

    for (var customField in _customFields) {
      _customFieldsIds.add(customField.id);
      _customFieldsNameControllers
          .add(TextEditingController(text: customField.name));
      _customFieldsNameFocusNode.add(FocusNode());
      _customFieldsNameDesktopFocusNode.add(FocusNode());

      _customFieldsValueControllers
          .add(TextEditingController(text: customField.value));
      _customFieldsValueFocusNode.add(FocusNode());
      _customFieldsValueDesktopFocusNode.add(FocusNode());
    }

    setState(() {});
  }

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
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

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
            onPressed: _save,
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

  Widget _displaysMobile(ThemeProvider themeProvider) {
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        title: widget.entry != null
            ? Text(widget.entry!.name)
            : Text(AppTranslations.of(context).text("new_password")),
        actions: [
          ChicTextButton(
            child: Text(AppTranslations.of(context).text("save")),
            onPressed: _save,
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

  Widget _displaysBody(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChicPlatform.isDesktop()
                ? Text(
                    AppTranslations.of(context).text("new_password"),
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  )
                : SizedBox.shrink(),
            ChicPlatform.isDesktop()
                ? SizedBox(height: 16.0)
                : SizedBox.shrink(),
            ChicTextField(
              controller: _nameController,
              focus: _nameFocusNode,
              desktopFocus: _desktopNameFocusNode,
              nextFocus: _desktopUsernameFocusNode,
              autoFocus: true,
              textCapitalization: TextCapitalization.sentences,
              label: AppTranslations.of(context).text("name"),
              errorMessage:
                  AppTranslations.of(context).text("error_name_empty"),
              validating: (String text) => _nameController.text.isNotEmpty,
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
              keyboardType: TextInputType.emailAddress,
              label: AppTranslations.of(context).text("username_email"),
              errorMessage:
                  AppTranslations.of(context).text("error_username_empty"),
              validating: (String text) => _usernameController.text.isNotEmpty,
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
              textCapitalization: TextCapitalization.none,
              label: AppTranslations.of(context).text("password"),
              errorMessage:
                  AppTranslations.of(context).text("error_empty_password"),
              validating: (String text) => _passwordController.text.isNotEmpty,
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
              label: AppTranslations.of(context).text("category"),
              errorMessage:
                  AppTranslations.of(context).text("error_category_empty"),
              validating: (String text) => _categoryController.text.isNotEmpty,
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
            SizedBox(height: 16.0),
            Divider(color: themeProvider.divider),
            SizedBox(height: 16.0),
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
              label: AppTranslations.of(context).text("comment"),
            ),
          ],
        ),
      ),
    );
  }

  _onAddCustomField() {
    _customFieldsIds.add("");
    _customFieldsNameControllers.add(TextEditingController());
    _customFieldsNameFocusNode.add(FocusNode());
    _customFieldsNameDesktopFocusNode.add(FocusNode());

    _customFieldsValueControllers.add(TextEditingController());
    _customFieldsValueFocusNode.add(FocusNode());
    _customFieldsValueDesktopFocusNode.add(FocusNode());
    setState(() {});
  }

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
                      label: AppTranslations.of(context).text("name"),
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
                      label: AppTranslations.of(context).text("value"),
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
                    _customFieldsIds.removeAt(customFieldIndex);
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

  _createCategory() async {
    var category = await ChicNavigator.push(
      context,
      NewCategoryScreen(),
      isModal: true,
    );

    if (category != null && category is Category) {
      if (ChicPlatform.isDesktop() && widget.onReloadCategories != null) {
        widget.onReloadCategories!();
      }

      _categoryController.text = category.name;
      _category = category;
      setState(() {});
    }
  }

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

  _save() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      if (_category == null) {
        return;
      }

      Entry entry;

      if (widget.entry != null) {
        // We are updating an entry that already exist
        entry = Entry(
          id: widget.entry!.id,
          name: _nameController.text,
          username: _usernameController.text,
          hash: Security.encrypt(currentPassword!, _passwordController.text),
          comment: _commentController.text,
          vaultId: selectedVault!.id,
          categoryId: _category!.id,
          passwordSize: _passwordController.text.length,
          createdAt: widget.entry!.createdAt,
          updatedAt: DateTime.now(),
        );

        // Update the entry
        await EntryService.update(entry);
      } else {
        // We are creating a new entry
        entry = Entry(
          id: Uuid().v4(),
          name: _nameController.text,
          username: _usernameController.text,
          hash: Security.encrypt(currentPassword!, _passwordController.text),
          comment: _commentController.text,
          vaultId: selectedVault!.id,
          categoryId: _category!.id,
          passwordSize: _passwordController.text.length,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save the entry
        await EntryService.save(entry);
      }

      // Save all the tags linked to the password
      for (var tagLabel in _tagLabelList) {
        // Check if the tag already exist in the database
        var tag =
            await TagService.getTagByVaultByName(selectedVault!.id, tagLabel);

        if (tag == null) {
          tag = Tag(
            id: Uuid().v4(),
            name: tagLabel,
            vaultId: selectedVault!.id,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await TagService.save(tag);
        }

        // Save the Entry Tag if the tag isn't already linked to it
        if (_tags.where((t) => t.name == tag!.name).isEmpty) {
          var entryTag = EntryTag(
            entryId: entry.id,
            tagId: tag.id,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await EntryTagService.save(entryTag);
        }
      }

      // Delete the tags if they are not linked to the entry anymore
      for (var tag in _tags) {
        if (_tagLabelList.where((t) => t == tag.name).isEmpty) {
          await EntryTagService.delete(entry.id, tag.id);
        }
      }

      // Delete the custom fields that are not existent anymore
      for (var customField in _customFields) {
        var exist =
            _customFieldsIds.where((id) => id == customField.id).isNotEmpty;

        if (!exist) {
          await CustomFieldService.delete(customField);
        }
      }

      // Add or the update the custom fields
      for (var customFieldIndex = 0;
          customFieldIndex < _customFieldsNameControllers.length;
          customFieldIndex++) {
        var exist = _customFieldsIds[customFieldIndex].isNotEmpty;

        var customField = CustomField(
          id: "",
          name: _customFieldsNameControllers[customFieldIndex].text,
          value: _customFieldsValueControllers[customFieldIndex].text,
          entryId: entry.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (!exist) {
          // Create a new one
          customField.id = Uuid().v4();
          await CustomFieldService.save(customField);
        } else {
          // Update the custom field
          customField.id = _customFieldsIds[customFieldIndex];
          await CustomFieldService.update(customField);
        }
      }

      _synchronizationProvider.synchronize();

      // Return to the previous screen
      entry.category = _category;
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

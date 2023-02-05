import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/feature/category/new/new_category_screen.dart';
import 'package:chic_secret/feature/category/select_category/select_category_screen.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/category.dart';
import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/entry_tag.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/service/category_service.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/service/entry_tag_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/ui/screen/generate_password_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/constant.dart';
import 'package:chic_secret/utils/rich_text_editing_controller.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class NewEntryScreenViewModel with ChangeNotifier {
  Locale? _locale;
  final formKey = GlobalKey<FormState>();

  var nameController = TextEditingController();
  var usernameController = TextEditingController();
  var passwordController = RichTextEditingController();
  var categoryController = TextEditingController();
  var tagController = TextEditingController();
  var commentController = TextEditingController();

  Category? category;
  List<String> tagLabelList = [];
  List<String> customFieldsIds = [];
  List<TextEditingController> customFieldsNameControllers = [];
  List<FocusNode> customFieldsNameFocusNode = [];
  List<FocusNode> customFieldsNameDesktopFocusNode = [];
  List<TextEditingController> customFieldsValueControllers = [];
  List<FocusNode> customFieldsValueFocusNode = [];
  List<FocusNode> customFieldsValueDesktopFocusNode = [];
  List<Tag> tags = [];
  List<CustomField> customFields = [];

  Entry? _previousEntry = null;
  Function()? _onReloadCategories = null;
  Function(Entry?)? _onFinish = null;

  NewEntryScreenViewModel(
    Entry? entry,
    Function()? onReloadCategories,
    Function(Entry?)? onFinish,
    BuildContext context,
  ) {
    _previousEntry = entry;
    _onReloadCategories = onReloadCategories;
    _onFinish = onFinish;
    _locale = Localizations.localeOf(context);

    if (entry != null) {
      _initEditEntry();
    } else {
      _initNewEntry();
    }
  }

  _initEditEntry() {
    nameController = TextEditingController(text: _previousEntry!.name);
    usernameController = TextEditingController(text: _previousEntry!.username);
    passwordController = RichTextEditingController(
        text: Security.decrypt(currentPassword!, _previousEntry!.hash));
    categoryController =
        TextEditingController(text: _previousEntry!.category!.name);
    commentController = TextEditingController(text: _previousEntry!.comment);

    category = _previousEntry!.category!;
    _loadTags();
    _loadCustomFields();
  }

  _initNewEntry() {
    _prefillPassword();
    _prefillUsername();

    if (ChicPlatform.isDesktop()) {
      if (selectedCategory == null) {
        _loadFirstCategory();
      } else {
        category = selectedCategory;
        categoryController.text = category!.name;
      }
    } else {
      _loadFirstCategory();
    }
  }

  _prefillPassword() async {
    passwordController = RichTextEditingController(
      text: Security.generatePasswordWithWords(
        _locale,
        defaultPasswordWordNumber,
        true,
        true,
        true,
      ),
    );
  }

  _prefillUsername() async {
    final entries = await EntryService.getAllByVault(selectedVault!.id);
    if (entries.isEmpty) return;
    final usernameMap = {};

    for (final entry in entries) {
      if (usernameMap.containsKey(entry.username)) {
        usernameMap[entry.username] += 1;
      } else {
        usernameMap[entry.username] = 1;
      }
    }

    final usernameMapValues = usernameMap.values.toList();
    usernameMapValues.sort((number1, number2) => number2.compareTo(number1));
    final mostUsedUsername = usernameMap.keys.firstWhere(
        (username) => usernameMap[username] == usernameMapValues.first);
    usernameController = TextEditingController(text: mostUsedUsername);
  }

  _loadTags() async {
    tags = await TagService.getAllByEntry(_previousEntry!.id);

    for (var tag in tags) {
      tagLabelList.add(tag.name);
    }

    notifyListeners();
  }

  _loadCustomFields() async {
    customFields = await CustomFieldService.getAllByEntry(_previousEntry!.id);

    for (var customField in customFields) {
      customFieldsIds.add(customField.id);
      customFieldsNameControllers
          .add(TextEditingController(text: customField.name));
      customFieldsNameFocusNode.add(FocusNode());
      customFieldsNameDesktopFocusNode.add(FocusNode());

      customFieldsValueControllers
          .add(TextEditingController(text: customField.value));
      customFieldsValueFocusNode.add(FocusNode());
      customFieldsValueDesktopFocusNode.add(FocusNode());
    }

    notifyListeners();
  }

  _loadFirstCategory() async {
    category = await CategoryService.getFirstByVault(selectedVault!.id);

    if (category != null) {
      categoryController.text = category!.name;
      notifyListeners();
    }
  }

  onAddCustomField() {
    customFieldsIds.add("");
    customFieldsNameControllers.add(TextEditingController());
    customFieldsNameFocusNode.add(FocusNode());
    customFieldsNameDesktopFocusNode.add(FocusNode());

    customFieldsValueControllers.add(TextEditingController());
    customFieldsValueFocusNode.add(FocusNode());
    customFieldsValueDesktopFocusNode.add(FocusNode());
    notifyListeners();
  }

  onRemoveCustomField(int customFieldIndex) {
    customFieldsIds.removeAt(customFieldIndex);
    customFieldsNameControllers.removeAt(customFieldIndex);
    customFieldsNameFocusNode.removeAt(customFieldIndex);
    customFieldsNameDesktopFocusNode.removeAt(customFieldIndex);

    customFieldsValueControllers.removeAt(customFieldIndex);
    customFieldsValueFocusNode.removeAt(customFieldIndex);
    customFieldsValueDesktopFocusNode.removeAt(customFieldIndex);

    notifyListeners();
  }

  selectCategory(BuildContext context) async {
    var title = _previousEntry != null
        ? _previousEntry!.name
        : AppTranslations.of(context).text("new_password");

    var new_category = await ChicNavigator.push(
      context,
      SelectCategoryScreen(category: category, previousPageTitle: title),
      isModal: true,
    );

    if (new_category != null && new_category is Category) {
      categoryController.text = new_category.name;
      category = new_category;
      notifyListeners();
    }
  }

  createCategory(BuildContext context) async {
    var title = _previousEntry != null
        ? _previousEntry!.name
        : AppTranslations.of(context).text("new_password");

    var category = await ChicNavigator.push(
      context,
      NewCategoryScreen(previousPageTitle: title),
      isModal: true,
    );

    if (category != null && category is Category) {
      if (ChicPlatform.isDesktop() && _onReloadCategories != null) {
        _onReloadCategories!();
      }

      categoryController.text = category.name;
      category = category;
      notifyListeners();
    }
  }

  generateNewPassword(BuildContext context) async {
    var title = _previousEntry != null
        ? _previousEntry!.name
        : AppTranslations.of(context).text("new_password");

    var password = await ChicNavigator.push(
      context,
      GeneratePasswordScreen(previousPageTitle: title),
      isModal: true,
    );

    if (password != null && password is String) {
      passwordController.text = password;
      notifyListeners();
    }
  }

  save(BuildContext context,
      SynchronizationProvider synchronizationProvider) async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      if (category == null) {
        return;
      }

      Entry entry;

      if (_previousEntry != null) {
        entry = await _updateEntry();
      } else {
        entry = await _createEntry();
      }

      await _saveTags(entry);
      await _deleteTags(entry);
      await _deleteCustomFields();
      await _addOrUpdateCustomFields(entry);

      synchronizationProvider.synchronize();

      // Return to the previous screen
      entry.category = category;
      if (_onFinish != null && ChicPlatform.isDesktop()) {
        _onFinish!(entry);
      } else {
        Navigator.pop(context, entry);
      }
    }
  }

  Future<Entry> _updateEntry() async {
    final entry = Entry(
      id: _previousEntry!.id,
      name: nameController.text,
      username: usernameController.text,
      hash: Security.encrypt(currentPassword!, passwordController.text),
      comment: commentController.text,
      vaultId: selectedVault!.id,
      categoryId: category!.id,
      passwordSize: passwordController.text.length,
      createdAt: _previousEntry!.createdAt,
      updatedAt: DateTime.now(),
    );

    await EntryService.update(entry);
    return entry;
  }

  Future<Entry> _createEntry() async {
    final entry = Entry(
      id: Uuid().v4(),
      name: nameController.text,
      username: usernameController.text,
      hash: Security.encrypt(currentPassword!, passwordController.text),
      comment: commentController.text,
      vaultId: selectedVault!.id,
      categoryId: category!.id,
      passwordSize: passwordController.text.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await EntryService.save(entry);
    return entry;
  }

  _saveTags(Entry entry) async {
    for (var tagLabel in tagLabelList) {
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
      if (tags.where((t) => t.name == tag!.name).isEmpty) {
        var entryTag = EntryTag(
          entryId: entry.id,
          tagId: tag.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await EntryTagService.save(entryTag);
      }
    }
  }

  _deleteTags(Entry entry) async {
    for (var tag in tags) {
      if (tagLabelList.where((t) => t == tag.name).isEmpty) {
        await EntryTagService.delete(entry.id, tag.id);
      }
    }
  }

  _deleteCustomFields() async {
    for (var customField in customFields) {
      var exist =
          customFieldsIds.where((id) => id == customField.id).isNotEmpty;

      if (!exist) {
        await CustomFieldService.delete(customField);
      }
    }
  }

  _addOrUpdateCustomFields(Entry entry) async {
    for (var customFieldIndex = 0;
        customFieldIndex < customFieldsNameControllers.length;
        customFieldIndex++) {
      var exist = customFieldsIds[customFieldIndex].isNotEmpty;

      var customField = CustomField(
        id: "",
        name: customFieldsNameControllers[customFieldIndex].text,
        value: customFieldsValueControllers[customFieldIndex].text,
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
        customField.id = customFieldsIds[customFieldIndex];
        await CustomFieldService.update(customField);
      }
    }
  }
}

import 'dart:io';

import 'package:chic_secret/component/common/chic_ahead_text_field.dart';
import 'package:chic_secret/component/common/chic_icon_button.dart';
import 'package:chic_secret/component/common/chic_text_button.dart';
import 'package:chic_secret/component/common/chic_text_field.dart';
import 'package:chic_secret/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/component/tag_chip.dart';
import 'package:chic_secret/feature/entry/new/new_entry_screen_view_model.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewEntryScreen extends StatefulWidget {
  final Entry? entry;
  final Function(Entry?)? onFinish;
  final Function()? onReloadCategories;
  final String previousPageTitle;

  NewEntryScreen({
    this.entry,
    this.onFinish,
    this.onReloadCategories,
    required this.previousPageTitle,
  });

  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  late NewEntryScreenViewModel _viewModel;
  late SynchronizationProvider _synchronizationProvider;

  var _nameFocusNode = FocusNode();
  var _usernameFocusNode = FocusNode();
  var _passwordFocusNode = FocusNode();
  var _categoryFocusNode = FocusNode();
  var _tagFocusNode = FocusNode();
  var _commentFocusNode = FocusNode();

  var _desktopNameFocusNode = FocusNode();
  var _desktopUsernameFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  var _desktopPasswordFocusNode = FocusNode();
  var _desktopCategoryFocusNode = FocusNode();
  var _desktopCommentFocusNode = FocusNode();

  @override
  void initState() {
    _viewModel = NewEntryScreenViewModel(
      widget.entry,
      widget.onReloadCategories,
      widget.onFinish,
    );

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _viewModel.initLocale(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

    return ChangeNotifierProvider<NewEntryScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<NewEntryScreenViewModel>(
        builder: (context, value, _) {
          if (ChicPlatform.isDesktop()) {
            return Container(
              color: themeProvider.backgroundColor,
              child: Column(
                children: [
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
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
        },
      ),
    );
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
      previousPageTitle: widget.previousPageTitle,
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: widget.entry != null
          ? Text(widget.entry!.name)
          : Text(AppTranslations.of(context).text("new_password")),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          AppTranslations.of(context).text("save"),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: _save,
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      scrolledUnderElevation: 0,
      title: widget.entry != null
          ? Text(widget.entry!.name)
          : Text(AppTranslations.of(context).text("new_password")),
      actions: [
        ChicTextButton(
          child: Text(AppTranslations.of(context).text("save")),
          onPressed: _save,
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
              controller: _viewModel.nameController,
              focus: _nameFocusNode,
              desktopFocus: _desktopNameFocusNode,
              nextFocus: _desktopUsernameFocusNode,
              autoFocus: true,
              textCapitalization: TextCapitalization.sentences,
              label: AppTranslations.of(context).text("name"),
              errorMessage:
                  AppTranslations.of(context).text("error_name_empty"),
              validating: (String text) =>
                  _viewModel.nameController.text.isNotEmpty,
              onSubmitted: (String text) {
                _usernameFocusNode.requestFocus();
              },
            ),
            SizedBox(height: 16.0),
            ChicTextField(
              controller: _viewModel.usernameController,
              focus: _usernameFocusNode,
              desktopFocus: _desktopUsernameFocusNode,
              nextFocus: _desktopPasswordFocusNode,
              autoFocus: false,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.emailAddress,
              label: AppTranslations.of(context).text("username_email"),
              errorMessage:
                  AppTranslations.of(context).text("error_username_empty"),
              validating: (String text) =>
                  _viewModel.usernameController.text.isNotEmpty,
              onSubmitted: (String text) {
                _passwordFocusNode.requestFocus();
              },
            ),
            SizedBox(height: 16.0),
            ChicTextField(
              controller: _viewModel.passwordController,
              focus: _passwordFocusNode,
              desktopFocus: _desktopPasswordFocusNode,
              autoFocus: false,
              isPassword: true,
              hasStrengthIndicator: true,
              textCapitalization: TextCapitalization.none,
              label: AppTranslations.of(context).text("password"),
              errorMessage:
                  AppTranslations.of(context).text("error_empty_password"),
              validating: (String text) =>
                  _viewModel.passwordController.text.isNotEmpty,
              onSubmitted: (String text) {},
            ),
            SizedBox(height: 16.0),
            ChicTextIconButton(
              onPressed: _generateNewPassword,
              icon: Icon(
                Platform.isIOS
                    ? CupertinoIcons.wand_stars
                    : Icons.auto_fix_high,
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
              controller: _viewModel.categoryController,
              focus: _categoryFocusNode,
              desktopFocus: _desktopCategoryFocusNode,
              autoFocus: false,
              isReadOnly: true,
              textCapitalization: TextCapitalization.sentences,
              label: AppTranslations.of(context).text("category"),
              errorMessage:
                  AppTranslations.of(context).text("error_category_empty"),
              validating: (String text) =>
                  _viewModel.categoryController.text.isNotEmpty,
              onTap: _selectCategory,
            ),
            SizedBox(height: 16.0),
            ChicTextIconButton(
              onPressed: _createCategory,
              icon: Icon(
                Platform.isIOS
                    ? CupertinoIcons.add_circled_solid
                    : Icons.add_circle,
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
              controller: _viewModel.tagController,
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
                  horizontalTitleGap: 8,
                  leading: Icon(
                      Platform.isIOS ? CupertinoIcons.tag_solid : Icons.tag),
                  title: Text(tag.name),
                );
              },
              onSuggestionSelected: (tag) {
                _viewModel.tagLabelList.add(tag.name);
                _viewModel.tagController.clear();
                setState(() {});
              },
              onSubmitted: (String text) {
                _viewModel.tagLabelList.add(text);
                _viewModel.tagController.clear();
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
              onPressed: _viewModel.onAddCustomField,
              icon: Icon(
                Platform.isIOS
                    ? CupertinoIcons.add_circled_solid
                    : Icons.add_circle,
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
              controller: _viewModel.commentController,
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

  Widget _displaysCustomFields(ThemeProvider themeProvider) {
    List<Widget> customFields = [];

    for (var customFieldIndex = 0;
        customFieldIndex < _viewModel.customFieldsNameControllers.length;
        customFieldIndex++) {
      var isLast =
          customFieldIndex == _viewModel.customFieldsNameControllers.length - 1;

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
                      controller: _viewModel
                          .customFieldsNameControllers[customFieldIndex],
                      focus: _viewModel
                          .customFieldsNameFocusNode[customFieldIndex],
                      desktopFocus: _viewModel
                          .customFieldsNameDesktopFocusNode[customFieldIndex],
                      nextFocus: _viewModel
                          .customFieldsValueDesktopFocusNode[customFieldIndex],
                      autoFocus: false,
                      textCapitalization: TextCapitalization.sentences,
                      label: AppTranslations.of(context).text("name"),
                      errorMessage:
                          AppTranslations.of(context).text("error_text_empty"),
                      validating: (String text) {
                        if (_viewModel
                            .customFieldsNameControllers[customFieldIndex]
                            .text
                            .isEmpty) {
                          return false;
                        }

                        return true;
                      },
                      onSubmitted: (String text) {
                        _viewModel.customFieldsValueFocusNode[customFieldIndex]
                            .requestFocus();
                      },
                    ),
                    SizedBox(height: 16.0),
                    ChicTextField(
                      controller: _viewModel
                          .customFieldsValueControllers[customFieldIndex],
                      focus: _viewModel
                          .customFieldsValueFocusNode[customFieldIndex],
                      desktopFocus: _viewModel
                          .customFieldsValueDesktopFocusNode[customFieldIndex],
                      autoFocus: false,
                      textCapitalization: TextCapitalization.sentences,
                      label: AppTranslations.of(context).text("value"),
                      errorMessage:
                          AppTranslations.of(context).text("error_text_empty"),
                      validating: (String text) {
                        if (_viewModel
                            .customFieldsValueControllers[customFieldIndex]
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
                    _viewModel.onRemoveCustomField(customFieldIndex);
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

    for (var tagIndex = 0;
        tagIndex < _viewModel.tagLabelList.length;
        tagIndex++) {
      chips.add(
        TagChip(
          name: _viewModel.tagLabelList[tagIndex],
          index: tagIndex,
          onDelete: (int index) {
            _viewModel.tagLabelList.removeAt(tagIndex);
            setState(() {});
          },
        ),
      );
    }

    return chips;
  }

  _selectCategory() async {
    _viewModel.selectCategory(context);
  }

  _createCategory() async {
    _viewModel.createCategory(context);
  }

  _generateNewPassword() async {
    _viewModel.generateNewPassword(context);
  }

  _save() async {
    _viewModel.save(context, _synchronizationProvider);
  }

  @override
  void dispose() {
    _viewModel.nameController.dispose();
    _viewModel.usernameController.dispose();
    _viewModel.passwordController.dispose();
    _viewModel.categoryController.dispose();
    _viewModel.tagController.dispose();
    _viewModel.commentController.dispose();

    for (var customFieldsNameController
        in _viewModel.customFieldsNameControllers) {
      customFieldsNameController.dispose();
    }

    for (var customFieldsValueController
        in _viewModel.customFieldsValueControllers) {
      customFieldsValueController.dispose();
    }

    _nameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _categoryFocusNode.dispose();
    _tagFocusNode.dispose();
    _commentFocusNode.dispose();

    for (var customFieldsNameFocusNode
        in _viewModel.customFieldsNameFocusNode) {
      customFieldsNameFocusNode.dispose();
    }

    for (var customFieldsValueFocusNode
        in _viewModel.customFieldsValueFocusNode) {
      customFieldsValueFocusNode.dispose();
    }

    _desktopNameFocusNode.dispose();
    _desktopUsernameFocusNode.dispose();
    _desktopPasswordFocusNode.dispose();
    _desktopCategoryFocusNode.dispose();
    _desktopCommentFocusNode.dispose();

    for (var customFieldsNameDesktopFocusNode
        in _viewModel.customFieldsNameDesktopFocusNode) {
      customFieldsNameDesktopFocusNode.dispose();
    }

    for (var customFieldsValueDesktopFocusNode
        in _viewModel.customFieldsValueDesktopFocusNode) {
      customFieldsValueDesktopFocusNode.dispose();
    }

    _scrollController.dispose();
    super.dispose();
  }
}

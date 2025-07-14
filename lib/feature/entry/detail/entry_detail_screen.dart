import 'dart:io';

import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/component/entry_detail_input.dart';
import 'package:chic_secret/component/entry_item.dart';
import 'package:chic_secret/component/tag_chip.dart';
import 'package:chic_secret/feature/entry/detail/entry_detail_screen_view_model.dart';
import 'package:chic_secret/feature/entry/new/new_entry_screen.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/date_render.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:chic_secret/utils/shared_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryDetailScreen extends StatefulWidget {
  final Entry entry;
  final Function(Entry)? onEntryEdit;
  final Function()? onEntryDeleted;
  final Function(Entry entry)? onEntrySelected;
  final String previousPageTitle;

  EntryDetailScreen({
    required this.entry,
    this.onEntryEdit,
    this.onEntryDeleted,
    this.onEntrySelected,
    required this.previousPageTitle,
  });

  @override
  _EntryDetailScreenState createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  late EntryDetailScreenViewModel _viewModel;

  @override
  void initState() {
    _viewModel = EntryDetailScreenViewModel(
      widget.entry,
      widget.onEntryDeleted,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (widget.entry.id != _viewModel.currentEntry.id) {
      if (_viewModel.passwordEntryDetailController.hidePassword != null) {
        _viewModel.passwordEntryDetailController.hidePassword!();
      }

      _viewModel.reload(widget.entry);
    }

    return ChangeNotifierProvider<EntryDetailScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<EntryDetailScreenViewModel>(
        builder: (context, value, _) {
          if (Platform.isIOS) {
            return CupertinoPageScaffold(
              backgroundColor: themeProvider.backgroundColor,
              navigationBar: _displaysIosAppbar(themeProvider),
              child: _displaysBody(themeProvider),
            );
          } else {
            return Scaffold(
              backgroundColor: themeProvider.backgroundColor,
              appBar: _displaysAppbar(themeProvider),
              body: _displaysBody(themeProvider),
            );
          }
        },
      ),
    );
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: widget.previousPageTitle,
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(widget.entry.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.pen,
            ),
            onPressed: _onEditButtonClicked,
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.delete,
              color: Colors.red,
            ),
            onPressed: _onDeleteButtonClicked,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        scrolledUnderElevation: 0,
        title: Text(widget.entry.name),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: themeProvider.textColor,
            ),
            onPressed: _onEditButtonClicked,
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: themeProvider.textColor,
            ),
            onPressed: _onDeleteButtonClicked,
          ),
        ],
      );
    } else {
      return null;
    }
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    var password = "";

    try {
      password = Security.decrypt(currentPassword!, widget.entry.hash);
    } catch (e) {
      print(e);
    }

    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: themeProvider.secondBackgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: themeProvider.secondTextColor,
                              size: 12,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              child: Text(
                                DateRender.displaysDate(
                                    context, widget.entry.updatedAt),
                                style: TextStyle(
                                  color: themeProvider.secondTextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ChicPlatform.isDesktop()
                            ? EntryDetailInput(
                                label: AppTranslations.of(context)
                                    .text("name_not_mandatory"),
                                text: widget.entry.name,
                              )
                            : SizedBox.shrink(),
                        ChicPlatform.isDesktop()
                            ? SizedBox(height: 24)
                            : SizedBox.shrink(),
                        EntryDetailInput(
                          label: AppTranslations.of(context).text("username"),
                          text: widget.entry.username,
                          canCopy: true,
                        ),
                        SizedBox(height: 24),
                        EntryDetailInput(
                          entryDetailInputController:
                              _viewModel.passwordEntryDetailController,
                          label: AppTranslations.of(context)
                              .text("password_not_mandatory"),
                          text: password,
                          canCopy: true,
                          isPassword: true,
                        ),
                        SizedBox(height: 24),
                        EntryDetailInput(
                          label: AppTranslations.of(context).text("category"),
                          text: widget.entry.category != null
                              ? widget.entry.category!.name
                              : "",
                        ),
                        _displaysTags(themeProvider),
                        _displaysCustomFields(),
                        _displaysComment(),
                      ],
                    ),
                  ),
                  _displayDuplicatedEntries(themeProvider),
                ],
              ),
            ),
          ),
        ),
        ChicPlatform.isDesktop()
            ? Container(
                margin: EdgeInsets.only(right: 8, top: 16),
                child: _displaysDesktopToolbar(themeProvider),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  Widget _displaysDesktopToolbar(ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(left: 8, bottom: 8),
          child: ChicTextIconButton(
            onPressed: _onEditButtonClicked,
            icon: Icon(
              Icons.edit,
              color: themeProvider.textColor,
              size: 20,
            ),
            label: Text(
              AppTranslations.of(context).text("edit"),
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
            onPressed: _onDeleteButtonClicked,
            icon: Icon(
              Icons.delete,
              color: themeProvider.textColor,
              size: 20,
            ),
            label: Text(
              AppTranslations.of(context).text("delete"),
              style: TextStyle(color: themeProvider.textColor),
            ),
            backgroundColor: Colors.red,
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

  Widget _displaysComment() {
    if (widget.entry.comment != null && widget.entry.comment!.isNotEmpty) {
      return Column(
        children: [
          SizedBox(height: 24),
          EntryDetailInput(
            label: AppTranslations.of(context).text("comment"),
            text: widget.entry.comment,
          ),
        ],
      );
    }

    return SizedBox.shrink();
  }

  Widget _displaysCustomFields() {
    if (_viewModel.customFields.isEmpty) {
      return SizedBox.shrink();
    }

    List<Widget> customFields = [];

    for (var customField in _viewModel.customFields) {
      customFields.add(
        EntryDetailInput(
          label: customField.name,
          text: customField.value,
        ),
      );

      if (customField != _viewModel.customFields.last) {
        customFields.add(SizedBox(height: 24));
      }
    }

    return Column(
      children: [
        SizedBox(height: 16),
        EntryDetailInput(
          label: AppTranslations.of(context).text("custom_fields"),
        ),
        SizedBox(height: 24),
        Column(
          children: customFields,
        ),
      ],
    );
  }

  Widget _displaysTags(ThemeProvider themeProvider) {
    if (_viewModel.tags.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 24),
        EntryDetailInput(
          label: AppTranslations.of(context).text("tags"),
          child: Container(
            margin: EdgeInsets.only(top: 8),
            child: Wrap(
              children: _createChipsList(themeProvider),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _createChipsList(ThemeProvider themeProvider) {
    List<Widget> chips = [];

    for (var tagIndex = 0; tagIndex < _viewModel.tags.length; tagIndex++) {
      chips.add(
        TagChip(
          name: _viewModel.tags[tagIndex].name,
          index: tagIndex,
        ),
      );
    }

    return chips;
  }

  Widget _displayDuplicatedEntries(ThemeProvider themeProvider) {
    if (_viewModel.duplicatedEntries.isEmpty) {
      return SizedBox.shrink();
    } else {
      return Container(
        margin: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.of(context).text("duplicated"),
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _viewModel.duplicatedEntries.length,
              itemBuilder: (context, index) {
                return EntryItem(
                  entry: _viewModel.duplicatedEntries[index],
                  isSelected: false,
                  onTap: _onEntrySelected,
                );
              },
            )
          ],
        ),
      );
    }
  }

  _onEntrySelected(Entry entry) async {
    if (ChicPlatform.isDesktop() && widget.onEntryEdit != null) {
      if (widget.onEntrySelected != null) {
        widget.onEntrySelected!(entry);
      }
    } else {
      await ChicNavigator.push(
        context,
        EntryDetailScreen(
          entry: entry,
          previousPageTitle: widget.entry.name,
        ),
      );
    }

    _viewModel.checkPasswordSecurity();
  }

  _onEditButtonClicked() async {
    if (ChicPlatform.isDesktop() && widget.onEntryEdit != null) {
      widget.onEntryEdit!(widget.entry);
    } else {
      var entry = await ChicNavigator.push(
        context,
        NewEntryScreen(
          entry: widget.entry,
          previousPageTitle: "",
        ),
      );

      if (entry is Entry) {
        ChicNavigator.pushReplacement(
          context,
          EntryDetailScreen(
            entry: entry,
            previousPageTitle: widget.entry.name,
          ),
        );
      }
    }
  }

  _onDeleteButtonClicked() async {
    var isAlreadyInTrash = widget.entry.category!.isTrash;

    var result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppTranslations.of(context).text("warning")),
          content: Text(
            isAlreadyInTrash
                ? AppTranslations.of(context).textWithArgument(
                    "warning_message_delete_entry_definitely",
                    widget.entry.name)
                : AppTranslations.of(context).textWithArgument(
                    "warning_message_delete_entry", widget.entry.name),
          ),
          actions: [
            TextButton(
              child: Text(
                AppTranslations.of(context).text("cancel"),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                AppTranslations.of(context).text("delete"),
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result != null && result) {
      _viewModel.onDeleteEntry(context, isAlreadyInTrash);
    }
  }
}

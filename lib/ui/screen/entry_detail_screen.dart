import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/service/entry_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/ui/component/common/chic_navigator.dart';
import 'package:chic_secret/ui/component/common/chic_text_icon_button.dart';
import 'package:chic_secret/ui/component/entry_detail_input.dart';
import 'package:chic_secret/ui/component/entry_item.dart';
import 'package:chic_secret/ui/component/tag_chip.dart';
import 'package:chic_secret/ui/screen/new_entry_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/date_render.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryDetailScreen extends StatefulWidget {
  final Entry entry;
  final Function(Entry)? onEntryEdit;
  final Function()? onEntryDeleted;
  final Function(Entry entry)? onEntrySelected;

  EntryDetailScreen({
    required this.entry,
    this.onEntryEdit,
    this.onEntryDeleted,
    this.onEntrySelected,
  });

  @override
  _EntryDetailScreenState createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  List<Entry> _duplicatedEntries = [];

  late Entry _oldEntry;
  List<Tag> _tags = [];
  List<CustomField> _customFields = [];
  EntryDetailInputController _passwordEntryDetailController =
      EntryDetailInputController();

  @override
  void initState() {
    _oldEntry = widget.entry;

    _checkPasswordSecurity();
    _loadTags();
    _loadCustomFields();
    super.initState();
  }

  _checkPasswordSecurity() async {
    var entries = await EntryService.findDuplicatedPasswords(
        selectedVault!.id, widget.entry.hash);

    _duplicatedEntries =
        entries.where((entry) => entry.id != widget.entry.id).toList();

    setState(() {});
  }

  _loadTags() async {
    _tags = await TagService.getAllByEntry(widget.entry.id);
    setState(() {});
  }

  _loadCustomFields() async {
    _customFields = await CustomFieldService.getAllByEntry(widget.entry.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    // Reload tags and custom fields if the entry changed (mainly for desktop usage)
    if (widget.entry.id != _oldEntry.id) {
      if (_passwordEntryDetailController.hidePassword != null) {
        _passwordEntryDetailController.hidePassword!();
      }

      _oldEntry = widget.entry;
      _checkPasswordSecurity();
      _loadTags();
      _loadCustomFields();
    }

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: _displaysAppbar(themeProvider),
      body: _displaysBody(themeProvider),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
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
                              _passwordEntryDetailController,
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
    if (_customFields.isEmpty) {
      return SizedBox.shrink();
    }

    List<Widget> customFields = [];

    for (var customField in _customFields) {
      customFields.add(
        EntryDetailInput(
          label: customField.name,
          text: customField.value,
        ),
      );

      if (customField != _customFields.last) {
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
    if (_tags.isEmpty) {
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

    for (var tagIndex = 0; tagIndex < _tags.length; tagIndex++) {
      chips.add(
        TagChip(
          name: _tags[tagIndex].name,
          index: tagIndex,
        ),
      );
    }

    return chips;
  }

  Widget _displayDuplicatedEntries(ThemeProvider themeProvider) {
    if (_duplicatedEntries.isEmpty) {
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
              itemCount: _duplicatedEntries.length,
              itemBuilder: (context, index) {
                return EntryItem(
                  entry: _duplicatedEntries[index],
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
      await ChicNavigator.push(context, EntryDetailScreen(entry: entry));
    }

    _checkPasswordSecurity();
  }

  _onEditButtonClicked() async {
    if (ChicPlatform.isDesktop() && widget.onEntryEdit != null) {
      widget.onEntryEdit!(widget.entry);
    } else {
      var entry = await ChicNavigator.push(
          context, NewEntryScreen(entry: widget.entry));

      if (entry is Entry) {
        ChicNavigator.pushReplacement(context, EntryDetailScreen(entry: entry));
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
      if (!isAlreadyInTrash) {
        // We move the entry to the trash bin
        await EntryService.moveToTrash(widget.entry);
      } else {
        // We delete it definitely
        await EntryService.deleteDefinitively(widget.entry);
      }

      if (ChicPlatform.isDesktop()) {
        if (widget.onEntryDeleted != null) {
          widget.onEntryDeleted!();
        }
      } else {
        Navigator.pop(context);
      }
    }
  }
}

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/model/database/custom_field.dart';
import 'package:chic_secret/model/database/entry.dart';
import 'package:chic_secret/model/database/tag.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/custom_field_service.dart';
import 'package:chic_secret/service/tag_service.dart';
import 'package:chic_secret/ui/component/entry_detail_input.dart';
import 'package:chic_secret/ui/component/tag_chip.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryDetailScreen extends StatefulWidget {
  final Entry entry;

  EntryDetailScreen({
    required this.entry,
  });

  @override
  _EntryDetailScreenState createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  late Entry _oldEntry;
  List<Tag> _tags = [];
  List<CustomField> _customFields = [];

  @override
  void initState() {
    _oldEntry = widget.entry;

    _loadTags();
    _loadCustomFields();
    super.initState();
  }

  /// Load the tags related to the entry
  _loadTags() async {
    _tags = await TagService.getAllByEntry(widget.entry.id);
    setState(() {});
  }

  /// Load the custom fields related to the entry
  _loadCustomFields() async {
    _customFields = await CustomFieldService.getAllByEntry(widget.entry.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    // Reload tags and custom fields if the entry changed (mainly for desktop usage)
    if (widget.entry.id != _oldEntry.id) {
      _oldEntry = widget.entry;
      _loadTags();
      _loadCustomFields();
    }

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: _displaysAppbar(themeProvider),
      body: ChicPlatform.isDesktop()
          ? _displaysBody(themeProvider)
          : _displaysBody(themeProvider),
    );
  }

  /// Displays the appbar that is only appearing on the mobile version
  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    if (!ChicPlatform.isDesktop()) {
      return AppBar(
        backgroundColor: themeProvider.secondBackgroundColor,
        brightness: themeProvider.getBrightness(),
        title: Text(widget.entry.name),
        actions: [],
      );
    } else {
      return null;
    }
  }

  /// Displays the body of the screen
  Widget _displaysBody(ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Container(
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
                ChicPlatform.isDesktop()
                    ? EntryDetailInput(
                        label: AppTranslations.of(context).text("name"),
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
                  label: AppTranslations.of(context).text("password"),
                  text: Security.decrypt(currentPassword!, widget.entry.hash),
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
        ),
      ),
    );
  }

  /// Displays a comment if it exists
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

  /// Displays the custom fields if they exist
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

  /// Displays tags if they exist
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

  /// Displays the list of tags
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
}
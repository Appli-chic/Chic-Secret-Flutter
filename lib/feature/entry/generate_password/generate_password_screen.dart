import 'dart:io';

import 'package:chic_secret/component/common/chic_elevated_button.dart';
import 'package:chic_secret/component/common/chic_icon_button.dart';
import 'package:chic_secret/component/common/chic_navigator.dart';
import 'package:chic_secret/component/common/chic_text_button.dart';
import 'package:chic_secret/component/common/chic_text_field.dart';
import 'package:chic_secret/component/common/desktop_modal.dart';
import 'package:chic_secret/feature/entry/generate_password/generate_password_screen_view_model.dart';
import 'package:chic_secret/feature/entry/generate_password/language/select_language_screen.dart';
import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeneratePasswordScreen extends StatefulWidget {
  final String previousPageTitle;

  GeneratePasswordScreen({
    required this.previousPageTitle,
  });

  @override
  _GeneratePasswordScreenState createState() => _GeneratePasswordScreenState();
}

class _GeneratePasswordScreenState extends State<GeneratePasswordScreen>
    with TickerProviderStateMixin {
  late GeneratePasswordScreenViewModel _viewModel;

  var _passwordFocusNode = FocusNode();
  var _languageFocusNode = FocusNode();
  var _desktopPasswordFocusNode = FocusNode();
  var _desktopLanguageFocusNode = FocusNode();

  @override
  void initState() {
    final tabController = TabController(length: 2, vsync: this);
    _viewModel = GeneratePasswordScreenViewModel(tabController);
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

    return ChangeNotifierProvider<GeneratePasswordScreenViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<GeneratePasswordScreenViewModel>(
        builder: (context, value, _) {
          if (ChicPlatform.isDesktop()) {
            return _displaysDesktopInModal(themeProvider);
          } else {
            return _displaysMobile(themeProvider);
          }
        },
      ),
    );
  }

  Widget _displaysDesktopInModal(ThemeProvider themeProvider) {
    return DesktopModal(
      title: AppTranslations.of(context).text("generate_password"),
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
              Navigator.of(context).pop(_viewModel.passwordController.text);
            },
          ),
        ),
      ],
    );
  }

  Widget _displaysMobile(ThemeProvider themeProvider) {
    var child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        child: _displaysBody(themeProvider),
      ),
    );

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: themeProvider.backgroundColor,
        navigationBar: _displaysIosAppbar(themeProvider),
        child: child,
      );
    } else {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: _displaysAppbar(themeProvider),
        body: child,
      );
    }
  }

  ObstructingPreferredSizeWidget _displaysIosAppbar(
      ThemeProvider themeProvider) {
    return CupertinoNavigationBar(
      previousPageTitle: widget.previousPageTitle,
      backgroundColor: themeProvider.secondBackgroundColor,
      middle: Text(AppTranslations.of(context).text("generate_password")),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          AppTranslations.of(context).text("done"),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          Navigator.of(context).pop(_viewModel.passwordController.text);
        },
      ),
    );
  }

  PreferredSizeWidget? _displaysAppbar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.secondBackgroundColor,
      title: Text(AppTranslations.of(context).text("generate_password")),
      actions: [
        ChicTextButton(
          child: Text(AppTranslations.of(context).text("done")),
          onPressed: () {
            Navigator.of(context).pop(_viewModel.passwordController.text);
          },
        ),
      ],
      bottom: _displayTabBar(themeProvider),
    );
  }

  Widget _displaysBody(ThemeProvider themeProvider) {
    String words = AppTranslations.of(context).text("words");
    String characters = AppTranslations.of(context).text("characters");
    int passwordSize = _viewModel.passwordController.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Platform.isIOS ? _displaySegment(themeProvider) : SizedBox.shrink(),
        Container(
          margin: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChicPlatform.isDesktop()
                  ? _displayTabBar(themeProvider)
                  : SizedBox.shrink(),
              ChicPlatform.isDesktop()
                  ? SizedBox(height: 16.0)
                  : SizedBox.shrink(),
              ChicTextField(
                controller: _viewModel.passwordController,
                focus: _passwordFocusNode,
                desktopFocus: _desktopPasswordFocusNode,
                label: "",
                isReadOnly: true,
                hasStrengthIndicator: true,
                maxLines: null,
                suffix: Container(
                  margin: EdgeInsets.only(right: 8),
                  child: ChicIconButton(
                    icon: Platform.isIOS
                        ? CupertinoIcons.arrow_clockwise
                        : Icons.refresh,
                    color: themeProvider.primaryColor,
                    onPressed: _viewModel.onGeneratePassword,
                  ),
                ),
              ),
              SizedBox(height: 32.0),
              Text(
                _viewModel.isGeneratingWords
                    ? "$words ($passwordSize $characters)"
                    : characters,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Slider.adaptive(
                      value: _viewModel.numberWords,
                      min: _viewModel.minWords,
                      max: _viewModel.maxWords,
                      divisions: _viewModel.divisionWords,
                      activeColor: themeProvider.primaryColor,
                      onChanged: _viewModel.onAmountWordsChanged,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 16),
                    child: Text(
                      "${_viewModel.numberWords.ceil()}",
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.0),
              Text(
                AppTranslations.of(context).text("settings"),
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppTranslations.of(context).text("uppercase"),
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _viewModel.hasUppercase,
                    activeColor: themeProvider.primaryColor,
                    onChanged: _viewModel.onUppercaseSwitchChanged,
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppTranslations.of(context).text("digit"),
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _viewModel.hasNumbers,
                    activeColor: themeProvider.primaryColor,
                    onChanged: _viewModel.onDigitSwitchChanged,
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppTranslations.of(context).text("symbol"),
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _viewModel.hasSpecialCharacters,
                    activeColor: themeProvider.primaryColor,
                    onChanged: _viewModel.onSpecialCharacterSwitchChanged,
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ChicTextField(
                controller: _viewModel.languageController,
                focus: _languageFocusNode,
                desktopFocus: _desktopLanguageFocusNode,
                isReadOnly: true,
                label: AppTranslations.of(context).text("language"),
                onTap: _selectLanguage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _displaySegment(ThemeProvider themeProvider) {
    return Container(
      width: double.maxFinite,
      color: themeProvider.secondBackgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: _viewModel.segmentedControlIndex,
        onValueChanged: _viewModel.onSegmentedControlChanged,
        children: {
          0: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppTranslations.of(context).text("words"),
              style: TextStyle(color: themeProvider.textColor),
            ),
          ),
          1: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppTranslations.of(context).text("characters"),
              style: TextStyle(color: themeProvider.textColor),
            ),
          ),
        },
      ),
    );
  }

  PreferredSizeWidget _displayTabBar(ThemeProvider themeProvider) {
    return TabBar(
      controller: _viewModel.tabController,
      indicatorColor: themeProvider.primaryColor,
      onTap: _viewModel.onTabBarItemTapped,
      tabs: <Widget>[
        Tab(
          text: AppTranslations.of(context).text("words"),
        ),
        Tab(
          text: AppTranslations.of(context).text("characters"),
        ),
      ],
    );
  }

  _selectLanguage() async {
    String? language = await ChicNavigator.push(
      context,
      SelectLanguageScreen(
        language: _viewModel.locale?.languageCode,
      ),
      isModal: true,
    );

    if (language != null) {
      _viewModel.setLanguage(language);
    }
  }

  @override
  void dispose() {
    _viewModel.passwordController.dispose();
    _viewModel.languageController.dispose();

    _passwordFocusNode.dispose();
    _languageFocusNode.dispose();

    _desktopPasswordFocusNode.dispose();
    _desktopLanguageFocusNode.dispose();

    super.dispose();
  }
}

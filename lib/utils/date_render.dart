import 'package:chic_secret/localization/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateRender {

  /// Displays the date corresponding to how old it is and within the
  /// current locale.
  static String displaysDate(BuildContext context, DateTime date) {
    var locale = AppTranslations.of(context).locale;
    var today = DateTime.now();

    if(today.difference(date).inDays < 1) {
      // Display time difference
      return timeago.format(date, locale: locale.languageCode);
    }

    return DateFormat.yMMMd(locale.languageCode).format(DateTime.now());
  }
}
import 'package:chic_secret/utils/database.dart';
import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';

const String userTable = "user";
const String columnUserEmail = "email";
const String columnUserIsSubscribed = "isSubscribed";
const String columnUserSubscription = "subscription";
const String columnUserSubscriptionStartDate = "subscriptionStartDate";
const String columnUserSubscriptionEndDate = "subscriptionEndDate";

class User {
  String id;
  String email;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
  bool? isSubscribed;
  String? subscription;
  DateTime? subscriptionStartDate;
  DateTime? subscriptionEndDate;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isSubscribed,
    this.subscription,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var createdAtString = DateTime.parse(json['CreatedAt']);
    var updatedAtString = DateTime.parse(json['UpdatedAt']);
    var deletedAtString;
    var subscriptionStartDateString;
    var subscriptionEndDateString;

    if (json['DeletedAt'] != null) {
      deletedAtString = DateTime.parse(json['DeletedAt']);
    }

    if (json['SubscriptionStartDate'] != null) {
      subscriptionStartDateString =
          DateTime.parse(json['SubscriptionStartDate']);
    }

    if (json['SubscriptionEndDate'] != null) {
      subscriptionEndDateString = DateTime.parse(json['SubscriptionEndDate']);
    }

    return User(
      id: json['ID'],
      email: json['Email'],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
      isSubscribed: json['IsSubscribed'],
      subscription: json['Subscription'],
      subscriptionStartDate: subscriptionStartDateString,
      subscriptionEndDate: subscriptionEndDateString,
    );
  }

  Map<String, dynamic> toJson() {
    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String createdAtString = dateFormatter.format(createdAt);
    String updatedAtString = dateFormatter.format(updatedAt);
    String? deletedAtString;
    String? subscriptionStartDateString;
    String? subscriptionEndDateString;

    if (deletedAt != null) {
      deletedAtString = dateFormatter.format(deletedAt!);
    }

    if (subscriptionStartDate != null) {
      subscriptionStartDateString =
          dateFormatter.format(subscriptionStartDate!);
    }

    if (subscriptionEndDate != null) {
      subscriptionEndDateString = dateFormatter.format(subscriptionEndDate!);
    }

    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = id;
    data['Email'] = email;
    data['CreatedAt'] = createdAtString;
    data['UpdatedAt'] = updatedAtString;
    data['DeletedAt'] = deletedAtString;
    data['IsSubscribed'] = isSubscribed;
    data['Subscription'] = subscription;
    data['SubscriptionStartDate'] = subscriptionStartDateString;
    data['SubscriptionEndDate'] = subscriptionEndDateString;

    return data;
  }

  factory User.fromMap(Map<String, dynamic> data) {
    var createdAtString = DateTime.parse(data[columnCreatedAt]);
    var updatedAtString = DateTime.parse(data[columnUpdatedAt]);
    var deletedAtString;
    var subscriptionStartDateString;
    var subscriptionEndDateString;

    if (data[columnDeletedAt] != null) {
      deletedAtString = DateTime.parse(data[columnDeletedAt]);
    }

    if (data[columnUserSubscriptionStartDate] != null) {
      subscriptionStartDateString =
          DateTime.parse(data[columnUserSubscriptionStartDate]);
    }

    if (data[columnUserSubscriptionEndDate] != null) {
      subscriptionEndDateString =
          DateTime.parse(data[columnUserSubscriptionEndDate]);
    }

    return User(
      id: data[columnId],
      email: data[columnUserEmail],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
      isSubscribed: data[columnUserIsSubscribed] != null
          ? transformIntToBool(data[columnUserIsSubscribed])
          : null,
      subscription: data[columnUserSubscription],
      subscriptionStartDate: subscriptionStartDateString,
      subscriptionEndDate: subscriptionEndDateString,
    );
  }

  // Transform an user into a map of data
  Map<String, dynamic> toMap() {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String createdAtString = dateFormatter.format(createdAt);
    String updatedAtString = dateFormatter.format(updatedAt);
    String? deletedAtString;
    String? subscriptionStartDateString;
    String? subscriptionEndDateString;
    int isSubscribedInt = 0;

    if (deletedAt != null) {
      deletedAtString = dateFormatter.format(deletedAt!);
    }

    if (subscriptionStartDate != null) {
      subscriptionStartDateString =
          dateFormatter.format(subscriptionStartDate!);
    }

    if (subscriptionEndDate != null) {
      subscriptionEndDateString = dateFormatter.format(subscriptionEndDate!);
    }

    if (isSubscribed != null) {
      isSubscribedInt = isSubscribed! ? 1 : 0;
    }

    return {
      columnId: id,
      columnUserEmail: email,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
      columnUserIsSubscribed: isSubscribedInt,
      columnUserSubscription: subscription,
      columnUserSubscriptionStartDate: subscriptionStartDateString,
      columnUserSubscriptionEndDate: subscriptionEndDateString,
    };
  }
}

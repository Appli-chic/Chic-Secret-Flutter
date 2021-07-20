import 'package:chic_secret/utils/database_structure.dart';
import 'package:intl/intl.dart';

const String userTable = "user";
const String columnUserEmail = "email";
const String columnUserIsSubscribed = "isSubscribed";
const String columnUserSubscription = "subscription";

class User {
  String id;
  String email;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
  bool? isSubscribed;
  String? subscription;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isSubscribed,
    this.subscription,
  });

  /// Transform a json to a user
  factory User.fromJson(Map<String, dynamic> json) {
    var createdAtString = DateTime.parse(json['CreatedAt']);
    var updatedAtString = DateTime.parse(json['UpdatedAt']);
    var deletedAtString;

    if (json['DeletedAt'] != null) {
      deletedAtString = DateTime.parse(json['DeletedAt']);
    }

    return User(
      id: json['ID'],
      email: json['Email'],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
      isSubscribed: json['IsSubscribed'],
      subscription: json['Subscription'],
    );
  }

  /// Transform a user to a json
  Map<String, dynamic> toJson() {
    var dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String createdAtString = dateFormatter.format(createdAt);
    String updatedAtString = dateFormatter.format(updatedAt);
    String? deletedAtString;

    if (deletedAt != null) {
      deletedAtString = dateFormatter.format(deletedAt!);
    }

    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.id;
    data['Email'] = this.email;
    data['CreatedAt'] = createdAtString;
    data['UpdatedAt'] = updatedAtString;
    data['DeletedAt'] = deletedAtString;
    data['IsSubscribed'] = isSubscribed;
    data['Subscription'] = subscription;

    return data;
  }

  /// Transform a map of [data] into an user
  factory User.fromMap(Map<String, dynamic> data) {
    var createdAtString = DateTime.parse(data[columnCreatedAt]);
    var updatedAtString = DateTime.parse(data[columnUpdatedAt]);
    var deletedAtString;

    if (data[columnDeletedAt] != null) {
      deletedAtString = DateTime.parse(data[columnDeletedAt]);
    }

    return User(
      id: data[columnId],
      email: data[columnUserEmail],
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      deletedAt: deletedAtString,
      isSubscribed: data[columnUserIsSubscribed],
      subscription: data[columnUserSubscription],
    );
  }

  // Transform an user into a map of data
  Map<String, dynamic> toMap() {
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String createdAtString = dateFormatter.format(createdAt);
    String updatedAtString = dateFormatter.format(updatedAt);
    String? deletedAtString;

    if (this.deletedAt != null) {
      deletedAtString = dateFormatter.format(deletedAt!);
    }

    return {
      columnId: id,
      columnUserEmail: email,
      columnCreatedAt: createdAtString,
      columnUpdatedAt: updatedAtString,
      columnDeletedAt: deletedAtString,
      columnUserIsSubscribed: isSubscribed,
      columnUserSubscription: subscription,
    };
  }
}

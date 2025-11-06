import 'package:json_annotation/json_annotation.dart';

part 'user_vo.g.dart';

@JsonSerializable()
class UserVO {
  final String id;
  final String username;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? lastLoginAt;
  final String createdAt;
  final AccountStatusVO accountStatus;
  final bool active;

  UserVO({
    required this.id,
    required this.username,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.lastLoginAt,
    required this.createdAt,
    required this.accountStatus,
    required this.active,
  });

  factory UserVO.fromJson(Map<String, dynamic> json) => _$UserVOFromJson(json);

  Map<String, dynamic> toJson() => _$UserVOToJson(this);
}

@JsonSerializable()
class AccountStatusVO {
  final String memberSince;
  final String lastActiveAgo;
  final bool notLocked;
  final bool verified;

  AccountStatusVO({
    required this.memberSince,
    required this.lastActiveAgo,
    required this.notLocked,
    required this.verified,
  });

  factory AccountStatusVO.fromJson(Map<String, dynamic> json) =>
      _$AccountStatusVOFromJson(json);

  Map<String, dynamic> toJson() => _$AccountStatusVOToJson(this);
}

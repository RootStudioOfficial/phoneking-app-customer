// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserVO _$UserVOFromJson(Map<String, dynamic> json) => UserVO(
  id: json['id'] as String,
  username: json['username'] as String,
  email: json['email'] as String?,
  displayName: json['displayName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  lastLoginAt: json['lastLoginAt'] as String?,
  createdAt: json['createdAt'] as String,
  accountStatus: AccountStatusVO.fromJson(
    json['accountStatus'] as Map<String, dynamic>,
  ),
  active: json['active'] as bool,
);

Map<String, dynamic> _$UserVOToJson(UserVO instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'displayName': instance.displayName,
  'phoneNumber': instance.phoneNumber,
  'lastLoginAt': instance.lastLoginAt,
  'createdAt': instance.createdAt,
  'accountStatus': instance.accountStatus,
  'active': instance.active,
};

AccountStatusVO _$AccountStatusVOFromJson(Map<String, dynamic> json) =>
    AccountStatusVO(
      memberSince: json['memberSince'] as String,
      lastActiveAgo: json['lastActiveAgo'] as String,
      notLocked: json['notLocked'] as bool,
      verified: json['verified'] as bool,
    );

Map<String, dynamic> _$AccountStatusVOToJson(AccountStatusVO instance) =>
    <String, dynamic>{
      'memberSince': instance.memberSince,
      'lastActiveAgo': instance.lastActiveAgo,
      'notLocked': instance.notLocked,
      'verified': instance.verified,
    };

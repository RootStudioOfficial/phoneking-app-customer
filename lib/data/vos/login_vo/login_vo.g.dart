// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginVO _$LoginVOFromJson(Map<String, dynamic> json) => LoginVO(
  id: json['id'] as String?,
  username: json['username'] as String?,
  email: json['email'] as String?,
  displayName: json['displayName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  lastLoginAt: json['lastLoginAt'] as String?,
  role: json['role'] == null
      ? null
      : RoleVO.fromJson(json['role'] as Map<String, dynamic>),
  active: json['active'] as bool?,
  deleted: json['deleted'] as bool?,
  notLocked: json['notLocked'] as bool?,
  referralCode: json['referralCode'] as String?,
);

Map<String, dynamic> _$LoginVOToJson(LoginVO instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'displayName': instance.displayName,
  'phoneNumber': instance.phoneNumber,
  'lastLoginAt': instance.lastLoginAt,
  'role': instance.role?.toJson(),
  'active': instance.active,
  'deleted': instance.deleted,
  'notLocked': instance.notLocked,
  'referralCode': instance.referralCode,
};

RoleVO _$RoleVOFromJson(Map<String, dynamic> json) => RoleVO(
  id: json['id'] as String?,
  roleName: json['roleName'] as String?,
  description: json['description'] as String?,
  menuList: (json['menuList'] as List<dynamic>?)
      ?.map((e) => MenuVO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RoleVOToJson(RoleVO instance) => <String, dynamic>{
  'id': instance.id,
  'roleName': instance.roleName,
  'description': instance.description,
  'menuList': instance.menuList,
};

MenuVO _$MenuVOFromJson(Map<String, dynamic> json) => MenuVO(
  id: json['id'] as String?,
  code: json['code'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$MenuVOToJson(MenuVO instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
};

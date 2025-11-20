import 'package:json_annotation/json_annotation.dart';

part 'login_vo.g.dart';

@JsonSerializable(explicitToJson: true)
class LoginVO {
  final String? id;
  final String? username;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? lastLoginAt;
  final RoleVO? role;
  final bool? active;
  final bool? deleted;
  final bool? notLocked;
  final String? referralCode;

  LoginVO({
    this.id,
    this.username,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.lastLoginAt,
    this.role,
    this.active,
    this.deleted,
    this.notLocked,
    this.referralCode,
  });

  factory LoginVO.fromJson(Map<String, dynamic> json) =>
      _$LoginVOFromJson(json);

  Map<String, dynamic> toJson() => _$LoginVOToJson(this);

  LoginVO copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? lastLoginAt,
    RoleVO? role,
    bool? active,
    bool? deleted,
    bool? notLocked,
    String? token,
    String? refreshToken,
  }) {
    return LoginVO(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      role: role ?? this.role,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      notLocked: notLocked ?? this.notLocked,
    );
  }
}

@JsonSerializable()
class RoleVO {
  final String? id;
  final String? roleName;
  final String? description;
  final List<MenuVO>? menuList;

  RoleVO({this.id, this.roleName, this.description, this.menuList});

  factory RoleVO.fromJson(Map<String, dynamic> json) => _$RoleVOFromJson(json);

  Map<String, dynamic> toJson() => _$RoleVOToJson(this);

  // ✅ copyWith method
  RoleVO copyWith({
    String? id,
    String? roleName,
    String? description,
    List<MenuVO>? menuList,
  }) {
    return RoleVO(
      id: id ?? this.id,
      roleName: roleName ?? this.roleName,
      description: description ?? this.description,
      menuList: menuList ?? this.menuList,
    );
  }
}

@JsonSerializable()
class MenuVO {
  final String? id;
  final String? code;
  final String? name;

  MenuVO({this.id, this.code, this.name});

  factory MenuVO.fromJson(Map<String, dynamic> json) => _$MenuVOFromJson(json);

  Map<String, dynamic> toJson() => _$MenuVOToJson(this);

  // ✅ copyWith method
  MenuVO copyWith({String? id, String? code, String? name}) {
    return MenuVO(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }
}

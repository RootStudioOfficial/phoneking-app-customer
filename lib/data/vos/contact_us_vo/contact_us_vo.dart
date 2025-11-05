import 'package:json_annotation/json_annotation.dart';

part 'contact_us_vo.g.dart';

@JsonSerializable()
class ContactUsVO {
  final String? createdAt;
  final String? updatedAt;
  final int? version;
  final String? id;
  final String? contactType;
  final String? contact;

  ContactUsVO({
    this.createdAt,
    this.updatedAt,
    this.version,
    this.id,
    this.contactType,
    this.contact,
  });

  factory ContactUsVO.fromJson(Map<String, dynamic> json) =>
      _$ContactUsVOFromJson(json);

  Map<String, dynamic> toJson() => _$ContactUsVOToJson(this);

  ContactUsVO copyWith({
    String? createdAt,
    String? updatedAt,
    int? version,
    String? id,
    String? contactType,
    String? contact,
  }) {
    return ContactUsVO(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      id: id ?? this.id,
      contactType: contactType ?? this.contactType,
      contact: contact ?? this.contact,
    );
  }
}

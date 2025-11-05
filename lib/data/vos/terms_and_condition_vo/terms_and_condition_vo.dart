import 'package:json_annotation/json_annotation.dart';

part 'terms_and_condition_vo.g.dart';

@JsonSerializable()
class TermsAndConditionVO {
  final String? id;
  final String? title;
  final String? description;

  TermsAndConditionVO({
    this.id,
    this.title,
    this.description,
  });

  factory TermsAndConditionVO.fromJson(Map<String, dynamic> json) =>
      _$TermsAndConditionVOFromJson(json);

  Map<String, dynamic> toJson() => _$TermsAndConditionVOToJson(this);

  TermsAndConditionVO copyWith({
    String? id,
    String? title,
    String? description,
  }) {
    return TermsAndConditionVO(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}

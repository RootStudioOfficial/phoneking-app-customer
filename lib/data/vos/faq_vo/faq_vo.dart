import 'package:json_annotation/json_annotation.dart';

part 'faq_vo.g.dart';

@JsonSerializable()
class FaqVO {
  final String? createdAt;
  final String? updatedAt;
  final int? version;
  final String? id;
  final String? question;
  final String? answer;

  FaqVO({
    this.createdAt,
    this.updatedAt,
    this.version,
    this.id,
    this.question,
    this.answer,
  });

  factory FaqVO.fromJson(Map<String, dynamic> json) => _$FaqVOFromJson(json);

  Map<String, dynamic> toJson() => _$FaqVOToJson(this);

  FaqVO copyWith({
    String? createdAt,
    String? updatedAt,
    int? version,
    String? id,
    String? question,
    String? answer,
  }) {
    return FaqVO(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }
}

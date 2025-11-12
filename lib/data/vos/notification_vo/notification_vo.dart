import 'package:json_annotation/json_annotation.dart';

part 'notification_vo.g.dart';

@JsonSerializable()
class NotificationVO {
  final List<NotificationContentVO> content;
  final PageableVO pageable;
  final int totalPages;
  final int totalElements;
  final bool last;
  final int numberOfElements;
  final int size;
  final int number;
  final SortVO sort;
  final bool first;
  final bool empty;

  NotificationVO({
    required this.content,
    required this.pageable,
    required this.totalPages,
    required this.totalElements,
    required this.last,
    required this.numberOfElements,
    required this.size,
    required this.number,
    required this.sort,
    required this.first,
    required this.empty,
  });

  factory NotificationVO.fromJson(Map<String, dynamic> json) =>
      _$NotificationVOFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationVOToJson(this);
}

@JsonSerializable()
class NotificationContentVO {
  final String id;
  final String title;
  final String body;
  final String? routeId;
  final String notificationType;
  final String localDateTime;
  final bool read;

  NotificationContentVO({
    required this.id,
    required this.title,
    required this.body,
    this.routeId,
    required this.notificationType,
    required this.localDateTime,
    required this.read,
  });

  factory NotificationContentVO.fromJson(Map<String, dynamic> json) =>
      _$NotificationContentVOFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationContentVOToJson(this);
}

@JsonSerializable()
class PageableVO {
  final int pageNumber;
  final int pageSize;
  final SortVO sort;
  final int offset;
  final bool unpaged;
  final bool paged;

  PageableVO({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.unpaged,
    required this.paged,
  });

  factory PageableVO.fromJson(Map<String, dynamic> json) =>
      _$PageableVOFromJson(json);

  Map<String, dynamic> toJson() => _$PageableVOToJson(this);
}

@JsonSerializable()
class SortVO {
  final bool unsorted;
  final bool sorted;
  final bool empty;

  SortVO({
    required this.unsorted,
    required this.sorted,
    required this.empty,
  });

  factory SortVO.fromJson(Map<String, dynamic> json) => _$SortVOFromJson(json);

  Map<String, dynamic> toJson() => _$SortVOToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationVO _$NotificationVOFromJson(Map<String, dynamic> json) =>
    NotificationVO(
      content: (json['content'] as List<dynamic>)
          .map((e) => NotificationContentVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageable: PageableVO.fromJson(json['pageable'] as Map<String, dynamic>),
      totalPages: (json['totalPages'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      last: json['last'] as bool,
      numberOfElements: (json['numberOfElements'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      sort: SortVO.fromJson(json['sort'] as Map<String, dynamic>),
      first: json['first'] as bool,
      empty: json['empty'] as bool,
    );

Map<String, dynamic> _$NotificationVOToJson(NotificationVO instance) =>
    <String, dynamic>{
      'content': instance.content,
      'pageable': instance.pageable,
      'totalPages': instance.totalPages,
      'totalElements': instance.totalElements,
      'last': instance.last,
      'numberOfElements': instance.numberOfElements,
      'size': instance.size,
      'number': instance.number,
      'sort': instance.sort,
      'first': instance.first,
      'empty': instance.empty,
    };

NotificationContentVO _$NotificationContentVOFromJson(
  Map<String, dynamic> json,
) => NotificationContentVO(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  routeId: json['routeId'] as String?,
  notificationType: json['notificationType'] as String,
  localDateTime: json['localDateTime'] as String,
  read: json['read'] as bool,
);

Map<String, dynamic> _$NotificationContentVOToJson(
  NotificationContentVO instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'routeId': instance.routeId,
  'notificationType': instance.notificationType,
  'localDateTime': instance.localDateTime,
  'read': instance.read,
};

PageableVO _$PageableVOFromJson(Map<String, dynamic> json) => PageableVO(
  pageNumber: (json['pageNumber'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  sort: SortVO.fromJson(json['sort'] as Map<String, dynamic>),
  offset: (json['offset'] as num).toInt(),
  unpaged: json['unpaged'] as bool,
  paged: json['paged'] as bool,
);

Map<String, dynamic> _$PageableVOToJson(PageableVO instance) =>
    <String, dynamic>{
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'sort': instance.sort,
      'offset': instance.offset,
      'unpaged': instance.unpaged,
      'paged': instance.paged,
    };

SortVO _$SortVOFromJson(Map<String, dynamic> json) => SortVO(
  unsorted: json['unsorted'] as bool,
  sorted: json['sorted'] as bool,
  empty: json['empty'] as bool,
);

Map<String, dynamic> _$SortVOToJson(SortVO instance) => <String, dynamic>{
  'unsorted': instance.unsorted,
  'sorted': instance.sorted,
  'empty': instance.empty,
};

import 'package:json_annotation/json_annotation.dart';

part 'get_balance_vo.g.dart';

@JsonSerializable()
class GetBalanceVO {
  final int totalBalance;

  GetBalanceVO({required this.totalBalance});

  factory GetBalanceVO.fromJson(Map<String,dynamic>json)=>_$GetBalanceVOFromJson(json);

  Map<String,dynamic>toJson()=>_$GetBalanceVOToJson(this);
}

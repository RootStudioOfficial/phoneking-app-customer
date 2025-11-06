import 'package:phone_king_customer/data/vos/get_balance_vo/get_balance_vo.dart';
import 'package:phone_king_customer/data/vos/history_vo/history_summary_vo/history_summary_vo.dart';
import 'package:phone_king_customer/data/vos/history_vo/history_vo.dart';
import 'package:phone_king_customer/data/vos/payment_success_vo/payment_success_vo.dart';
import 'package:phone_king_customer/data/vos/scan_payment_vo/scan_payment_vo.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

abstract class PhoneKingPointModel {
  Future<BaseResponse<GetBalanceVO>> getBalance();

  Future<BaseResponse<HistorySummaryVO>> getSummary(
    String fromDate,
    String toDate,
  );

  Future<BaseResponse<List<HistoryVO>>> getHistory(
    String fromDate,
    String toDate,
  );

  Future<BaseResponse<ScanPaymentVO>> scanPaymentQrInfo(String key);

  Future<BaseResponse<PaymentSuccessVO>> makePayment(
    String key,
    String password,
  );
}

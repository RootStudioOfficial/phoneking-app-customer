import 'package:phonekingcustomer/data/model/point/phone_king_point_model.dart';
import 'package:phonekingcustomer/data/vos/get_balance_vo/get_balance_vo.dart';
import 'package:phonekingcustomer/data/vos/history_vo/history_summary_vo/history_summary_vo.dart';
import 'package:phonekingcustomer/data/vos/history_vo/history_vo.dart';
import 'package:phonekingcustomer/data/vos/payment_success_vo/payment_success_vo.dart';
import 'package:phonekingcustomer/data/vos/scan_payment_vo/scan_payment_vo.dart';
import 'package:phonekingcustomer/network/api/phone_king_api.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';

class PhoneKingPointModelImpl implements PhoneKingPointModel {
  final PhoneKingCustomerAPI _api = PhoneKingCustomerAPI();

  @override
  Future<BaseResponse<GetBalanceVO>> getBalance() {
    return _api.getBalance();
  }

  @override
  Future<BaseResponse<List<HistoryVO>>> getHistory(
    String fromDate,
    String toDate,
  ) {
    return _api.getHistory(fromDate, toDate);
  }

  @override
  Future<BaseResponse<HistorySummaryVO>> getSummary(
    String fromDate,
    String toDate,
  ) {
    return _api.getSummary(fromDate, toDate);
  }

  @override
  Future<BaseResponse<PaymentSuccessVO>> makePayment(
    String key,
    String password,
  ) {
    return _api.makePayment(key, password);
  }

  @override
  Future<BaseResponse<ScanPaymentVO>> scanPaymentQrInfo(String key) {
    return _api.scanPaymentQrInfo(key);
  }
}

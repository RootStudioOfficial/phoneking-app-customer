import 'package:phonekingcustomer/data/model/notification/phone_king_notification_model.dart';
import 'package:phonekingcustomer/data/vos/notification_vo/notification_vo.dart';
import 'package:phonekingcustomer/network/api/phone_king_api.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';

class PhoneKingNotificationModelImpl implements PhoneKingNotificationModel {
  final PhoneKingCustomerAPI _api = PhoneKingCustomerAPI();

  @override
  Future<BaseResponse<NotificationVO>> getAllNotification(
    String size,
    String page,
  ) {
    return _api.getAllNotification(size, page);
  }

  @override
  Future<BaseResponse<void>> readAllNotification() {
    return _api.readAllNotification();
  }

  @override
  Future<BaseResponse<void>> readNotificationByID(String notificationID) {
    return _api.readNotificationByID(notificationID);
  }
}

import 'package:phone_king_customer/data/model/notification/phone_king_notification_model.dart';
import 'package:phone_king_customer/data/vos/notification_vo/notification_vo.dart';
import 'package:phone_king_customer/network/api/phone_king_api.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

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

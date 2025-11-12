import 'package:phone_king_customer/data/vos/notification_vo/notification_vo.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

abstract class PhoneKingNotificationModel {
  Future<BaseResponse<NotificationVO>> getAllNotification(
      String size,
      String page,
      );

  Future<BaseResponse<void>> readNotificationByID(String notificationID);

  Future<BaseResponse<void>> readAllNotification();
}

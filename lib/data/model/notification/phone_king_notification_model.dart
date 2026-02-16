import 'package:phonekingcustomer/data/vos/notification_vo/notification_vo.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';

abstract class PhoneKingNotificationModel {
  Future<BaseResponse<NotificationVO>> getAllNotification(
      String size,
      String page,
      );

  Future<BaseResponse<void>> readNotificationByID(String notificationID);

  Future<BaseResponse<void>> readAllNotification();
}



import 'package:phonekingcustomer/data/vos/app_update_config_vo/app_update_config_vo.dart';
import 'package:phonekingcustomer/data/vos/branches_vo/branches_vo.dart';
import 'package:phonekingcustomer/data/vos/contact_us_vo/contact_us_vo.dart';
import 'package:phonekingcustomer/data/vos/faq_vo/faq_vo.dart';
import 'package:phonekingcustomer/data/vos/terms_and_condition_vo/terms_and_condition_vo.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';

abstract class PhoneKingSupportModel {
  Future<BaseResponse<List<FaqVO>>> getSupportFaqs();
  Future<BaseResponse<List<ContactUsVO>>> getContactUs();
  Future<BaseResponse<List<BranchesVO>>> getSupportBranches();
  Future<BaseResponse<List<TermsAndConditionVO>>> getSupportTermsAndConditions();
  Future<BaseResponse<AppUpdateConfigVO>> checkVersion(
      String platform,
      int currentVersionCode,
      );
}

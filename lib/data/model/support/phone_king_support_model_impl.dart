import 'package:phone_king_customer/data/model/support/phone_king_support_model.dart';
import 'package:phone_king_customer/data/vos/branches_vo/branches_vo.dart';
import 'package:phone_king_customer/data/vos/contact_us_vo/contact_us_vo.dart';
import 'package:phone_king_customer/data/vos/faq_vo/faq_vo.dart';
import 'package:phone_king_customer/data/vos/terms_and_condition_vo/terms_and_condition_vo.dart';
import 'package:phone_king_customer/network/api/phone_king_api.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

class PhoneKingSupportModelImpl implements PhoneKingSupportModel {
  final PhoneKingCustomerAPI _api = PhoneKingCustomerAPI();

  @override
  Future<BaseResponse<List<FaqVO>>> getSupportFaqs() {
    return _api.getSupportFaqs();
  }

  @override
  Future<BaseResponse<List<ContactUsVO>>> getContactUs() {
    return _api.getContactUs();
  }

  @override
  Future<BaseResponse<List<BranchesVO>>> getSupportBranches() {
    return _api.getSupportBranches();
  }

  @override
  Future<BaseResponse<List<TermsAndConditionVO>>>
  getSupportTermsAndConditions() {
    return _api.getSupportTermsAndConditions();
  }
}

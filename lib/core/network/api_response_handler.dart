// import 'dart:convert';
// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../constants/app_image.dart';
// import '../constants/app_string.dart';
// import '../navigation_key/global_key.dart';
// import '../services/startup_service.dart';
// import '../utils/enum.dart';
// import '../utils/logger_util.dart';
// import '../utils/navigation_manager.dart';
// import '../utils/router.dart';
// import 'api_helper.dart';
// import 'api_result.dart';
// import 'api_result_constant.dart';
// import 'network_result.dart';
//
// final deviceInfo = DeviceInfoPlugin();
//
// APIResult<T> getAPIResultFromNetwork<T>(NetworkResult networkResult) {
//   switch (networkResult.networkResultType) {
//     case NetworkResultType.ERROR:
//       var baseJson = json.decode(networkResult.result!);
//       BaseResponseModelEntity baseResponseEntity =
//       BaseResponseModelEntity.fromJson(baseJson);
//       return APIResult.failure(baseResponseEntity.message);
//
//     case NetworkResultType.NO_INTERNET:
//       return APIResult.noInternet();
//
//     case NetworkResultType.UNAUTHORISED:
//       StartupService.remove();
//       navigateToPageAndRemoveAllPage(
//         GlobalVariable.navigatorKey.currentContext!,
//         LOGIN_ROUTE,
//       );
//       return APIResult.userUnauthorised();
//
//     case NetworkResultType.USER_DEACTIVE:
//       StartupService.remove();
//       navigateToPageAndRemoveAllPage(
//         GlobalVariable.navigatorKey.currentContext!,
//         LOGIN_ROUTE_FROM_API,
//       );
//       return APIResult.userDeactivate();
//
//     case NetworkResultType.USER_DELETED:
//       StartupService.remove();
//       navigateToPageAndRemoveAllPage(
//         GlobalVariable.navigatorKey.currentContext!,
//         LOGIN_ROUTE_FROM_API,
//       );
//       return APIResult.userDeleted();
//
//     case NetworkResultType.NOTFOUND:
//       _showNotFoundDailog(GlobalVariable.navigatorKey.currentContext!);
//       return APIResult.userDeleted();
//
//     case NetworkResultType.FORCE_UPDATE:
//       _showForceUpdateDailog(GlobalVariable.navigatorKey.currentContext!);
//       return APIResult.forceUpdate();
//
//     case NetworkResultType.UNDER_MAINTENANCE:
//       _showUnderMaintenance(GlobalVariable.navigatorKey.currentContext!);
//       return APIResult.underMaintenance();
//
//     case NetworkResultType.CACHEERROR:
//       return APIResult.failure(AppString.ERROR);
//
//     case NetworkResultType.SUCCESS:
//     default:
//       {
//         if (networkResult.result.isNullOrEmpty()) {
//           logger.w("user isNullOrEmpty");
//           return APIResult.failure("");
//         }
//         try {
//           var baseJson = json.decode(networkResult.result!);
//           BaseResponseModelEntity baseResponseEntity =
//           BaseResponseModelEntity.fromJson(baseJson);
//           if (baseResponseEntity.status == APIResultConstant.ERROR) {
//             logger.w("user ERROR");
//             return APIResult.failure(baseResponseEntity.message.orEmpty());
//           } else if (baseResponseEntity.status ==
//               APIResultConstant.USER_UNAUTHORISED) {
//             logger.w("user unautorized");
//             // navigateToPageAndRemoveAllPage(GlobalVariable.navigatorKey.currentContext!, LOGIN_ROUTE,);
//             return APIResult.userUnauthorised();
//           } else if (baseResponseEntity.status ==
//               APIResultConstant.USER_DELETED) {
//             logger.w("user USER_DELETED");
//             return APIResult.userDeleted();
//           } else {
//             if (baseResponseEntity.result != null) {
//               if (baseResponseEntity.result.runtimeType != String) {
//                 T? responseModel =
//                 JsonConvert.fromJsonAsT<T>(baseResponseEntity.result);
//                 return APIResult.success(
//                     baseResponseEntity.message?.orEmpty(), responseModel);
//               }
//               return APIResult.success(baseResponseEntity.message.orEmpty(),
//                   baseResponseEntity.result);
//             } else {
//               return APIResult.success(
//                   baseResponseEntity.message.orEmpty(), null);
//             }
//           }
//         } catch (e, s) {
//           logger.w("result failure catch");
//           FirebaseCrashlytics.instance.recordError(e, s);
//           return APIResult.failure(AppString.ERROR);
//         }
//       }
//   }
// }
//
// APIResult<T> getAPIResultFromNetworkWithoutBase<T>(
//     NetworkResult networkResult) {
//   switch (networkResult.networkResultType) {
//     case NetworkResultType.ERROR:
//       return APIResult.failure(AppString.ERROR);
//     case NetworkResultType.NO_INTERNET:
//       return APIResult.noInternet();
//
//     case NetworkResultType.UNAUTHORISED:
//       StartupService.remove();
//       navigateToPageAndRemoveAllPage(
//         GlobalVariable.navigatorKey.currentContext!,
//         LOGIN_ROUTE_FROM_API,
//       );
//       return APIResult.userUnauthorised();
//
//     case NetworkResultType.USER_DEACTIVE:
//       StartupService.remove();
//       navigateToPageAndRemoveAllPage(
//         GlobalVariable.navigatorKey.currentContext!,
//         LOGIN_ROUTE_FROM_API,
//       );
//       return APIResult.userDeactivate();
//
//     case NetworkResultType.USER_DELETED:
//       StartupService.remove();
//       navigateToPageAndRemoveAllPage(
//         GlobalVariable.navigatorKey.currentContext!,
//         LOGIN_ROUTE_FROM_API,
//       );
//       return APIResult.userDeleted();
//
//     case NetworkResultType.NOTFOUND:
//       _showNotFoundDailog(GlobalVariable.navigatorKey.currentContext!);
//       return APIResult.userDeleted();
//
//     case NetworkResultType.FORCE_UPDATE:
//       _showForceUpdateDailog(GlobalVariable.navigatorKey.currentContext!);
//       return APIResult.forceUpdate();
//
//     case NetworkResultType.UNDER_MAINTENANCE:
//       _showUnderMaintenance(GlobalVariable.navigatorKey.currentContext!);
//       return APIResult.underMaintenance();
//
//     case NetworkResultType.SUCCESS:
//     default:
//       {
//         if (networkResult.result.isNullOrEmpty()) {
//           return APIResult.failure("");
//         }
//         try {
//           if (networkResult.result != null) {
//             var baseJson = json.decode(networkResult.result!);
//             T? responseModel = JsonConvert.fromJsonAsT<T>(baseJson);
//             return APIResult.success(
//               "",
//               responseModel,
//             );
//           } else {
//             return APIResult.success("", null);
//           }
//         } catch (e, s) {
//           return APIResult.failure(e.toString());
//         }
//       }
//   }
// }
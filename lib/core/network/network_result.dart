import '../utils/enum.dart';

class NetworkResult {
  NetworkResultType networkResultType;
  String? result;

  NetworkResult._(this.networkResultType, this.result);

  static NetworkResult noInternet() {
    return NetworkResult._(NetworkResultType.NO_INTERNET, null);
  }

  static NetworkResult success(String data) {
    return NetworkResult._(NetworkResultType.SUCCESS, data);
  }

  static NetworkResult error(String data) {
    return NetworkResult._(NetworkResultType.ERROR, data);
  }

  static NetworkResult cacheError() {
    return NetworkResult._(NetworkResultType.CACHEERROR, null);
  }

  static NetworkResult unAuthorised() {
    return NetworkResult._(NetworkResultType.UNAUTHORISED, null);
  }

  static NetworkResult notFound() {
    return NetworkResult._(NetworkResultType.NOTFOUND, null);
  }

  static NetworkResult userDeleted() {
    return NetworkResult._(NetworkResultType.USER_DELETED, null);
  }

  static NetworkResult userDeactivate() {
    return NetworkResult._(NetworkResultType.USER_DEACTIVE, null);
  }

  static NetworkResult forceUpdate() {
    return NetworkResult._(NetworkResultType.FORCE_UPDATE, null);
  }

  static NetworkResult underMaintenance() {
    return NetworkResult._(NetworkResultType.UNDER_MAINTENANCE, null);
  }



  @override
  String toString() {
    return 'NetworkResult{networkResultType: $networkResultType, data: $result}';
  }
}

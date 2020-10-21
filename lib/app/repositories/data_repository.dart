import 'package:covtrack2/app/repositories/endpoints_data.dart';
import 'package:covtrack2/app/services/api.dart';
import 'package:covtrack2/app/services/api_service.dart';
import 'package:covtrack2/app/services/data_cache_service.dart';
import 'package:covtrack2/app/services/endpoint_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class DataRepository {
  DataRepository({@required this.apiService, @required this.dataCacheService});
  final APIService apiService;
  final DataCacheService dataCacheService;

  String _accessToken;

  Future<T> _getDataRefreshingToken<T>(
      {@required Future<T> Function() onGetData}) async {
    try {
      if (_accessToken == null)
        _accessToken = await apiService.getAccessToken();

      return await onGetData();
    } on Response catch (response) {
      // if token expired
      if (response.statusCode == 401) {
        _accessToken = await apiService.getAccessToken();
        return await onGetData();
      }
      rethrow;
    }
  }

  Future<EndpointData> getEndpointData(Endpoint endpoint) async =>
      await _getDataRefreshingToken<EndpointData>(
        onGetData: () => apiService.getEndpointData(
            accessToken: _accessToken, endpoint: endpoint),
      );

  EndpointsData getAllEnpointsCachedData() => dataCacheService.getData();

  Future<EndpointsData> getAllEndpointsData() async {
    final enpointsData =
        await _getDataRefreshingToken(onGetData: _getAllEndpointsData);

    //save to cache
    await dataCacheService.setData(enpointsData);
    return enpointsData;
  }

  Future<EndpointsData> _getAllEndpointsData() async {
    final values = await Future.wait([
      apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.cases),
      apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.casesSuspected),
      apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.casesConfirmed),
      apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.deaths),
      apiService.getEndpointData(
          accessToken: _accessToken, endpoint: Endpoint.recovered),
    ]);

    return EndpointsData(
      values: {
        Endpoint.cases: values[0],
        Endpoint.casesSuspected: values[1],
        Endpoint.casesConfirmed: values[2],
        Endpoint.deaths: values[3],
        Endpoint.recovered: values[4],
      },
    );
  }
}

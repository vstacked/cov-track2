import 'package:covtrack2/app/repositories/endpoints_data.dart';
import 'package:covtrack2/app/services/api.dart';
import 'package:covtrack2/app/services/endpoint_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataCacheService {
  DataCacheService({@required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  static String endpointValueKey(Endpoint endpoint) => '$endpoint/value';
  static String endpointDateKey(Endpoint endpoint) => '$endpoint/date';

  EndpointsData getData() {
    Map<Endpoint, EndpointData> values = {};
    Endpoint.values.forEach((element) {
      final value = sharedPreferences.getInt(endpointValueKey(element));
      final dateString = sharedPreferences.getString(endpointDateKey(element));
      if (value != null && dateString != null) {
        final date = DateTime.tryParse(dateString);
        values[element] = EndpointData(value: value, date: date);
      }
    });
    return EndpointsData(values: values);
  }

  Future<void> setData(EndpointsData data) async {
    data.values.forEach((key, value) async {
      await sharedPreferences.setInt(endpointValueKey(key), value.value);
      await sharedPreferences.setString(
        endpointDateKey(key),
        value.date.toIso8601String(),
      );
    });
  }
}

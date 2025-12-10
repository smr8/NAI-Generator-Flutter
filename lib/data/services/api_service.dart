import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:nai_casrand/data/models/api_request.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<ApiResponse> fetchData(ApiRequest request) async {
    final url = Uri.parse(request.endpoint);
    final client = createHttpClient(request.proxy);
    http.Response response;
    if (client == null) {
      response = await http.post(
        url,
        headers: request.headers,
        body: json.encode(request.payload),
      );
    } else {
      response = await client.post(
        url,
        headers: request.headers,
        body: json.encode(request.payload),
      );
    }

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true &&
            jsonResponse['data'] != null &&
            jsonResponse['data']['image_url'] != null) {
          final imageUrl = jsonResponse['data']['image_url'];
          final imageResponse = client == null
              ? await http.get(Uri.parse(imageUrl))
              : await client.get(Uri.parse(imageUrl));
          return ApiResponse(
            status: imageResponse.statusCode.toString(),
            data: imageResponse.bodyBytes,
          );
        }
      } catch (e) {
        // Not a JSON response or error parsing, return original response
      }
    }

    return ApiResponse(
      status: response.statusCode.toString(),
      data: response.bodyBytes,
    );
  }

  http.Client? createHttpClient(String proxy) {
    if (kIsWeb || proxy == '') return null;
    final ioClient = HttpClient();
    ioClient.findProxy = (uri) => 'PROXY $proxy';
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }
}

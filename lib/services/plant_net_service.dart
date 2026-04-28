import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlantNetService {
  static const String defaultBaseUrl = "https://my-api.plantnet.org/v2/identify";

  static final Dio _dio = Dio();

  static Future<Map<String, dynamic>?> identify(List<File> images, {String project = 'all'}) async {
    final prefs = await SharedPreferences.getInstance();
    final String apiKey = prefs.getString('plantnet_key') ?? dotenv.env['PLANTNET_API_KEY'] ?? "";
    
    final String url = "$defaultBaseUrl/$project?api-key=$apiKey";
    
    try {
      List<MultipartFile> multipartImages = [];
      List<String> organs = [];

      for (var file in images) {
        multipartImages.add(await MultipartFile.fromFile(file.path, filename: 'image.jpg'));
        organs.add('leaf');
      }

      FormData formData = FormData.fromMap({
        'images': multipartImages,
        'organs': organs,
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: {'accept': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print("Error Pl@ntNet (Status ${response.statusCode}): ${response.data}");
        return null;
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio Error: ${e.response?.data ?? e.message}");
      } else {
        print("Error calling Pl@ntNet: $e");
      }
      return null;
    }
  }
}

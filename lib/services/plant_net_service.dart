import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlantNetService {
  static final String apiKey = dotenv.env['PLANTNET_API_KEY'] ?? "";
  static const String baseUrl = "https://my-api.plantnet.org/v2/identify";

  static final Dio _dio = Dio();

  static Future<Map<String, dynamic>?> identify(List<File> images, {String project = 'all'}) async {
    final String url = "$baseUrl/$project?api-key=$apiKey";
    
    try {
      // Criamos a lista de arquivos para o Dio
      List<MultipartFile> multipartImages = [];
      List<String> organs = [];

      for (var file in images) {
        multipartImages.add(await MultipartFile.fromFile(file.path, filename: 'image.jpg'));
        organs.add('leaf'); // Definimos como 'leaf' para todas as fotos
      }

      // O FormData do Dio aceita listas para chaves repetidas
      FormData formData = FormData.fromMap({
        'images': multipartImages,
        'organs': organs,
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
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

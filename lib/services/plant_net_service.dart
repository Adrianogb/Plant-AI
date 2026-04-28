import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PlantNetService {
  static const String apiKey = "2b1068vmRfMBXgrbVkCOqN8X";
  static const String baseUrl = "https://my-api.plantnet.org/v2/identify";

  static Future<Map<String, dynamic>?> identify(List<File> images, {String project = 'all'}) async {
    // Adicionamos os órgãos via query parameters pois o pacote 'http' não suporta chaves duplicadas no fields do MultipartRequest
    String organsParams = images.map((_) => "&organs=leaf").join();
    final uri = Uri.parse("$baseUrl/$project?api-key=$apiKey$organsParams");
    
    final request = http.MultipartRequest('POST', uri);

    for (var i = 0; i < images.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          images[i].path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Error Pl@ntNet: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error calling Pl@ntNet: $e");
      return null;
    }
  }
}

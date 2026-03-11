import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImgbbService {
  static const String _apiKey = 'a1514e6f0c63c29bf9970eccadd1d716';

  static Future<String?> uploadImage(String filePath) async {
    if (filePath.isEmpty || !File(filePath).existsSync()) return null;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$_apiKey'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      final response = await request.send();
      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final data = json.decode(resStr);
        return data['data']['url'];
      }
      return null;
    } catch (e) {
      print('ImgBB Service Error: $e');
      return null;
    }
  }
}

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class BusanHealthService {
  static const String baseUrl = 'http://apis.data.go.kr/6260000/BusanTblHcexStusService/getTblHcexStusInfo';
  static const String apiKey = '%2FIzNTIF8GiKEYHQ188kh1%2BcfduUz%2BiTxd6paBHtMw74xqA3HP9zXHhju4CdYnSrPV37AagmcuSi7EOdjaHXI%2Bw%3D%3D';
  
  Future<List<Map<String, String>>> getHealthcareInfo({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl?serviceKey=$apiKey'
        '&numOfRows=10'
        '&pageNo=1'
        '&resultType=xml'
      );
      
      print('API 호출 URL: $url');
      print('위치: $latitude, $longitude');

      final response = await http.get(url);
      print('API 응답 상태 코드: ${response.statusCode}');
      print('API 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        
        // 응답 코드 확인
        final resultCode = document.findAllElements('resultCode').first.text;
        final resultMsg = document.findAllElements('resultMsg').first.text;
        
        if (resultCode != '00' || resultMsg != 'NORMAL_CODE') {
          throw Exception('API 오류: $resultMsg');
        }

        final items = document.findAllElements('item');
        
        return items.map((item) => {
          'testName': _getElementText(item, 'testName'),
          'testKind': _getElementText(item, 'testKind'),
          'testPrice': _getElementText(item, 'testPrice'),
          'dataDay': _getElementText(item, 'dataDay'),
          'haeundaegu': _getElementText(item, 'haeundaegu'),
          'suyeonggu': _getElementText(item, 'suyeonggu'),
          'namgu': _getElementText(item, 'namgu'),
          'donggu': _getElementText(item, 'donggu'),
          'bukgu': _getElementText(item, 'buggu'),
          'junggu': _getElementText(item, 'junggu'),
        }).toList();
      } else {
        throw Exception('API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 오류 발생: $e');
      rethrow;
    }
  }

  String _getElementText(XmlElement item, String elementName) {
    try {
      return item.findElements(elementName).first.text.trim();
    } catch (e) {
      return '-';
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

class AIService {

  static Future<String> suggestJob(String keyword) async {

    // نموذج بسيط يعتمد على API مجاني تجريبي

    final url = Uri.parse('https://api.monkedev.com/fun/chat?msg=$keyword%20job%20suggestion');

    final res = await http.get(url);

    if (res.statusCode == 200) {

      final data = jsonDecode(res.body);

      return data['response'] ?? "لا توجد اقتراحات حالياً.";

    } else {

      return "حدث خطأ أثناء جلب الاقتراحات.";

    }

  }

}
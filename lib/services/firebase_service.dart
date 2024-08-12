import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class FirebaseService {
  const FirebaseService();

  static const firebaseURL =
      "restock-cc312-default-rtdb.asia-southeast1.firebasedatabase.app";

  Future<Map<String, dynamic>> getItems({String searchQuery = ''}) async {
    Map<String, dynamic> queryParams = {};

    if (searchQuery.isNotEmpty) {
      queryParams = {
        'orderBy': jsonEncode("name"),
        'startAt': jsonEncode(searchQuery),
        'endAt': jsonEncode("$searchQuery\uf8ff"),
      };
    }

    final url = Uri.https(firebaseURL, "shopping-list.json", queryParams);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> listData = json.decode(response.body);

      return listData;
    }

    throw HttpException(response.body);
  }

  Future<Map<String, dynamic>> addItem(
    String name,
    int quantity,
    String category,
  ) async {
    final url = Uri.https(firebaseURL, "shopping-list.json");

    final response = await http.post(
      url,
      headers: {"Content-type": "application/json"},
      body: json.encode({
        'name': name,
        'quantity': quantity,
        'category': category,
      }),
    );

    if (response.statusCode == 200) {
      final resData = json.decode(response.body);
      return resData;
    }

    throw HttpException(response.body);
  }

  Future<Map<String, dynamic>> updateItem(
    String itemId,
    String name,
    int quantity,
    String category,
  ) async {
    final url = Uri.https(firebaseURL, "shopping-list/$itemId.json");

    final response = await http.patch(
      url,
      headers: {"Content-type": "application/json"},
      body: json.encode(
        {
          'name': name,
          'quantity': quantity,
          'category': category,
        },
      ),
    );

    if (response.statusCode == 200) {
      final resData = json.decode(response.body);
      return resData;
    }

    throw HttpException(response.body);
  }

  Future<void> deleteItem(String itemId) async {
    final url = Uri.https(firebaseURL, "shopping-list/$itemId.json");

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return;
    }

    throw HttpException(response.body);
  }
}

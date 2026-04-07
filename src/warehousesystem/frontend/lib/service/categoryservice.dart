import 'apiservice.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final response = await _apiService.get('/category/categories/all');

      if (response is List) {
        return response.map<Map<String, dynamic>>((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return <String, dynamic>{};
        }).toList();
      }

      if (response is Map && response.containsKey('data')) {
        final dataList = response['data'] as List;
        return dataList.map<Map<String, dynamic>>((item) {
          return Map<String, dynamic>.from(item as Map);
        }).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getCategoryByName(String name) async {
    try {
      final response = await _apiService.get('/category/$name');

      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }

      return {};
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> createCategory(String name) async {
    try {
      final response = await _apiService.post('/category', {'name': name});

      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }

      return {};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateCategory(
    int categoryId,
    String name,
  ) async {
    try {
      final response = await _apiService.put('/category/update/$categoryId', {
        'name': name,
      });

      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }

      return {};
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      final response = await _apiService.delete('/category/delete/$categoryId');

      if (response is Map) {
        return response['success'] ?? false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}

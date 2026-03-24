import 'package:flutter/material.dart';
import '../models/productdata.dart';
import 'apiservice.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  // Получение товаров по категории - фильтруем на клиенте
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final allProducts = await getAllProducts();
      return allProducts
          .where((product) => product.categoryId == categoryId)
          .toList();
    } catch (e) {
      debugPrint('Ошибка получения товаров по категории: $e');
      return [];
    }
  }

  // Получение всех товаров
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _apiService.get('/product/products/all');
      final products = _processProductResponse(response);
      debugPrint('📦 Загружено товаров: ${products.length}');
      for (var p in products) {
        debugPrint(
          '   - ${p.name}: количество ${p.quantity}, доступен: ${p.isAvailable}',
        );
      }
      return products;
    } catch (e) {
      debugPrint('❌ Ошибка получения всех товаров: $e');
      return [];
    }
  }

  // Получение товара по имени
  Future<Product?> getProductByName(String name) async {
    try {
      final response = await _apiService.get('/product/$name');
      if (response is Map) {
        return Product.fromJson(Map<String, dynamic>.from(response));
      }
      return null;
    } catch (e) {
      debugPrint('Ошибка получения товара по имени: $e');
      return null;
    }
  }

  // Поиск товаров
  Future<List<Product>> searchProducts(String query) async {
    try {
      final allProducts = await getAllProducts();
      return allProducts
          .where(
            (product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.productId.toString().contains(query),
          )
          .toList();
    } catch (e) {
      debugPrint('Ошибка поиска товаров: $e');
      return [];
    }
  }

  // Получение товаров с низким остатком (меньше порога)
  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    try {
      final allProducts = await getAllProducts();

      // Товары считаются с низким остатком, если их количество > 0, но < порога
      final lowStock = allProducts
          .where(
            (product) =>
                (product.quantity ?? 0) > 0 &&
                (product.quantity ?? 0) < threshold,
          )
          .toList();

      debugPrint(
        '📦 Товаров с низким остатком (< $threshold): ${lowStock.length}',
      );
      for (var p in lowStock) {
        debugPrint('   - ${p.name}: ${p.quantity} шт.');
      }

      return lowStock;
    } catch (e) {
      debugPrint('❌ Ошибка получения товаров с низким остатком: $e');
      return [];
    }
  }

  // Получение статистики склада
  Future<Map<String, dynamic>> getWarehouseStats() async {
    try {
      final allProducts = await getAllProducts();

      int totalProducts = allProducts.length;

      // Товары в наличии (количество > 0 и доступен)
      int inStockCount = allProducts
          .where((p) => (p.quantity ?? 0) > 0 && p.isAvailable)
          .length;

      // Товары с низким остатком (количество от 1 до 9)
      int lowStockCount = allProducts
          .where((p) => (p.quantity ?? 0) > 0 && (p.quantity ?? 0) < 10)
          .length;

      // Товары не в наличии (количество = 0 или недоступен)
      int outOfStockCount = allProducts
          .where((p) => (p.quantity ?? 0) <= 0 || !p.isAvailable)
          .length;

      double totalValue = allProducts.fold(
        0,
        (sum, item) => sum + (item.price * (item.quantity ?? 0)),
      );

      debugPrint('📊 Статистика:');
      debugPrint('   - Всего товаров: $totalProducts');
      debugPrint('   - В наличии: $inStockCount');
      debugPrint('   - Мало на складе: $lowStockCount');
      debugPrint('   - Нет в наличии: $outOfStockCount');

      return {
        'total_products': totalProducts,
        'in_stock_count': inStockCount,
        'low_stock_count': lowStockCount,
        'out_of_stock_count': outOfStockCount,
        'total_value': totalValue,
      };
    } catch (e) {
      debugPrint('❌ Ошибка получения статистики: $e');
      return {
        'total_products': 0,
        'in_stock_count': 0,
        'low_stock_count': 0,
        'out_of_stock_count': 0,
        'total_value': 0,
      };
    }
  }

  // Увеличение количества товара (пополнение)
  Future<bool> increaseStock(int productId, int quantity) async {
    try {
      debugPrint('🔄 Пополнение товара ID: $productId, количество: $quantity');

      final allProducts = await getAllProducts();
      final product = allProducts.firstWhere(
        (p) => p.productId == productId,
        orElse: () => throw Exception('Товар не найден'),
      );

      final newQuantity = (product.quantity ?? 0) + quantity;
      debugPrint('📦 Новое количество: $newQuantity');

      final response = await _apiService.put('/product/update/$productId', {
        'quantity': newQuantity,
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'category_id': product.categoryId,
        'is_available': newQuantity > 0,
      });

      if (response is Map) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Ошибка пополнения товара: $e');
      return false;
    }
  }

  // Уменьшение количества товара (списание)
  Future<bool> decreaseStock(int productId, int quantity) async {
    try {
      debugPrint('🔄 Списание товара ID: $productId, количество: $quantity');

      final allProducts = await getAllProducts();
      final product = allProducts.firstWhere(
        (p) => p.productId == productId,
        orElse: () => throw Exception('Товар не найден'),
      );

      final currentQuantity = product.quantity ?? 0;
      if (currentQuantity < quantity) {
        throw Exception('Недостаточно товара на складе');
      }

      final newQuantity = currentQuantity - quantity;
      debugPrint('📦 Новое количество: $newQuantity');

      final response = await _apiService.put('/product/update/$productId', {
        'quantity': newQuantity,
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'category_id': product.categoryId,
        'is_available': newQuantity > 0,
      });

      if (response is Map) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Ошибка списания товара: $e');
      return false;
    }
  }

  // Вспомогательный метод для обработки ответа с товарами
  List<Product> _processProductResponse(dynamic response) {
    if (response is List) {
      return response
          .map(
            (item) => Product.fromJson(
              item is Map ? Map<String, dynamic>.from(item) : {},
            ),
          )
          .where((product) => product.productId > 0)
          .toList();
    } else if (response is Map && response.containsKey('data')) {
      return (response['data'] as List)
          .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
          .where((product) => product.productId > 0)
          .toList();
    }
    return [];
  }
}

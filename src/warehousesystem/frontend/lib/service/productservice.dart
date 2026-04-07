import '../models/productdata.dart';
import 'apiservice.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final allProducts = await getAllProducts();
      return allProducts
          .where((product) => product.categoryId == categoryId)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _apiService.get('/product/products/all');
      final products = _processProductResponse(response);
      return products;
    } catch (e) {
      return [];
    }
  }

  Future<Product?> getProductByName(String name) async {
    try {
      final response = await _apiService.get('/product/$name');
      if (response is Map) {
        return Product.fromJson(Map<String, dynamic>.from(response));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Product?> getProductById(int productId) async {
    try {
      final allProducts = await getAllProducts();
      return allProducts.firstWhere(
        (p) => p.productId == productId,
        orElse: () => throw Exception('Товар не найден'),
      );
    } catch (e) {
      return null;
    }
  }

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
      return [];
    }
  }

  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    try {
      final allProducts = await getAllProducts();

      final lowStock = allProducts
          .where(
            (product) =>
                (product.quantity ?? 0) > 0 &&
                (product.quantity ?? 0) < threshold,
          )
          .toList();

      return lowStock;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getWarehouseStats() async {
    try {
      final allProducts = await getAllProducts();

      int totalProducts = allProducts.length;
      int inStockCount = allProducts
          .where((p) => (p.quantity ?? 0) > 0 && p.isAvailable)
          .length;
      int lowStockCount = allProducts
          .where((p) => (p.quantity ?? 0) > 0 && (p.quantity ?? 0) < 10)
          .length;
      int outOfStockCount = allProducts
          .where((p) => (p.quantity ?? 0) <= 0 || !p.isAvailable)
          .length;
      double totalValue = allProducts.fold(
        0,
        (sum, item) => sum + (item.price * (item.quantity ?? 0)),
      );

      return {
        'total_products': totalProducts,
        'in_stock_count': inStockCount,
        'low_stock_count': lowStockCount,
        'out_of_stock_count': outOfStockCount,
        'total_value': totalValue,
      };
    } catch (e) {
      return {
        'total_products': 0,
        'in_stock_count': 0,
        'low_stock_count': 0,
        'out_of_stock_count': 0,
        'total_value': 0,
      };
    }
  }

  Future<bool> addProduct({
    required String name,
    required double price,
    required int categoryId,
    String? description,
    String? imageUrl,
    int quantity = 0,
  }) async {
    try {
      final response = await _apiService.post('/product/', {
        'name': name,
        'price': price,
        'description': description,
        'category_id': categoryId,
        'image_url': imageUrl,
        'quantity': quantity,
        'is_available': quantity > 0,
      });

      if (response is Map && response['product_id'] != null) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduct({
    required int productId,
    required String name,
    required double price,
    required int categoryId,
    String? description,
    String? imageUrl,
    int? quantity,
    bool? isAvailable,
  }) async {
    try {
      final product = await getProductById(productId);
      if (product == null) return false;

      final newQuantity = quantity ?? product.quantity ?? 0;

      final response = await _apiService.put('/product/update/$productId', {
        'name': name,
        'price': price,
        'description': description ?? product.description,
        'category_id': categoryId,
        'image_url': imageUrl ?? product.imageUrl,
        'quantity': newQuantity,
        'is_available': isAvailable ?? (newQuantity > 0),
      });

      if (response is Map) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      final response = await _apiService.delete('/product/delete/$productId');

      if (response is Map && response['message'] != null) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> increaseStock(int productId, int quantity) async {
    try {
      final product = await getProductById(productId);
      if (product == null) return false;

      final newQuantity = (product.quantity ?? 0) + quantity;

      return await updateProduct(
        productId: productId,
        name: product.name,
        price: product.price,
        categoryId: product.categoryId,
        description: product.description,
        imageUrl: product.imageUrl,
        quantity: newQuantity,
        isAvailable: newQuantity > 0,
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> decreaseStock(int productId, int quantity) async {
    try {
      final product = await getProductById(productId);
      if (product == null) return false;

      final currentQuantity = product.quantity ?? 0;
      if (currentQuantity < quantity) return false;

      final newQuantity = currentQuantity - quantity;

      return await updateProduct(
        productId: productId,
        name: product.name,
        price: product.price,
        categoryId: product.categoryId,
        description: product.description,
        imageUrl: product.imageUrl,
        quantity: newQuantity,
        isAvailable: newQuantity > 0,
      );
    } catch (e) {
      return false;
    }
  }

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

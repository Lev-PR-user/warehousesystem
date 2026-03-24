import 'package:flutter/material.dart';
import '../models/userdata.dart';
import '../models/productdata.dart';
import 'profilescreen.dart';
import 'productdetailscreen.dart';
import 'categoryproductsscreen.dart';
import '../service/categoryservice.dart';
import '../service/productservice.dart';

class MainScreen extends StatefulWidget {
  final UserData userData;

  const MainScreen({super.key, required this.userData});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  List<Map<String, dynamic>> _categories = [];
  List<Product> _lowStockProducts = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('🔄 Начинаем загрузку данных...');

      // Загружаем все данные параллельно с таймаутом
      final results = await Future.wait([
        _categoryService.getAllCategories().timeout(
          const Duration(seconds: 5),
          onTimeout: () => [],
        ),
        _productService
            .getLowStockProducts(threshold: 10)
            .timeout(const Duration(seconds: 5), onTimeout: () => []),
        _productService.getWarehouseStats().timeout(
          const Duration(seconds: 5),
          onTimeout: () => ({
            'total_products': 0,
            'in_stock_count': 0,
            'low_stock_count': 0,
            'out_of_stock_count': 0,
            'total_value': 0,
          }),
        ),
      ]);

      // Детальный вывод товаров с низким остатком
      List<Product> lowStock = results[1] as List<Product>;
      debugPrint('📦 ЗАГРУЖЕНО товаров с низким остатком: ${lowStock.length}');
      for (var p in lowStock) {
        debugPrint('   ➡️ ${p.name}: ${p.quantity} шт. (ID: ${p.productId})');
      }

      setState(() {
        _categories = results[0] as List<Map<String, dynamic>>;
        _lowStockProducts = lowStock;
        _stats = results[2] as Map<String, dynamic>;
        _isLoading = false;
      });

      debugPrint('📊 Статистика на главной: $_stats');

      // Если категории пустые, используем тестовые данные
      if (_categories.isEmpty) {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('❌ Ошибка загрузки: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      // Загружаем тестовые данные при ошибке
      _loadMockData();
    }
  }

  void _loadMockData() {
    setState(() {
      _categories = [
        {'category_id': 1, 'name': 'Электроника', 'products_count': 245},
        {'category_id': 2, 'name': 'Одежда', 'products_count': 189},
        {'category_id': 3, 'name': 'Игрушки', 'products_count': 156},
        {'category_id': 4, 'name': 'Канцелярия', 'products_count': 324},
        {'category_id': 5, 'name': 'Бытовая химия', 'products_count': 98},
        {'category_id': 6, 'name': 'Продукты', 'products_count': 167},
        {'category_id': 7, 'name': 'Инструменты', 'products_count': 78},
        {'category_id': 8, 'name': 'Техника', 'products_count': 112},
      ];

      _stats = {
        'total_products': 1500,
        'in_stock_count': 1432,
        'low_stock_count': 23,
        'out_of_stock_count': 45,
        'total_value': 1250000,
      };

      _lowStockProducts = List.generate(
        5,
        (index) => Product(
          productId: index + 1,
          name: 'Товар ${index + 1}',
          description: 'Описание',
          price: 999.0,
          categoryId: 1,
          quantity: 5 + index,
          isAvailable: true,
        ),
      );
    });
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) return;

    try {
      final results = await _productService.searchProducts(query);
      if (mounted) {
        final shouldRefresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsScreen(
              query: query,
              products: results,
              userData: widget.userData,
            ),
          ),
        );

        // Если нужно обновить после поиска
        if (shouldRefresh == true) {
          _loadData();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка поиска: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'СКЛАД',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF3498DB).withOpacity(0.1),
              backgroundImage: widget.userData.avatarUrl != null
                  ? NetworkImage(widget.userData.avatarUrl!)
                  : null,
              child: widget.userData.avatarUrl == null
                  ? Text(
                      widget.userData.login.isNotEmpty
                          ? widget.userData.login[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3498DB),
                      ),
                    )
                  : null,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(value, context),
            icon: const Icon(Icons.more_vert, color: Color(0xFF2C3E50)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Color(0xFF2C3E50)),
                    SizedBox(width: 12),
                    Text('Профиль'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Color(0xFF2C3E50)),
                    SizedBox(width: 12),
                    Text('Обновить'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3498DB),
                strokeWidth: 3,
              ),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFE74C3C),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки',
                    style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Приветствие и поиск
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.waving_hand,
                              color: Color(0xFFF1C40F),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Добро пожаловать,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userData.login,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Поле поиска
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: _searchProducts,
                            decoration: const InputDecoration(
                              hintText:
                                  'Поиск товаров по артикулу или названию...',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              suffixIcon: Icon(
                                Icons.filter_list,
                                color: Colors.grey,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Статистика склада - ПЕРВЫЙ РЯД
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Всего товаров',
                            '${_stats['total_products'] ?? 0}',
                            Icons.inventory_2_outlined,
                            const Color(0xFF3498DB),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'В наличии',
                            '${_stats['in_stock_count'] ?? 0}',
                            Icons.check_circle_outline,
                            const Color(0xFF2ECC71),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Статистика склада - ВТОРОЙ РЯД
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Мало на складе',
                            '${_stats['low_stock_count'] ?? _lowStockProducts.length}',
                            Icons.warning_amber_outlined,
                            const Color(0xFFF39C12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Нет в наличии',
                            '${_stats['out_of_stock_count'] ?? 0}',
                            Icons.cancel_outlined,
                            const Color(0xFFE74C3C),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Категории
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Категории товаров',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Переход на все категории
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF3498DB),
                          ),
                          child: const Text('Все категории'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Сетка категорий
                  if (_categories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.9,
                            ),
                        itemCount: _categories.length > 8
                            ? 8
                            : _categories.length,
                        itemBuilder: (context, index) {
                          // Защита от выхода за границы массива
                          if (index >= _categories.length) {
                            return const SizedBox.shrink();
                          }

                          final category = _categories[index];
                          return CategoryCard(
                            icon: _getCategoryIcon(category['name'] ?? ''),
                            label: category['name'] ?? 'Категория',
                            color: _getCategoryColor(category['name'] ?? ''),
                            count: category['products_count'] ?? 0,
                            categoryId: category['category_id'] ?? 0,
                            userData: widget.userData,
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Товары с низким остатком - теперь с правильной проверкой
                  if (_lowStockProducts.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Требуется пополнение',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF39C12).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_lowStockProducts.length} товара',
                              style: const TextStyle(
                                color: Color(0xFFF39C12),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Горизонтальный список товаров с низким остатком
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _lowStockProducts.length,
                        itemBuilder: (context, index) {
                          // Защита от выхода за границы массива
                          if (index >= _lowStockProducts.length) {
                            return const SizedBox.shrink();
                          }
                          return _buildLowStockCard(_lowStockProducts[index]);
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ИСПРАВЛЕННЫЙ МЕТОД - теперь правильно отображает статус и обновляет данные
  Widget _buildLowStockCard(Product product) {
    final quantity = product.quantity ?? 0;
    final isLowStock = quantity > 0 && quantity < 10;

    return GestureDetector(
      onTap: () async {
        debugPrint(
          '👉 Открываем карточку товара: ${product.name} (ID: ${product.productId})',
        );

        // Ждем результат с экрана деталей
        final shouldRefresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
              userData: widget.userData,
            ),
          ),
        );

        debugPrint(
          '👈 Вернулись на главный экран, shouldRefresh = $shouldRefresh',
        );

        // Если нужно обновить (после списания/пополнения)
        if (shouldRefresh == true) {
          debugPrint('🔄 Обновляем главный экран после операции');
          await _loadData();
          debugPrint('✅ Главный экран обновлен');
        }
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                    // Статус наличия - теперь правильно отображается
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLowStock
                              ? const Color(0xFFF39C12) // Желтый для мало
                              : (quantity > 0
                                    ? const Color(
                                        0xFF2ECC71,
                                      ) // Зеленый для достаточно
                                    : const Color(
                                        0xFFE74C3C,
                                      )), // Красный для нет
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          !isLowStock
                              ? (quantity > 0 ? 'Достаточно' : 'Нет')
                              : 'Мало',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Количество
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$quantity шт',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${product.price.toStringAsFixed(0)} ₽',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'электроника':
        return Icons.computer;
      case 'одежда':
        return Icons.checkroom;
      case 'игрушки':
        return Icons.toys;
      case 'канцелярия':
        return Icons.create;
      case 'бытовая химия':
        return Icons.cleaning_services;
      case 'продукты':
        return Icons.fastfood;
      case 'инструменты':
        return Icons.build;
      case 'техника':
        return Icons.kitchen;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'электроника':
        return const Color(0xFF3498DB);
      case 'одежда':
        return const Color(0xFF9B59B6);
      case 'игрушки':
        return const Color(0xFFE74C3C);
      case 'канцелярия':
        return const Color(0xFFF39C12);
      case 'бытовая химия':
        return const Color(0xFF2ECC71);
      case 'продукты':
        return const Color(0xFFE67E22);
      case 'инструменты':
        return const Color(0xFF95A5A6);
      case 'техника':
        return const Color(0xFF1ABC9C);
      default:
        return const Color(0xFF3498DB);
    }
  }

  void _handleMenuSelection(String value, BuildContext context) {
    if (value == 'profile') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userData: widget.userData),
        ),
      );
    } else if (value == 'refresh') {
      _loadData();
    }
  }
}

// ==================== ОСТАЛЬНЫЕ КЛАССЫ ====================

// Класс для карточки категории
class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int count;
  final int categoryId;
  final UserData userData;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.count,
    required this.categoryId,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsScreen(
              categoryName: label,
              categoryId: categoryId,
              userData: userData,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$count шт',
              style: TextStyle(fontSize: 9, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// Класс для экрана результатов поиска
class SearchResultsScreen extends StatelessWidget {
  final String query;
  final List<Product> products;
  final UserData userData;

  const SearchResultsScreen({
    super.key,
    required this.query,
    required this.products,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        title: Text(
          'Результаты поиска',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Ничего не найдено',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'По запросу "$query"',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Найдено товаров: ${products.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        if (index >= products.length) {
                          return const SizedBox.shrink();
                        }
                        return ProductCard(
                          product: products[index],
                          userData: userData,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Класс для карточки товара
class ProductCard extends StatelessWidget {
  final Product product;
  final UserData userData;

  const ProductCard({super.key, required this.product, required this.userData});

  @override
  Widget build(BuildContext context) {
    final isInStock = product.isAvailable && (product.quantity ?? 0) > 0;
    final quantity = product.quantity ?? 0;
    final isLowStock = quantity > 0 && quantity < 10;

    return GestureDetector(
      onTap: () async {
        final shouldRefresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailScreen(product: product, userData: userData),
          ),
        );

        // Если нужно обновить после операции
        if (shouldRefresh == true && context.mounted) {
          // Возвращаем результат на главный экран
          Navigator.pop(context, true);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение товара с индикатором наличия
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  // Индикатор наличия - исправлено
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: !isInStock
                            ? const Color(0xFFE74C3C)
                            : (isLowStock
                                  ? const Color(0xFFF39C12)
                                  : const Color(0xFF2ECC71)),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        !isInStock
                            ? 'Нет'
                            : (isLowStock ? 'Мало' : 'В наличии'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Количество
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$quantity шт',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Информация о товаре
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Название и артикул
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PRD-${product.productId}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    // Цена
                    Text(
                      '${product.price.toStringAsFixed(0)} ₽',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

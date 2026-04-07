import 'package:flutter/material.dart';
import '../models/productdata.dart';
import '../models/userdata.dart';
import '../service/productservice.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final UserData userData;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.userData,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  late Future<Product?> _productFuture;
  bool _isLoading = false;
  String? _error;
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshProduct();
  }

  Future<void> _refreshProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final updatedProduct = await _productService.getProductByName(
        widget.product.name,
      );

      if (updatedProduct != null && mounted) {
        setState(() {
          _productFuture = Future.value(updatedProduct);
          _isLoading = false;
        });
      } else {
        final allProducts = await _productService.getAllProducts();
        final foundProduct = allProducts.firstWhere(
          (p) => p.productId == widget.product.productId,
          orElse: () => widget.product,
        );

        setState(() {
          _productFuture = Future.value(foundProduct);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Ошибка загрузки: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _productFuture = Future.value(widget.product);
      });
    }
  }

  // ✏️ РЕДАКТИРОВАНИЕ ТОВАРА
  Future<void> _editProduct(Product product) async {
    if (!widget.userData.isAdmin) {
      _showErrorSnackBar('Только администратор может редактировать товары');
      return;
    }

    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(
      text: product.price.toString(),
    );
    final categoryIdController = TextEditingController(
      text: product.categoryId.toString(),
    );
    final descriptionController = TextEditingController(
      text: product.description ?? '',
    );
    final quantityController = TextEditingController(
      text: (product.quantity ?? 0).toString(),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактирование товара'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Цена'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryIdController,
                decoration: const InputDecoration(labelText: 'ID категории'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Количество'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
            ),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);

      final success = await _productService.updateProduct(
        productId: product.productId,
        name: nameController.text.trim(),
        price: double.parse(priceController.text),
        categoryId: int.parse(categoryIdController.text),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        quantity: int.tryParse(quantityController.text) ?? 0,
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        _showSuccessSnackBar('✅ Товар обновлён');
        _refreshProduct();
        Navigator.pop(context, true);
      } else if (mounted) {
        _showErrorSnackBar('❌ Ошибка при обновлении');
      }
    }
  }

  // ❌ УДАЛЕНИЕ ТОВАРА
  Future<void> _deleteProduct(Product product) async {
    if (!widget.userData.isAdmin) {
      _showErrorSnackBar('Только администратор может удалять товары');
      return;
    }

    final confirm = await _showConfirmDialog(
      'Подтверждение удаления',
      'Удалить товар "${product.name}"?\nЭто действие нельзя отменить.',
    );

    if (!confirm) return;

    setState(() => _isLoading = true);

    final success = await _productService.deleteProduct(product.productId);

    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSuccessSnackBar('✅ Товар удалён');
      Navigator.pop(context, true);
    } else if (mounted) {
      _showErrorSnackBar('❌ Ошибка при удалении');
    }
  }

  Future<void> _decreaseStock(Product product) async {
    if (!widget.userData.isAdmin) {
      _showErrorSnackBar('Только администратор может списывать товары');
      return;
    }

    if (product.quantity == null || product.quantity! <= 0) {
      _showErrorSnackBar('Невозможно списать: товар отсутствует');
      return;
    }

    int quantity = 1;
    if (_quantityController.text.isNotEmpty) {
      quantity = int.tryParse(_quantityController.text) ?? 1;
    }

    if (quantity <= 0) {
      _showErrorSnackBar('Количество должно быть больше 0');
      return;
    }

    if (quantity > (product.quantity ?? 0)) {
      _showErrorSnackBar(
        'Недостаточно товара на складе. Доступно: ${product.quantity}',
      );
      return;
    }

    bool confirm = await _showConfirmDialog(
      'Подтверждение списания',
      'Списать $quantity шт. товара "${product.name}"?',
    );

    if (!confirm) return;

    setState(() => _isLoading = true);

    try {
      final success = await _productService.decreaseStock(
        product.productId,
        quantity,
      );

      if (success && mounted) {
        _showSuccessSnackBar('✅ Списано $quantity шт. товара');
        Navigator.pop(context, true);
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar('❌ Ошибка при списании товара');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('❌ Ошибка при списании: $e');
    }
  }

  Future<void> _increaseStock(Product product) async {
    if (!widget.userData.isAdmin) {
      _showErrorSnackBar('Только администратор может пополнять товары');
      return;
    }

    int quantity = 1;
    if (_quantityController.text.isNotEmpty) {
      quantity = int.tryParse(_quantityController.text) ?? 1;
    }

    if (quantity <= 0) {
      _showErrorSnackBar('Количество должно быть больше 0');
      return;
    }

    bool confirm = await _showConfirmDialog(
      'Подтверждение пополнения',
      'Добавить $quantity шт. товара "${product.name}"?',
    );

    if (!confirm) return;

    setState(() => _isLoading = true);

    try {
      final success = await _productService.increaseStock(
        product.productId,
        quantity,
      );

      if (success && mounted) {
        _showSuccessSnackBar('✅ Добавлено $quantity шт. товара');
        Navigator.pop(context, true);
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar('❌ Ошибка при пополнении товара');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('❌ Ошибка при добавлении: $e');
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Подтвердить'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2ECC71),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE74C3C),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showQuantityDialog(bool isDecrease, Product product) {
    if (!widget.userData.isAdmin) {
      _showErrorSnackBar(
        isDecrease
            ? 'Только администратор может списывать товары'
            : 'Только администратор может пополнять товары',
      );
      return;
    }

    _quantityController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDecrease ? 'Списание товара' : 'Пополнение товара'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Товар: ${product.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Количество',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (isDecrease) {
                _decreaseStock(product);
              } else {
                _increaseStock(product);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDecrease
                  ? const Color(0xFFE74C3C)
                  : const Color(0xFF2ECC71),
              foregroundColor: Colors.white,
            ),
            child: Text(isDecrease ? 'Списать' : 'Пополнить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        title: const Text(
          'Детали товара',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          // Кнопка обновления
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProduct,
            color: const Color(0xFF2C3E50),
          ),
          // ✏️ Кнопка редактирования (только для админов)
          if (widget.userData.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF3498DB)),
              onPressed: () async {
                final product = await _productFuture;
                if (product != null) {
                  await _editProduct(product);
                }
              },
              tooltip: 'Редактировать',
            ),
          // ❌ Кнопка удаления (только для админов)
          if (widget.userData.isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFE74C3C)),
              onPressed: () async {
                final product = await _productFuture;
                if (product != null) {
                  await _deleteProduct(product);
                }
              },
              tooltip: 'Удалить',
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
                    onPressed: _refreshProduct,
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
          : FutureBuilder<Product?>(
              future: _productFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3498DB),
                      strokeWidth: 3,
                    ),
                  );
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return Center(
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
                          'Не удалось загрузить товар',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final product = snapshot.data!;
                final isInStock =
                    product.isAvailable && (product.quantity ?? 0) > 0;
                final quantity = product.quantity ?? 0;
                final isAdmin = widget.userData.isAdmin;
                final isLowStock = quantity > 0 && quantity < 10;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Изображение товара
                      Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.white,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            product.imageUrl != null
                                ? Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.inventory_2_outlined,
                                        size: 100,
                                        color: Colors.grey[300],
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.inventory_2_outlined,
                                    size: 100,
                                    color: Colors.grey[300],
                                  ),
                            // Статус товара
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: !isInStock
                                      ? const Color(0xFFE74C3C).withOpacity(0.9)
                                      : (isLowStock
                                            ? const Color(
                                                0xFFF39C12,
                                              ).withOpacity(0.9)
                                            : const Color(
                                                0xFF2ECC71,
                                              ).withOpacity(0.9)),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  !isInStock
                                      ? 'НЕТ В НАЛИЧИИ'
                                      : (isLowStock ? 'МАЛО' : 'В НАЛИЧИИ'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Название и артикул
                            Container(
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF3498DB,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Артикул: PRD-${product.productId}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF3498DB),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Категория ID: ${product.categoryId}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Цена и количество
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Цена',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${product.price.toStringAsFixed(0)} ₽',
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2C3E50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'На складе',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '$quantity',
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2C3E50),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'шт',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Информация о наличии
                            Container(
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
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: !isInStock
                                          ? const Color(
                                              0xFFE74C3C,
                                            ).withOpacity(0.1)
                                          : (isLowStock
                                                ? const Color(
                                                    0xFFF39C12,
                                                  ).withOpacity(0.1)
                                                : const Color(
                                                    0xFF2ECC71,
                                                  ).withOpacity(0.1)),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      !isInStock
                                          ? Icons.cancel_outlined
                                          : (isLowStock
                                                ? Icons.warning_amber_outlined
                                                : Icons.check_circle_outline),
                                      color: !isInStock
                                          ? const Color(0xFFE74C3C)
                                          : (isLowStock
                                                ? const Color(0xFFF39C12)
                                                : const Color(0xFF2ECC71)),
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          !isInStock
                                              ? 'Товар отсутствует'
                                              : (isLowStock
                                                    ? 'Мало на складе'
                                                    : 'Товар в наличии'),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: !isInStock
                                                ? const Color(0xFFE74C3C)
                                                : (isLowStock
                                                      ? const Color(0xFFF39C12)
                                                      : const Color(
                                                          0xFF2ECC71,
                                                        )),
                                          ),
                                        ),
                                        if (isInStock && isLowStock)
                                          const Text(
                                            'Рекомендуется пополнить запасы',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFF39C12),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Описание товара
                            Container(
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.description_outlined,
                                        size: 20,
                                        color: Color(0xFF3498DB),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Описание',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    product.description ??
                                        'Описание отсутствует',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[800],
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Кнопки действий для склада (только для админов)
                            if (isAdmin) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: isInStock
                                          ? () => _showQuantityDialog(
                                              true,
                                              product,
                                            )
                                          : null,
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 20,
                                      ),
                                      label: const Text('Списать'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFE74C3C,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _showQuantityDialog(false, product),
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        size: 20,
                                      ),
                                      label: const Text('Пополнить'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2ECC71,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Color(0xFF3498DB),
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Операции со складом доступны только администраторам',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

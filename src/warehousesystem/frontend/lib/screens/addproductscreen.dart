import 'package:flutter/material.dart';
import '../service/productservice.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ProductService _productService = ProductService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryIdController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _productService.addProduct(
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text),
      categoryId: int.parse(_categoryIdController.text),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      quantity: int.tryParse(_quantityController.text) ?? 0,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Товар успешно добавлен'),
          backgroundColor: Color(0xFF2ECC71),
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Ошибка при добавлении товара'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
    }
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
          'Добавление товара',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3498DB),
                strokeWidth: 3,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
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
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Название товара *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                            ),
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Введите название'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _priceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Цена *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.currency_ruble),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true)
                                      return 'Введите цену';
                                    if (double.tryParse(value!) == null) {
                                      return 'Введите число';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _categoryIdController,
                                  decoration: const InputDecoration(
                                    labelText: 'ID категории *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.category),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true)
                                      return 'Введите ID';
                                    if (int.tryParse(value!) == null) {
                                      return 'Введите число';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Количество на складе',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.production_quantity_limits,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Описание',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description_outlined),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'URL изображения',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.image_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Color(0xFFE74C3C)),
                            ),
                            child: const Text(
                              'Отмена',
                              style: TextStyle(color: Color(0xFFE74C3C)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _addProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2ECC71),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Добавить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

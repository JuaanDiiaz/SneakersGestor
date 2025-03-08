import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:gestor_tenis/providers/product_form_provider.dart';
import 'package:gestor_tenis/services/services.dart';
import 'package:gestor_tenis/ui/input_decorations.dart';
import 'package:gestor_tenis/widgets/widgets.dart';

import '../models/models.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(productService.selectedProduct),
      child: _ProductScreenBody(productService: productService),
    );
  }
}

class _ProductScreenBody extends StatefulWidget {
  const _ProductScreenBody({super.key, required this.productService});

  final ProductsService productService;

  @override
  State<_ProductScreenBody> createState() => _ProductScreenBodyState();
}

class _ProductScreenBodyState extends State<_ProductScreenBody> {
  List<File> _images = [];
  String? _selectedImage;

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
        _selectedImage = _images.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ProductImage(url: productForm.product.picture),
                Positioned(
                  top: 60,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 40, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    onPressed: () async {
                      _pickImages();
                    },
                    icon: const Icon(Icons.camera_alt_outlined, size: 40, color: Colors.white),
                  ),
                )
              ],
            ),
            if (_images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                height: 100,
                width: double.infinity,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = _images[index];
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _images[index] == _selectedImage
                                ? Colors.blue
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Image.file(_images[index], fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
            ),
            _ProductForm(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: widget.productService.isSaving
            ? null
            : () async {
                if (!productForm.isValidForm()) return;
                final String? imageUrl = await widget.productService.uploadImage();
                if (imageUrl != null) productForm.product.picture = imageUrl;
                await widget.productService.saveOrCreateProduct(productForm.product);
              },
        child: widget.productService.isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.save_outlined),
      ),
    );
  }
}

class _ProductForm extends StatefulWidget {
  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final List<String> brands = ['Nike', 'Adidas', 'Puma', 'Reebok', 'Converse', 'Vans'];
  final Map<String, List<String>> sizes = {
    'Hombre': ['6', '7', '8', '9', '10', '11'],
    'Mujer': ['5', '6', '7', '8', '9'],
    'Niño': ['1', '2', '3', '4', '5'],
    'Niña': ['1', '2', '3', '4', '5'],
  };
  String selectedGender = 'Hombre';
  String selectedSize = '6';
  Color selectedColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: _buildBoxDecoration(),
        child: Form(
          key: productForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                initialValue: product.name,
                onChanged: (value) => product.name = value,
                validator: (value) => value == null || value.isEmpty ? 'El nombre es obligatorio' : null,
                decoration: InputDecorations.authInputDecoration(hintText: 'Nombre del producto', labelText: 'Nombre:'),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: product.brand,
                items: brands.map((brand) => DropdownMenuItem(value: brand, child: Text(brand))).toList(),
                onChanged: (value) => setState(() => product.brand = value!),
                decoration: InputDecorations.authInputDecoration(labelText: 'Marca', hintText: 'Marca del producto'),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: sizes.keys.map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
                onChanged: (value) => setState(() {
                  selectedGender = value!;
                  selectedSize = sizes[selectedGender]!.first;
                }),
                decoration: InputDecorations.authInputDecoration(labelText: 'Género', hintText: 'Género del producto'),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedSize,
                items: sizes[selectedGender]!.map((size) => DropdownMenuItem(value: size, child: Text(size))).toList(),
                onChanged: (value) => setState(() => selectedSize = value!),
                decoration: InputDecorations.authInputDecoration(labelText: 'Talla', hintText: 'Talla del producto'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: product.price?.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => product.price = double.tryParse(value) ?? 0.0,
                validator: (value) => (value == null || value.isEmpty) ? 'El precio es obligatorio' : null,
                decoration: InputDecorations.authInputDecoration(hintText: 'Precio del producto', labelText: 'Precio:'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectColor(context, product),
                    child: const Text('Seleccionar Color'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SwitchListTile.adaptive(
                value: product.available,
                title: const Text('Disponible'),
                activeColor: Colors.indigo,
                onChanged: productForm.updateAvailability,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _selectColor(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecciona un color'),
        content: BlockPicker(
          pickerColor: selectedColor,
          onColorChanged: (color) => setState(() {
            selectedColor = color;
            product.color = color.value.toString(); // Guarda el color en el producto
          }),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(color: Colors.white);
}

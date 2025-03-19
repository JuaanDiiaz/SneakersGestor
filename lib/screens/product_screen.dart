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
  String image = '';

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
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 40, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final XFile? pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 100,
                      );
                      if (pickedFile == null) return;
                      image = pickedFile.path;
                      productForm.product.picture = image;
                      setState(() {});
                    },
                    icon: const Icon(Icons.camera_alt_outlined,
                        size: 40, color: Colors.white),
                  ),
                )
              ],
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
                //final String? imageUrl = await widget.productService.uploadImage(image);
                //if (imageUrl != null) productForm.product.picture = imageUrl;
                await widget.productService
                    .saveOrCreateProduct(productForm.product);
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
  final List<String> brands = [
    'Nike',
    'Adidas',
    'Puma',
    'Reebok',
    'Converse',
    'Vans'
  ];
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
                validator: (value) => value == null || value.isEmpty
                    ? 'El nombre es obligatorio'
                    : null,
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'Nombre del producto', labelText: 'Nombre:'),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: product.brand,
                items: brands
                    .map((brand) =>
                        DropdownMenuItem(value: brand, child: Text(brand)))
                    .toList(),
                onChanged: (value) => setState(() => product.brand = value!),
                decoration: InputDecorations.authInputDecoration(
                    labelText: 'Marca', hintText: 'Marca del producto'),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: sizes.keys
                    .map((gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => setState(() {
                  selectedGender = value!;
                  selectedSize = sizes[selectedGender]!.first;
                }),
                decoration: InputDecorations.authInputDecoration(
                    labelText: 'Género', hintText: 'Género del producto'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: product.price.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) =>
                    product.price = double.tryParse(value) ?? 0.0,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'El precio es obligatorio'
                    : null,
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'Precio del producto', labelText: 'Precio:'),
              ),
              const SizedBox(height: 20),
              SwitchListTile.adaptive(
                value: product.available,
                title: const Text('Disponible'),
                activeColor: Colors.indigo,
                onChanged: productForm.updateAvailability,
              ),
              const SizedBox(height: 20),
              if (product.details != null && product.details!.isNotEmpty)
                SizedBox(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: product.details!.length,
                    itemBuilder: (context, index) {
                      final detail = product.details![index];
                      return Dismissible(
                        key: Key(index.toString()),
                        background: Container(
                          color: Colors.red,
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                        ),
                        onDismissed: (_) {
                          product.details!.removeAt(index);
                          setState(() {});
                        },
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Color(int.parse(detail.color)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (detail.mainImage.startsWith('http'))
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      detail.mainImage,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                if (detail.mainImage.startsWith('/') &&
                                    (Platform.isAndroid || Platform.isIOS))
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(detail.mainImage),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'POS ${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tallas disponibles: ${detail.sizes.map((size) => '${size.keys.first} (${size.values.first})').join(', ')}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.amber,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Agregar detalle'),
                  ),
                ),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext modalContext) {
                      return ChangeNotifierProvider.value(
                        value: Provider.of<ProductFormProvider>(context,
                            listen: false),
                        child:
                            ProductDetaiWidget(sizes: sizes[selectedGender]!),
                      );
                    },
                  );
                },
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(color: Colors.white);
}

class ProductDetaiWidget extends StatefulWidget {
  ProductDetaiWidget({super.key, required this.sizes});
  ProductDetails detail = ProductDetails('', [], '', []);
  final List<String> sizes;

  @override
  State<ProductDetaiWidget> createState() => _ProductDetaiWidgetState();
}

class _ProductDetaiWidgetState extends State<ProductDetaiWidget> {
  String selectedSize = '';
  int quantity = 1;
  Color selectedColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    final size = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            if (widget.detail.sizes.length > 0)
              Container(
                height: widget.detail.sizes.length * 60.0,
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.detail.sizes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            'Talla: ${widget.detail.sizes[index].keys.first} - Cantidad: ${widget.detail.sizes[index].values.first}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => {
                            widget.detail.sizes.removeAt(index),
                            setState(() {})
                          },
                        ),
                      );
                    }),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: widget.sizes.length > 0
                      ? DropdownButtonFormField<String>(
                          value: selectedSize.isEmpty
                              ? widget.sizes.first
                              : selectedSize,
                          items: widget.sizes
                              .map((size) => DropdownMenuItem(
                                  value: size, child: Text(size)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedSize = value!),
                          decoration: InputDecorations.authInputDecoration(
                              labelText: 'Talla',
                              hintText: 'Talla del producto'),
                        )
                      : Container(),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    initialValue: "1",
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => quantity = int.tryParse(value) ?? 1,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'La cantidad es necesaria'
                        : null,
                    decoration: InputDecorations.authInputDecoration(
                        hintText: 'Cantidad de pares', labelText: 'Cantidad:'),
                  ),
                ),
                GestureDetector(
                  child: const Icon(
                    Icons.add_circle_outline,
                    size: 30,
                  ),
                  onTap: () => {
                    widget.detail.sizes.add({
                      selectedSize.isEmpty ? widget.sizes.first : selectedSize:
                          quantity
                    }),
                    widget.detail.color = selectedColor.toString(),
                    setState(() {}),
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 100,
                  );

                  if (pickedFile == null) return;
                  widget.detail.mainImage = pickedFile.path;

                  setState(() {});
                },
                child: const Text('Seleccionar imagen principal')),
            if (widget.detail.mainImage.isNotEmpty)
              const ProductImage().getImage(
                widget.detail.mainImage,
              ),
            const Text('Imágenes del producto'),
            ElevatedButton(
              onPressed: () async {
                _pickImages();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Seleccionar imágenes'),
            ),
            const SizedBox(height: 10),
            if (widget.detail.images.isNotEmpty)
              Container(
                height: 100,
                width: double.infinity,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.detail.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(5),
                      width: 100,
                      child: const ProductImage()
                          .getImage(widget.detail.images[index]),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => {
                    _selectColor(context),
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(''),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => {
                    productForm.addDetail(widget.detail),
                    setState(() {
                      widget.detail = ProductDetails('', [], '', []);
                    }),
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Agregar detalle'),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        widget.detail.images =
            pickedFiles.map((file) => File(file.path).path).toList();
      });
    }
  }

  void _selectColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecciona un color'),
        content: BlockPicker(
          pickerColor: selectedColor,
          onColorChanged: (color) => setState(() {
            selectedColor = color;
            widget.detail.color = selectedColor.value.toString();
          }),
        ),
      ),
    );
  }
}

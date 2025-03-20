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
      resizeToAvoidBottomInset: true,
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
    final size = MediaQuery.of(context).size;

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
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (_) {
                          setState(() {
                            product.details!.removeAt(index);
                          });
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
              ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (_) => ChangeNotifierProvider.value(
                            value: Provider.of<ProductFormProvider>(context,
                                listen: false),
                            child: ProductDetaiWidget(
                                sizes: sizes[selectedGender]!),
                          ));
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar detalle'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
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

    return Container(
      padding: const EdgeInsets.all(20),
      height: 500,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // Evita que el Column intente ocupar todo el espacio
          children: [
            const SizedBox(height: 10),
            if (widget.detail.sizes.isNotEmpty)
              SizedBox(
                height: widget.detail.sizes.length *
                    60.0, // Mantener una altura definida
                child: ListView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(), // Para evitar conflictos de scroll
                  itemCount: widget.detail.sizes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        'Talla: ${widget.detail.sizes[index].keys.first} - Cantidad: ${widget.detail.sizes[index].values.first}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() {
                            widget.detail.sizes.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: widget.sizes.isNotEmpty
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
                          decoration: InputDecoration(
                            labelText: 'Talla',
                            hintText: 'Talla del producto',
                          ),
                        )
                      : Container(),
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                    Text('$quantity'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
                GestureDetector(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue,
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      size: 30,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      widget.detail.sizes.add({
                        selectedSize.isEmpty
                            ? widget.sizes.first
                            : selectedSize: quantity
                      });
                      widget.detail.color = selectedColor.toString();
                      quantity = 1;
                    });
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

                if (pickedFile != null) {
                  setState(() {
                    widget.detail.mainImage = pickedFile.path;
                  });
                }
              },
              child: const Text('Seleccionar imagen principal'),
            ),
            if (widget.detail.mainImage.isNotEmpty)
              ProductImage().getImage(widget.detail.mainImage),
            const Text('Imágenes del producto'),
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text('Seleccionar imágenes'),
            ),
            const SizedBox(height: 10),
            if (widget.detail.images.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.detail.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(5),
                      width: 100,
                      child:
                          ProductImage().getImage(widget.detail.images[index]),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _selectColor(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(''),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    productForm.addDetail(widget.detail);
                    setState(() {
                      widget.detail = ProductDetails('', [], '', []);
                    });
                  },
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

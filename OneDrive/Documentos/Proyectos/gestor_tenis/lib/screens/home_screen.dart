import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gestor_tenis/models/models.dart';
import 'package:gestor_tenis/screens/screens.dart';
import 'package:gestor_tenis/services/services.dart';
import 'package:gestor_tenis/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsService = Provider.of<ProductsService>(context);
    
    if (productsService.isLoading) return LoadingScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: ListView.builder(
        itemCount: productsService.products.length,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
          onTap: () {
            productsService.selectedProduct = productsService.products[index].copy();
            Navigator.pushNamed(context, 'product');
          },
          child: ProductCard(
            product: productsService.products[index],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          productsService.selectedProduct = Product(
            available: false,
            name: '',
            price: 0,
            brand: 'Nike', // Valor predeterminado o vacío según prefieras
            gender: 'Hombre',
            size: '0', // Define un valor adecuado
            color: '#FFFFFF', // Color por defecto (blanco)
          );
          Navigator.pushNamed(context, 'product');
        },
      ),
    );
  }
}

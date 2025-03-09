import 'package:flutter/material.dart';
import 'package:gestor_tenis/models/models.dart';

class ProductFormProvider extends ChangeNotifier {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Product product;

  ProductFormProvider( this.product );

  updateAvailability( bool value ) {
    print(value);
    product.available = value;
    notifyListeners();
  }

  addDetail(ProductDetails detail) {
    product.details ??= [];

    product.details!.add(detail);
    notifyListeners();
  }


  bool isValidForm() {

    print( product.name );
    print( product.price );
    print( product.available );

    return formKey.currentState?.validate() ?? false;
  }

}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gestor_tenis/screens/screens.dart';
import 'package:gestor_tenis/services/services.dart';

 
void main() => runApp(AppState());

class AppState extends StatelessWidget {
  const AppState({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ( _ ) => ProductsService() )
      ],
      child: MyApp(),
    );
  }
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Productos App',
      initialRoute: 'home',
      routes: {
        'login'   : ( _ ) => LoginScreen(),
        'home'    : ( _ ) => HomeScreen(),
        'product' : ( _ ) => ProductScreen(),
      },
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[300],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          color: Colors.indigo
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
          elevation: 0
        )
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_app/presentation/pages/home_page.dart';
import 'package:product_app/presentation/pages/product_page.dart';
import 'package:product_app/presentation/pages/product_details_page.dart';
import 'package:product_app/domain/entities/products.dart';
import 'package:product_app/presentation/providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeMode, 
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
        '/products': (context) => const ProductPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          );
        }
        return null; 
      },
    );
  }
}

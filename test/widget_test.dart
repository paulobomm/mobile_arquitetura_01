






import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:product_app/main.dart';
import 'package:product_app/domain/entities/products.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/presentation/product_viewmodel.dart';

class _FakeRepo implements ProductRepository {
  @override
  Future<List<Product>> getProducts() async => [];
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    
    final viewModel = ProductViewModel(_FakeRepo());
    await tester.pumpWidget(MyApp(viewModel: viewModel));

    
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

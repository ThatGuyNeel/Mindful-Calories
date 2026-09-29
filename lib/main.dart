// import 'package:flutter/material.dart';
// import 'package:openfoodfacts/openfoodfacts.dart';

// void main() {
//   // 1. Ensure Flutter bindings are initialized
//   WidgetsFlutterBinding.ensureInitialized();

//   // 2. Set the global User-Agent required by OpenFoodFacts
//   // Format: AppName/Version (ContactEmail or Website)
//   OpenFoodAPIConfiguration.userAgent = UserAgent(
//     name: 'MyFoodApp',
//     version: '1.0.0',
//     comment: 'Student project build',
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Food Product Finder',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
//         useMaterial3: true,
//       ),
//       home: const ProductSearchPage(),
//     );
//   }
// }

// class ProductSearchPage extends StatefulWidget {
//   const ProductSearchPage({super.key});

//   @override
//   State<ProductSearchPage> createState() => _ProductSearchPageState();
// }

// class _ProductSearchPageState extends State<ProductSearchPage> {
//   // 1. Controllers & State Variables
//   final TextEditingController _barcodeController = TextEditingController(text: '0048151623426');
  
//   bool _isLoading = false;
//   String? _errorMessage;
//   Product? _fetchedProduct;

//   @override
//   void dispose() {
//     _barcodeController.dispose();
//     super.dispose();
//   }

//   // 2. API Integration Function
//   Future<void> _fetchProduct() async {
//     final barcode = _barcodeController.text.trim();
//     if (barcode.isEmpty) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//       _fetchedProduct = null;
//     });

//     try {
//       final ProductQueryConfiguration configuration = ProductQueryConfiguration(
//         barcode,
//         language: OpenFoodFactsLanguage.ENGLISH,
//         fields: [
//           ProductField.NAME,
//           ProductField.BRANDS,
//           ProductField.IMAGE_FRONT_URL,
//           ProductField.INGREDIENTS_TEXT,
//           ProductField.NUTRIMENTS,
//         ],
//         version: ProductQueryVersion.v3,
//       );

//       final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(configuration);

//       if (result.status == ProductResultV3.statusSuccess && result.product != null) {
//         setState(() {
//           _fetchedProduct = result.product;
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Product not found for barcode: $barcode';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to fetch data: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // 3. UI Widget Tree Construction
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('OpenFoodFacts Lookup'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search Control Bar (Input + Button)
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _barcodeController,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: 'Barcode',
//                       hintText: 'e.g. 0048151623426',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: _isLoading ? null : _fetchProduct,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//                   ),
//                   child: const Text('Fetch'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // Dynamic Content Section
//             Expanded(
//               child: _buildBodyContent(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper method to keep main build function clean
//   Widget _buildBodyContent() {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (_errorMessage != null) {
//       return Center(
//         child: Text(
//           _errorMessage!,
//           style: const TextStyle(color: Colors.red, fontSize: 16),
//           textAlign: TextAlign.center,
//         ),
//       );
//     }

//     if (_fetchedProduct == null) {
//       return const Center(
//         child: Text(
//           'Enter a barcode above and click Fetch.',
//           style: TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//       );
//     }

//     // Display fetched information inside a scrollable card
//     return SingleChildScrollView(
//       child: Card(
//         elevation: 3,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (_fetchedProduct!.imageFrontUrl != null)
//                 Center(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       _fetchedProduct!.imageFrontUrl!,
//                       height: 180,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 16),
//               Text(
//                 _fetchedProduct!.productName ?? 'Unnamed Product',
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Brand: ${_fetchedProduct!.brands ?? 'Unknown'}',
//                 style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//               ),
//               const Divider(height: 24),
//               const Text(
//                 'Ingredients:',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 _fetchedProduct!.ingredientsText ?? 'No ingredients listed.',
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
// import './home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mindful Calories',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 21, 105, 214)),
      ),
      
      home: Scaffold( 
        appBar: AppBar(title: const Text('Home')),
        body : Center ( 
          child: Scanner(),
          ),
      ),
    );
  }
}

class Scanner extends StatelessWidget {
  const Scanner({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        final capture = await showAiBarcodeScanner(context);
        debugPrint(capture?.firstRawValue); // null if the user backed out
      },
      child: const Text('Scan'),
    );
  }
}


// template code below
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
            
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// template for ai bar code scanner
// class ScanButton extends StatelessWidget {
//   const ScanButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FilledButton(
//       onPressed: () async {
//         final capture = await showAiBarcodeScanner(context);
//         debugPrint(capture?.firstRawValue); // null if the user backed out
//       },
//       child: const Text('Scan'),
//     );
//   }
// }

// ai bar code scanner template from medium
// class BarcodeScannerPage extends StatelessWidget {
//   const BarcodeScannerPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AiBarcodeScanner(
//       onDetect: (capture) {
//         final barcode = capture.barcodes.first;

//         debugPrint(
//           barcode.rawValue ?? "No barcode detected",
//         );
//       },
//     );
//   }
// }
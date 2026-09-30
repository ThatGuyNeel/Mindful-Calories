# Mindful Calories

This app is designed for the calorie conscious. Nutritional information often times is buried along with the other information that comes on the packaging. This application eliminates that problem by utilizing a scanner to scan the barcode on the product and present nutritional information along with indicators detailing whether a product has low calorie density along with high protein content, fat content and calorie density. 

The project makes use of the Open Food Facts API to retrieve information from their servers. 

## Visuals 
<img width="1080" height="2280" alt="Screenshot_20260930-203302" src="https://github.com/user-attachments/assets/3efd4320-ec4e-4baf-a882-a41da82aaa7d" />
<img width="1080" height="2280" alt="Screenshot_20260930-203611" src="https://github.com/user-attachments/assets/fc848bb2-2d7a-43f4-a995-ac80f6eb7a5a" />
<img width="1080" height="2280" alt="Screenshot_20260930-203335" src="https://github.com/user-attachments/assets/00ee38fe-090e-459d-b5c0-2a1667139134" />


## Setup 

1. Follow the official guide to install Flutter on your device and complete the setup: (https://docs.flutter.dev/install/quick) 
2. Clone the repository
   ``` bash
   git clone https://github.com/ThatGuyNeel/Mindful-Calories.git
   ```
4. Open the project in your IDE and run the below command to fetch dependencies
   ``` bash
   flutter pub get 
   ```
5. Check the environment
   ``` bash
   flutter doctor
   ```
7. Running the project:
   ```bash
   flutter run
   ```
   In bash / powershell navigate to the main file located in the lib folder. (main.dart)
   A prompt to select the edge device will show a menu in terminal.
   This project runs on android and web.
   For android: Enable USB debugging on your device and set Wireless Debugging to be on as well.

## Flutter and Dart Versions
| Tool | Version |
|---|---|
| Flutter | 3.47.5 |
| Dart | 3.13.4 |

### Using the app
 
1. Scan: tap Scan Product, point the camera at a barcode, and the product detail screen opens.
2. Search by category: type a category and press Enter or the search icon. Results show name, calories and protein per 100g.
3. Recent products: scanned products are saved locally (up to 10) and shown on the home screen. Tap Clear to remove them.
4. Theme: open the settings icon to switch between System, Light and Dark.
   
# Architecture 

### Layers
 
- **UI (screens):** `ConsumerStatefulWidget`s that watch `productNotifierProvider` and rebuild on state changes. 
- **State (providers):** `ProductNotifier` extends `StateNotifier<ProductState>`. `ProductState` is an immutable class holding recent products, search results, the selected product, loading and error state, and the current query. Updates go through `copyWith`.
- **Services:** `ApiService` wraps the `http` client, applies timeouts, parses JSON and converts failures into `ApiException` / `TimeoutException`.
- **Persistence:** `shared_preferences` stores the 10 most recent scanned products as JSON strings under the `recent_products` key and allows for offline viewing.

**Scan flow:** barcode captured -> `scanBarcode` -> `fetchProductByBarcode` -> product saved to recents -> navigate to detail screen.
 
**Search flow:** user submits category -> `searchProducts` -> `searchProductsByName` -> results stored in state -> list rendered on the home screen.
 
## Packages
 
| Package | Purpose |
|---|---|
| [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) | State management and dependency injection |
| [`http`](https://pub.dev/packages/http) | REST calls to the Open Food Facts API |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Local storage of recent products |
| [`ai_barcode_scanner`](https://pub.dev/packages/ai_barcode_scanner) | Camera-based barcode scanning |
 
Dart core libraries used: `dart:convert` for JSON encoding/decoding. Flutter's `foundation` library is used for `debugPrint`.
 
Time log: 
| Task | Time |
|---|---|
| Setup | 3h |
| Data Layer | 4h |
| UI | 2h | 
| Tests | 1h |

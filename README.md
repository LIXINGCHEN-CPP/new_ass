
<p align="center">
  <img src="assets/images/app_logo.svg" alt="eGrocery Logo" />
</p>

## Project Overview

This Flutter application uses the **Material** component library along with third-party packages such as `flutter_svg` and `cached_network_image` to build its UI. All UI-related source code is located under the `lib` directory. The high-level structure is as follows:

* **Core Module (`lib/core`)**: Defines global constants, routing, shared components (themes, icons, colors, defaults, etc.).
* **Views Module (`lib/views`)**: Organized into feature subdirectories (`home`, `menu`, `cart`, `auth`, `profile`, etc.), each containing page (`*Page.dart`) and widget files.
* **Entrypoint (`lib/views/entrypoint`)**: `EntryPointUI` manages bottom navigation and page transitions.

All navigation uses `Navigator.pushNamed` with routes declared in `lib/core/routes/app_routes.dart`.

## Core Module (`lib/core`)

* **`constants/app_colors.dart`**, **`app_defaults.dart`**, **`app_images.dart`**, **`app_icons.dart`**: Global color definitions (e.g. `AppColors.primary`), spacing and duration defaults, asset paths for images and icons.
* **`constants/app_routes.dart`**: String constants listing every route (`/home`, `/login`, `/cart`, etc.), used application-wide.
* **`constants/constants.dart`**: Barrel file exporting all constant files and defining mock data sets (`Dummy.products`, `Dummy.bundles`) for demonstration.
* **`routes/on_generate_route.dart`**: A route generator that matches route names to page widgets via a `switch` statement.
* **`utils/app_util.dart`**: Utility functions (e.g. `dismissKeyboard`) that do not directly affect layout.
* **Shared Components (`core/components`)**: Reusable UI widgets, including:

    * `AppBackButton`: Custom back arrow button for AppBars.
    * `NetworkImageWithLoader`: Network image widget with a loading placeholder.
    * `ProductTileSquare` & `BundleTileSquare`: Square card widgets for displaying products and bundle deals.
    * `TitleAndActionButton`: A header widget with a title and a "View All" action button.
    * `ReviewRowButton` & `BuyNowRowButton`: Row buttons on product detail pages for reviews and purchase.
    * `PriceAndQuantityRow`: Displays price, original price, and quantity controls.
    * `AppRadio`: Custom radio button used for address selection and defaults.
    * Other helpers like `skeleton.dart` for placeholders and the theme file `app_themes.dart`.

These core components are used throughout the app to ensure consistent styling and reuse.

## Entrypoint Page (`lib/views/entrypoint`)

* **`entrypoint_ui.dart`**: The app’s main entry point with a `Scaffold` that contains a floating cart button and a bottom navigation bar. Uses `PageTransitionSwitcher` from the `animations` package to animate between five pages: `HomePage`, `MenuPage`, `CartPage`, `SavePage`, and `ProfilePage`. The bottom bar is rendered by `AppBottomNavigationBar`, and its items by `BottomAppBarItem`.
* **`components/app_navigation_bar.dart`** & **`bottom_app_bar_item.dart`**: Custom widgets for the bottom navigation layout. `AppBottomNavigationBar` uses `BottomAppBar`, positioning “Home/Menus” on the left and “Wishlist/Profile” on the right around the floating button.

Tapping a tab updates the `currentIndex` to switch pages without reloading them.

## Home Page (`lib/views/home`)

* **`home_page.dart`**: A vertically scrollable `CustomScrollView` with a floating `SliverAppBar` (menu button on the left, search on the right). Main sections:

    * **`AdSpace`**: Full-width banner using `NetworkImageWithLoader`.
    * **`PopularPacks`**: Horizontal list of `BundleTileSquare` cards under a `TitleAndActionButton` header. Tapping "View All" opens `PopularPackPage`.
    * **`OurNewItem`**: Similar horizontal list of `ProductTileSquare` cards under a "Our New Items" header linking to `NewItemPage`.
* **Bundle Creation & Details**:

    * **`bundle_create_page.dart`**: Lets users build custom packs via `FoodCategories` (horizontal chips), `ProductGridView`, and `BottomActionBar` showing selections and total price.
    * **`bundle_product_details_page.dart`**: Displays a bundle’s details with `ProductImagesSlider`, `PriceAndQuantityRow`, metadata, `PackDetails`, `ReviewRowButton`, and `BuyNowRow`.
    * **`popular_pack_page.dart`**: Full grid of bundles with a bottom button to create a custom pack.
* **New Items & Product Details**:

    * **`new_item_page.dart`**: Grid of new products using `ProductTileSquare`.
    * **`product_details_page.dart`**: Shows a single product with a slider, details, description, review row, and a bottom purchase bar.
* **Category & Search**:

    * **`category_page.dart`**: Shows a grid of products in a selected category.
    * **`search_page.dart`**: Header search field with filters and a list of recent searches.
    * **`search_result_page.dart`**: Search input with result count and a product grid.

## Menu Page (`lib/views/menu`)

* **`menu_page.dart`**: Grid of `CategoryTile` widgets for quick access to features like “My Orders” or “Favorites”.
* **`CategoryTile`**: Custom circular image + label widget reused across menu and home.

## Cart & Checkout (`lib/views/cart`)

* **`cart_page.dart`**: Lists `SingleCartItemTile` items, a coupon field, and total summary with a checkout button.
* **`checkout_page.dart`**: Multi-section checkout flow including:

    * **Address Selector** (`AddressCard` + `AppRadio`).
    * **Payment Method** (`PaymentCardTile`).
    * **Card Details Form**.
    * **Pay Now** button.

## Authentication & Profile (`lib/views/auth`, `lib/views/profile`)

* **Onboarding & Login**: `onboarding_page.dart`, `intro_login_page.dart`, `login_or_signup_page.dart`, `login_page.dart`, `forget_password_page.dart`, `password_reset_page.dart`.
* **Sign Up & Verification**: `sign_up_page.dart`, `number_verification_page.dart` with `VerifiedDialog`.
* **Profile**: `profile_page.dart` with `ProfileHeader`, `ProfileHeaderOptions`, `ProfileMenuOptions`.
* **Address Management**: `address_page.dart`, `new_address_page.dart` using `AddressTile` and `AppRadio`.
* **Coupons & Orders**: `coupon` and `order` submodules under `views/profile`.
* **Payment Methods & Settings**: `payment_method_page.dart`, `profile settings` pages with `AppRadio` and switches.

## Wishlist (`lib/views/save`)

* **`save_page.dart`**: Displays either a list of saved products or an `EmptySavePage` with a prompt to add items.

## Running the App

Before running the app, clone the repository and navigate into the project folder:

```bash
git clone https://github.com/7Packanyet/Mobile_Application_Assignment_Flutter.git
cd Mobile_Application_Assignment_Flutter
```

Then execute the Flutter commands:

```bash
flutter clean
flutter pub get
flutter run
```

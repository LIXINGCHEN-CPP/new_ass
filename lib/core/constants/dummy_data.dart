import '../models/dummy_bundle_model.dart';
import '../models/dummy_product_model.dart';

class Dummy {
  /// List Of Dummy Products
  static List<ProductModel> products = [
    ProductModel(
      name: 'Perry\'s Ice Cream Banana',
      weight: '800 gm',
      cover: 'https://i.imgur.com/6unJlSL.png',
      images: ['https://i.imgur.com/6unJlSL.png'],
      price: 13,
      mainPrice: 15,
    ),
    ProductModel(
      name: 'Vanilla Ice Cream Banana',
      weight: '500 gm',
      cover: 'https://i.imgur.com/oaCY49b.png',
      images: ['https://i.imgur.com/oaCY49b.png'],
      price: 12,
      mainPrice: 15,
    ),
    ProductModel(
      name: 'Beef',
      weight: '1 Kg',
      cover: 'https://i.imgur.com/5wghZji.png',
      images: ['https://i.imgur.com/5wghZji.png'],
      price: 15,
      mainPrice: 18,
    ),
    ProductModel(
      name: 'Mushroom',
      weight: '500 gm',
      cover: 'https://i.imgur.com/XyAQYNX.jpeg',
      images: ['https://i.imgur.com/XyAQYNX.jpeg'],
      price: 15,
      mainPrice: 20,
    ),
    ProductModel(
      name: 'Fresh Milk',
      weight: '1 Kg',
      cover: 'https://i.imgur.com/9GqopLf.png',
      images: ['https://i.imgur.com/9GqopLf.png'],
      price: 15,
      mainPrice: 18,
    ),
    ProductModel(
      name: 'Pencil Case',
      weight: '1 Pair',
      cover: 'https://i.imgur.com/k7MfSmE.jpeg',
      images: ['https://i.imgur.com/k7MfSmE.jpeg'],
      price: 15,
      mainPrice: 17,
    ),
    ProductModel(
      name: 'Tray of Eggs',
      weight: '1 Kg',
      cover: 'https://i.imgur.com/FFnxmbr.png',
      images: ['https://i.imgur.com/FFnxmbr.png'],
      price: 15,
      mainPrice: 18,
    ),
    ProductModel(
      name: 'Green Vegetables',
      weight: '500 gm',
      cover: 'https://i.imgur.com/gdCzhXW.jpeg',
      images: ['https://i.imgur.com/gdCzhXW.jpeg'],
      price: 12,
      mainPrice: 15,
    ),
  ];

  /// List Of Dummy Bundles
  static List<BundleModel> bundles = [
    BundleModel(
      name: 'Vegetables Pack',
      cover: 'https://i.imgur.com/Y0IFT2g.png',
      itemNames: ['Onion, Carrot, etc.'],
      price: 35,
      mainPrice: 50.32,
    ),
    BundleModel(
      name: 'Gardening Pack',
      cover: 'https://i.imgur.com/RQ3gtlc.png',
      itemNames: ['Hoe, Scissors, etc.'],
      price: 35,
      mainPrice: 45,
    ),
    BundleModel(
      name: 'Medium Spices Pack',
      cover: 'https://i.postimg.cc/qtM4zj1K/packs-2.png',
      itemNames: ['Onion, Oil, Salt'],
      price: 150,
      mainPrice: 200,
    ),
    BundleModel(
      name: 'Daily Essentials',
      cover: 'https://i.postimg.cc/MnwW8WRd/pack-1.png',
      itemNames: ['Vegetables, Wine, etc.'],
      price: 29,
      mainPrice: 37,
    ),
    BundleModel(
      name: 'Spice Pack',
      cover: 'https://i.imgur.com/fI1BtZZ.jpeg',
      itemNames: ['Black pepper, Cinnamon, etc.'],
      price: 11.5,
      mainPrice: 20,
    ),
    BundleModel(
      name: 'Stationery Pack',
      cover: 'https://i.imgur.com/tk4JddK.jpeg',
      itemNames: ['Pen, Ruler, etc.'],
      price: 35,
      mainPrice: 50.32,
    ),
    BundleModel(
      name: 'Cosmetic Pack',
      cover: 'https://i.miji.bid/2025/05/22/0963b911fff4c23a72d1eef2e07c053b.webp',
      itemNames: ['Onion, Oil, Salt'],
      price: 500,
      mainPrice: 550,
    ),
    BundleModel(
      name: 'First Aid Kit',
      cover: 'https://i.imgur.com/HmoQQIz.jpeg',
      itemNames: ['Gauze, Medicine bottle, etc.'],
      price: 35,
      mainPrice: 50.32,
    ),
  ];
}

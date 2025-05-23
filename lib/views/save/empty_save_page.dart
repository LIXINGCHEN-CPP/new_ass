import 'package:flutter/material.dart';

// 如果你的包名是 package:grocery，请这样导入；如果不是，请替换成你自己项目的包名
import 'package:grocery/views/home/new_item_page.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/app_defaults.dart';

class EmptySavePage extends StatelessWidget {
  const EmptySavePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // 演示图片
          SizedBox(
            width: width * 0.7,
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding * 2),
              child: AspectRatio(
                aspectRatio: 1,
                child: NetworkImageWithLoader(
                  // 这里使用位置参数，不要写 imageUrl:
                  'https://i.imgur.com/mbjap7k.png',
                ),
              ),
            ),
          ),

          // 标题
          Text(
            'Oppss!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          // 副标题
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Sorry, you have no product in your wishlist',
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),

          // “Start Adding” 按钮
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding * 2),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // 如果你的 NewItemPage 类使用了 const 构造，保留 const
                      builder: (_) => const NewItemsPage(),
                    ),
                  );
                },
                child: const Text('Start Adding'),
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

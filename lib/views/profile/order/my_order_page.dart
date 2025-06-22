import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/providers/user_provider.dart';
import 'components/custom_tab_label.dart';
import 'components/tab_all.dart';
import 'components/tab_completed.dart';
import 'components/tab_running.dart';

class AllOrderPage extends StatefulWidget {
  const AllOrderPage({super.key});

  @override
  State<AllOrderPage> createState() => _AllOrderPageState();
}

class _AllOrderPageState extends State<AllOrderPage> {
  @override
  void initState() {
    super.initState();
    // Load orders when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      
      
      if (userProvider.isLoggedIn && userProvider.currentUser?.id != null) {
        orderProvider.loadOrdersByUserId(userProvider.currentUser!.id!);
      } else {
        orderProvider.loadOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('My Order'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                return TabBar(
                  physics: const NeverScrollableScrollPhysics(),
                  tabs: [
                    CustomTabLabel(
                      label: 'All', 
                      value: '(${orderProvider.orders.length})',
                    ),
                    CustomTabLabel(
                      label: 'Running', 
                      value: '(${orderProvider.runningOrdersCount})',
                    ),
                    CustomTabLabel(
                      label: 'Previous', 
                      value: '(${orderProvider.completedOrdersCount})',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        body: Container(
          color: AppColors.cardColor,
          child: const TabBarView(
            children: [
              AllTab(),
              RunningTab(),
              CompletedTab(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:jedi_pixels_products/helpers/app_helpers.dart';
import '../../models/product/product_model.dart';
import 'products_listview_item1.dart';
import 'products_listview_item2.dart';
import 'products_listview_item_card.dart';

class ProductsListView extends StatelessWidget {
  const ProductsListView({
    Key? key,
    required this.productsList,
    required this.scrollController,
    required this.selectedListType,
  }) : super(key: key);

  final List<ProductModel> productsList;
  final ScrollController scrollController;
  final SelectedListType selectedListType;

  @override
  Widget build(BuildContext context) {
    // return CustomScrollView(
    //   controller: scrollController,
    //   physics: const AlwaysScrollableScrollPhysics(),
    //   slivers: [
    //     const SliverToBoxAdapter(
    //       child: Icon(
    //         Icons.flutter_dash,
    //         size: 48,
    //       ),
    //     ),
    //     SliverList(
    //       delegate: SliverChildBuilderDelegate(
    //         (BuildContext context, int index) {
    //    debugPrint('Build: ${productsList.length}');
    //           switch (selectedListType) {
    //             case SelectedListType.card:
    //               return ProductsListViewCard(
    //                   productModel: productsList, index: index);
    //             case SelectedListType.list1:
    //               return ProductsListViewItem1(
    //                   productModel: productsList, index: index);
    //             case SelectedListType.list2:
    //               return ProductsListViewItem2(
    //                   productModel: productsList, index: index);
    //           }
    //         },
    //         childCount: productsList.length,
    //       ),
    //     )
    //   ],
    // );

    //TODO: Create with a ListView.builder and ListView.separeted to test performance
    debugPrint('Build: ${productsList.length}');
    switch (selectedListType) {
      case SelectedListType.card:
        return ListView.builder(
            itemCount: productsList.length,
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int indexImages) {
              debugPrint('Build: Card - ListView.builder $indexImages');
              return ProductsListViewCard(productModel: productsList, index: indexImages);
            });
      case SelectedListType.list1:
        return ListView.separated(
            itemCount: productsList.length,
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int indexImages) {
              debugPrint('Build: List 1 - ListView.separated $indexImages');
              return ProductsListViewItem1(productModel: productsList, index: indexImages);
            },
            separatorBuilder: (BuildContext context, int indexImages) => const Divider(),
            );
      case SelectedListType.list2:
        return ListView.separated(
          itemCount: productsList.length,
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int indexImages) {
            debugPrint('Build: List 2 - ListView.separated $indexImages');
            return ProductsListViewItem1(productModel: productsList, index: indexImages);
          },
          separatorBuilder: (BuildContext context, int indexImages) => const Divider(),
        );
    }
  }
}

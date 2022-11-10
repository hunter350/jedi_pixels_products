import 'package:flutter/material.dart';
import 'package:jedi_pixels_products/models/product/product_model.dart';
import 'package:jedi_pixels_products/services/auth/auth_service.dart';
import 'package:jedi_pixels_products/services/connection_service.dart';
import 'package:jedi_pixels_products/services/product/product_list_service.dart';
import 'package:jedi_pixels_products/widgets/products/products_listview.dart';
import 'package:jedi_pixels_products/widgets/status_message.dart';

import '../helpers/app_helpers.dart';
import '../services/product/product_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ConnectionService connectionService;
  late ProductService  productService;
  AuthServiceResponse authServiceResponse = AuthServiceResponse();
  final ProductListService productListService = ProductListService();
  final ScrollController scrollController = ScrollController();
  ValueNotifier<SelectedListType> selectedListType = ValueNotifier<SelectedListType>(SelectedListType.card);

  @override
  void initState() {
    super.initState();
    //AFTER....
    connectionService = ConnectionService(productListService);
    connectionService.watchConnectivity(productListService);
    productService = ProductService(productListService);
    getAuth();
    //Check if scroll has reached the bottom, then retrieve the next 10 records/products
    scrollController.addListener(() {
      if (scrollController.offset ==
              scrollController.position.maxScrollExtent &&
          !productListService.isProductLoading) {
        getProducts();
      }
    });
  }

  @override
  void dispose() {
    //BEFORE...
    connectionService.cancel();
    productListService.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<bool> checkInternetConnection() async {
    productListService.internetConnectionAvailability =
        await connectionService.isInternetConnectionAvailable();
    if (!productListService.internetConnectionAvailability) {
      productListService.internetConnectionAvailability = false;
      productListService.isProductLoading = false;
      productListService
          .addProductError('Internet connection is currently not available');
    }
    return productListService.internetConnectionAvailability;
  }

  Future<void> getAuth() async {
    productListService.internetConnectionAvailability =
        await checkInternetConnection();

    if (!productListService.internetConnectionAvailability) {
      return;
    }

//Authenticate User and look for credential errors
    authServiceResponse = await AuthService.login();
    if (authServiceResponse.statusCode == 200 &&
        authServiceResponse.error != 'Error Response') {
      productListService.isProductLoading = false;
      getProducts();
    } else {
      productListService.isProductLoading = false;
      final String error = authServiceResponse.error;
      productListService.addProductError(error);
    }
  }

  Future<void> getProducts() async {
    if (productListService.isProductLoading) {
      return;
    }
    productListService.isProductLoading = true;

    //Make sure we did not loose connectivity since our last products fetch
    productListService.internetConnectionAvailability =
    await checkInternetConnection();
    if(!productListService.internetConnectionAvailability){
      return ;
    }

    //Future Enchancement: Check if authServiceResponse has not expired, otherwise re-Authenticated
    if(authServiceResponse.token.isEmpty){
      getAuth();
      return ;
    }

    //Retrieve the next products
    productService.getProducts(authServiceResponse.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
            initialData: const [],
            stream: productListService.getProductList,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                final productList = snapshot.data as List<ProductModel>;
                return Text('Products: ${productList.length}');
              }else{
                return const Text('Products');
              }
            }),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: getProducts,
              icon: const Icon(Icons.refresh)),
          const SizedBox(width: 4),
          ValueListenableBuilder(
              valueListenable: selectedListType,
              builder: (BuildContext context, SelectedListType value, Widget? child){
               return DropdownButtonHideUnderline(
                 child: DropdownButton(
                     value: selectedListType.value.name.toLowerCase(),
                     focusColor: Colors.transparent,
                     style: TextStyle(color: Theme.of(context).primaryColorLight),
                     dropdownColor: Theme.of(context).backgroundColor,
                     items: [
                       DropdownMenuItem(
                         value: 'card',
                           child: Row(
                             children: const [
                               Icon(Icons.view_agenda_outlined),
                               SizedBox(width: 4),
                               Text('Card')
                             ],
                           )),
                       DropdownMenuItem(
                           value: 'list1',
                           child: Row(
                             children: const [
                               Icon(Icons.view_day_outlined),
                               SizedBox(width: 4),
                               Text('List 1')
                             ],
                           )),
                       DropdownMenuItem(
                           value: 'list2',
                           child: Row(
                             children: const [
                               Icon(Icons.view_list_outlined),
                               SizedBox(width: 4),
                               Text('List 2')
                             ],
                           )),
                     ],
                     onChanged: (selectedValue){
                       if(selectedValue != selectedListType.value.name.toLowerCase()){
                         selectedListType.value = SelectedListType.values.firstWhere((element) =>
                         element.name == selectedValue.toString().toLowerCase());
                         productListService.refreshCurrentListProducts();
                       }
                     }
                 ),
               );
              }
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          initialData: const [],
          stream: productListService.getProductList,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!productListService.internetConnectionAvailability) {
              return const StatusMessage(
                  message: 'Internet connection is currently not available',
                  bannerMessage: 'none',
                  bannerColor: Colors.yellow,
                  textColor: Colors.black);
            }

            //TODO: check snapshot connection state
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.active:
                if (snapshot.hasError) {
                  return StatusMessage(
                      message: '${snapshot.error}',
                      bannerMessage:
                          !productListService.internetConnectionAvailability
                              ? 'none'
                              : 'error',
                      bannerColor:
                          !productListService.internetConnectionAvailability
                              ? Colors.yellow
                              : Colors.red,
                      textColor:
                          !productListService.internetConnectionAvailability
                              ? Colors.black
                              : Colors.white);
                } else if (snapshot.hasData) {
                 final productsList = snapshot.data as List<ProductModel>;

                 return ProductsListView(
                     productsList: productsList,
                     scrollController: scrollController,
                     selectedListType: selectedListType.value);
                }else{
                  return const StatusMessage(
                      message: 'Not able to retrieve products',
                      bannerMessage: 'error',
                      bannerColor: Colors.red,
                      textColor: Colors.white
                  );
                }
            }
            return const Text('Hello');
          },
        ),
      ),
    );
  }
}

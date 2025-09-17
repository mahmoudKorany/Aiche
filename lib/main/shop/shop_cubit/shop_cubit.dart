import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/constants/constants.dart';
import 'package:aiche/core/shared/constants/url_constants.dart';
import 'package:aiche/main/shop/Model/collection_model.dart';
import 'package:aiche/main/shop/Model/product_model.dart';
import 'package:aiche/main/shop/shop_cubit/shop_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/dio/dio.dart';

class ShopCubit extends Cubit<ShopState> {
  ShopCubit() : super(ShopInitial());
  static ShopCubit get(context) => BlocProvider.of(context);

  //GET ALL PRODUCTS
  List<ProductModel> allProducts = [];

  Future<void> getAllProducts() async {
    allProducts = [];
    emit(GetAllProductsLoadingState());

    final response = await DioHelper.getData(
      url: UrlConstants.getAllProducts,
      token: token,
      query: {},
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage =
          response.data['message'] ?? 'Failed to load products';
      emit(GetAllProductsErrorState(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      for (var element in response.data['data']) {
        if (element['name'] != 'p_test' &&
            element['name'] != 'last test' &&
            element['name'] != 'clt test') {
          allProducts.add(ProductModel.fromJson(element));
        }
      }

      emit(GetAllProductsSuccessState());
    } else {
      String errorMessage = 'Failed to load products';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(GetAllProductsErrorState(errorMessage));
    }
  }

  //GET ALL COLLECTIONS
  List<CollectionModel> allCollections = [];
  Future<void> getAllCollections() async {
    allCollections = [];
    emit(GetAllCollectionsLoadingState());

    final response = await DioHelper.getData(
      url: UrlConstants.getAllCollections,
      token: token,
      query: {},
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage =
          response.data['message'] ?? 'Failed to load collections';
      emit(GetAllCollectionsErrorState(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      for (var element in response.data['data']) {
        allCollections.add(CollectionModel.fromJson(element));
      }
      emit(GetAllCollectionsSuccessState());
    } else {
      String errorMessage = 'Failed to load collections';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(GetAllCollectionsErrorState(errorMessage));
    }
  }

  // Place Order
  Future<void> placeProductOrder({
    required int productId,
    required String phone,
  }) async {
    emit(PlaceOrderLoadingState());

    final response = await DioHelper.postData(
      url: UrlConstants.placeProductOrder,
      token: token,
      data: {
        'phone': phone,
        'product_id': productId,
      },
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage =
          response.data['message'] ?? 'Failed to place product order';
      emit(PlaceOrderErrorState(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      showToast(
          msg: 'Product order created successfully', state: MsgState.success);
      emit(PlaceOrderSuccessState());
    } else {
      String errorMessage = 'Failed to place product order';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(PlaceOrderErrorState(errorMessage));
    }
  }

  Future<void> placeCollectionOrder({
    required int collectionId,
    required String phone,
  }) async {
    emit(PlaceOrderLoadingState());

    final response = await DioHelper.postData(
      url: UrlConstants.placeCollectionOrder,
      token: token,
      data: {
        'phone': phone,
        'collection_id': collectionId,
      },
    );

    // Check if the response contains an error
    if (response.data != null &&
        response.data is Map &&
        response.data['error'] == true) {
      String errorMessage =
          response.data['message'] ?? 'Failed to place collection order';
      emit(PlaceOrderErrorState(errorMessage));
      return;
    }

    if (response.statusCode == 200) {
      showToast(
          msg: 'Collection order created successfully',
          state: MsgState.success);
      emit(PlaceOrderSuccessState());
    } else {
      String errorMessage = 'Failed to place collection order';
      if (response.data != null &&
          response.data is Map &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      }
      emit(PlaceOrderErrorState(errorMessage));
    }
  }
}

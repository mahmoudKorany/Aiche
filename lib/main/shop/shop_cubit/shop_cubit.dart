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
    try {
      DioHelper.getData(
        url: UrlConstants.getAllProducts,
        token: token,
        query: {},
      ).then((value) {
        for (var element in value.data['data']) {
          allProducts.add(ProductModel.fromJson(element));
        }
        emit(GetAllProductsSuccessState());
      });
      // Mock data
      emit(GetAllProductsSuccessState());
    } catch (error) {
      emit(GetAllProductsErrorState(error.toString()));
    }
  }

  //GET ALL COLLECTIONS
  List<CollectionModel> allCollections = [];
  Future<void> getAllCollections() async {
    allCollections = [];
    emit(GetAllCollectionsLoadingState());
    try {
      DioHelper.getData(
        url: UrlConstants.getAllCollections,
        token: token,
        query: {},
      ).then((value) {
        for (var element in value.data['data']) {
          allCollections.add(CollectionModel.fromJson(element));
        }
        emit(GetAllCollectionsSuccessState());
      });
      // Mock data
      emit(GetAllCollectionsSuccessState());
    } catch (error) {
      emit(GetAllCollectionsErrorState(error.toString()));
    }
  }
}

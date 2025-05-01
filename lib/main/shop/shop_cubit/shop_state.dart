abstract class ShopState {}

class ShopInitial extends ShopState {}

class GetAllProductsLoadingState extends ShopState {}
class GetAllProductsSuccessState extends ShopState {}
class GetAllProductsErrorState extends ShopState {
  final String error;

  GetAllProductsErrorState(this.error);
}
class GetAllCollectionsLoadingState extends ShopState {}
class GetAllCollectionsSuccessState extends ShopState {}
class GetAllCollectionsErrorState extends ShopState {
  final String error;

  GetAllCollectionsErrorState(this.error);
}

// Order states
class PlaceOrderLoadingState extends ShopState {}
class PlaceOrderSuccessState extends ShopState {}
class PlaceOrderErrorState extends ShopState {
  final String error;

  PlaceOrderErrorState(this.error);
}
class ChangeSelectedProductState extends ShopState {}

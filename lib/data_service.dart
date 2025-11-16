import 'package:mmsn/app/AppImages.dart';

class DataService {
  DataService._();

  // Keep only carousel images for local assets
  final List<String> carouselImages = [
    AppImages.carouselImages1,
    AppImages.carouselImages2,
    AppImages.carouselImages3, 
    AppImages.carouselImages4,
  ];

  static DataService? _instance;

  static DataService get instance {
    return _instance ??= DataService._();
  }

  // All family-related methods have been moved to FamilyApiService
  // Remove all mock data and methods related to families
}
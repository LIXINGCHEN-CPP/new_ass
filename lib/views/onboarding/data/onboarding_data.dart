import '../../../core/constants/app_images.dart';
import 'onboarding_model.dart';

class OnboardingData {
  static List<OnboardingModel> items = [
    OnboardingModel(
      imageUrl: AppImages.onboarding1,
      headline: 'Discover popular and new products',
      description:
          'Browse trending items and new arrivals for top deals and fresh inspiration.',
    ),
    OnboardingModel(
      imageUrl: AppImages.onboarding2,
      headline: 'Endless variety and custom packs',
      description:
          'Mix and match products across categories to create your perfect pack and shop easily.',
    ),
    OnboardingModel(
      imageUrl: AppImages.onboarding3,
      headline: 'Fast and reliable delivery',
      description:
          'Track your orders in real-time and enjoy swift doorstep delivery.',
    ),
  ];
}

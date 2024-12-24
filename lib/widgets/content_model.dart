class UnBoardingContent {
  String image;
  String title;
  String description;

  UnBoardingContent(
      {required this.description, required this.image, required this.title});
}

List<UnBoardingContent> contents = [
  UnBoardingContent(
      description: 'Pick your Grocery from our menu',
      image: 'assets/images/screen1.jpg',
      title: 'Select the best menu'),
  UnBoardingContent(
      description: 'You can pay cash on delivery',
      image: 'assets/images/screen2.jpg',
      title: 'Cash on Delivery Payment'),
  UnBoardingContent(
      description: 'Deliver your food at doorstep',
      image: 'assets/images/screen3.jpg',
      title: 'Quick Delivery Service')
];

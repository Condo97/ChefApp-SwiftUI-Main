# ChefApp

Welcome to ChefApp, an innovative application designed to streamline your cooking experiences. This app offers a range of features to help users turn their culinary inspirations into reality, manage recipes, and even interact with food-related content on platforms like TikTok. This README will guide you through the setup and main functionalities of ChefApp.

## Table of Contents:
- [Installation](#installation)
- [Features](#features)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

## Installation

To install and run ChefApp, you will need to have [Xcode](https://developer.apple.com/xcode/) installed on your macOS. Follow the steps below:

1. Clone this repository to your local machine:
   ```
   git clone https://github.com/Condo97/ChefApp.git
   ```
2. Navigate to the `ChefApp` directory:
   ```
   cd ChefApp
   ```
3. Open the Xcode project:
   ```
   open ChefApp.xcodeproj
   ```
4. Run the app in the simulator or on your iOS device by clicking the Run button in Xcode or pressing `Cmd + R`.

## Features

ChefApp comes packed with a variety of features:

- **Recipe Management**: Create and manage your recipes with ease.
- **Ingredient Parsing**: Parse ingredients from text inputs or images, making sure you have everything you need for your recipes.
- **Food Content Integration**: Interact with food content on TikTok, import recipes, and generate recipe directions and ingredient lists from TikTok videos.
- **User Feedback System**: Includes functionality for likes and dislikes on recipes.
- **Recipe Sharing**: Easily share your recipes with friends and family via URL.
- **In-App Purchases**: Support for purchasing premium subscriptions.

## Dependencies

ChefApp uses the following packages and frameworks:

- **SwiftUI**: For building the app's user interface.
- **Combine**: To handle asynchronous events with declarative code.
- **CoreData**: For managing app's model layer objects.
- **StoreKit**: To handle in-app purchases.
- **PDFKit**: To handle PDF parsing and viewing.
- **GoogleMobileAds**: For displaying ads within the app.
- **Image Processing**: Custom classes for handling image resizing and converting GIFs using UIKit.

## Contributing

We welcome contributions to ChefApp. To contribute, please follow the steps below:

1. Fork this repository.
2. Create a new branch: `git checkout -b feature-branch-name`.
3. Make your changes and commit them: `git commit -m 'Add some feature'`.
4. Push the changes to your fork: `git push origin feature-branch-name`.
5. Submit a pull request to the original repository.

Please ensure your code adheres to the existing format and includes appropriate tests.

## License

ChefApp is licensed under the MIT License. See the `LICENSE` file for more information.

---

Thank you for using ChefApp! If you have any questions or need further assistance, please feel free to contact us at acoundou@gmail.com.

# Apollo Agriculture - Agricultural E-Commerce Platform

A comprehensive Flutter-based e-commerce application for agricultural products and services, built with Firebase backend integration.

## Overview

Apollo Agriculture is a multi-role agricultural platform that connects farmers with essential products, services, and credit facilities. The platform supports various user roles including farmers, finance managers, inventory managers, suppliers, drivers, dispatch managers, and trainers.

## Features

### For Farmers (Main Users)
- Browse and purchase agricultural products (seeds, fertilizers, pesticides, equipment)
- Place orders and track deliveries
- Request and manage credit facilities
- Book training appointments for certifications
- View order history and credit status

### For Finance Managers
- Review and approve/reject credit requests
- Track active loans and payments
- Generate financial reports
- Monitor payment status

### For Inventory Managers
- Manage product inventory
- Track stock levels
- Request products from suppliers
- Monitor low-stock alerts

### For Suppliers
- Supply products to the platform
- Manage product listings
- Track supply orders

### For Drivers
- View assigned delivery orders
- Update delivery status
- Navigate to delivery locations

### For Dispatch Managers
- Assign orders to drivers
- Coordinate deliveries
- Track delivery status

### For Trainers
- Manage training appointments
- Issue certifications
- Schedule training sessions

## Technology Stack

- **Frontend**: Flutter/Dart
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider
- **UI**: Material Design 3

## Project Structure

```
lib/
├── models/           # Data models (User, Product, Order, Credit, Appointment)
├── providers/        # State management providers
├── screens/          # UI screens for different user roles
├── services/         # Firebase and business logic services
├── utils/           # Helper functions and theme
└── widgets/         # Reusable UI components

web/                 # Admin and reporting web interface
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Firebase project configured
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/M17ge/Test-for-absolute-Apollo.git
cd Test-for-absolute-Apollo
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a Firebase project at https://console.firebase.google.com
   - Add Android/iOS apps to your Firebase project
   - Download and place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in respective directories
   - Enable Authentication, Firestore, and Storage in Firebase Console

4. Run the app:
```bash
flutter run
```

## User Roles

The application supports the following user roles:

1. **Farmer** - Main user who purchases products and services
2. **Finance Manager** - Manages credit requests and payments
3. **Inventory Manager** - Manages product inventory
4. **Supplier** - Supplies products to the platform
5. **Driver** - Handles deliveries
6. **Dispatch Manager** - Coordinates deliveries
7. **Trainer** - Provides training and certifications
8. **Admin** - Full platform management

## Firebase Collections

- `users` - User profiles and authentication data
- `products` - Agricultural products catalog
- `orders` - Customer orders
- `credits` - Credit requests and loan management
- `appointments` - Training appointments

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

For support, please contact the development team or open an issue in the repository.

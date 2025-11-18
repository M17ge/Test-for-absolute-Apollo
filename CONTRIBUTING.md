# Contributing to Apollo Agriculture

Thank you for your interest in contributing to Apollo Agriculture! This document provides guidelines for contributing to the project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## How to Contribute

### Reporting Bugs

If you find a bug:

1. Check if the bug has already been reported in Issues
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable
   - Device/platform information
   - Flutter and Dart versions

### Suggesting Features

To suggest a new feature:

1. Check if it's already been suggested
2. Create a new issue with:
   - Clear description of the feature
   - Use cases and benefits
   - Possible implementation approach
   - Any mockups or examples

### Pull Requests

#### Before Starting

1. Fork the repository
2. Create a feature branch from `main`
3. Discuss major changes in an issue first

#### Development Process

1. **Setup**
   ```bash
   git clone https://github.com/YOUR_USERNAME/Test-for-absolute-Apollo.git
   cd Test-for-absolute-Apollo
   flutter pub get
   ```

2. **Create Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Changes**
   - Follow the coding standards
   - Write meaningful commit messages
   - Add tests for new features
   - Update documentation

4. **Test Your Changes**
   ```bash
   flutter test
   flutter analyze
   ```

5. **Commit**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

6. **Push**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create Pull Request**
   - Go to GitHub and create a PR
   - Fill in the PR template
   - Link related issues

## Coding Standards

### Dart Style Guide

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines:

- Use `lowerCamelCase` for variables, methods, and parameters
- Use `UpperCamelCase` for classes, enums, and typedefs
- Use `lowercase_with_underscores` for libraries and file names
- Prefer single quotes for strings
- Use trailing commas for better formatting

### Code Organization

```dart
// 1. Imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 2. Constants
const kDefaultPadding = 16.0;

// 3. Classes
class MyWidget extends StatelessWidget {
  // 4. Constructor
  const MyWidget({Key? key}) : super(key: key);
  
  // 5. Methods
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Widget Guidelines

- Keep widgets small and focused
- Extract reusable widgets
- Use const constructors when possible
- Prefer composition over inheritance

### State Management

- Use Provider for state management
- Keep business logic in providers
- Separate UI from business logic
- Use ChangeNotifier for reactive updates

### Firebase Integration

- Always handle errors
- Use try-catch blocks
- Provide user feedback
- Log errors for debugging

## Testing Guidelines

### Unit Tests

Write unit tests for:
- Models and their methods
- Provider logic
- Utility functions
- Data transformations

Example:
```dart
test('User model should convert to map correctly', () {
  final user = AppUser(...);
  final map = user.toMap();
  expect(map['email'], user.email);
});
```

### Widget Tests

Write widget tests for:
- UI components
- User interactions
- Navigation
- Form validation

Example:
```dart
testWidgets('Login button should be disabled when loading', (tester) async {
  await tester.pumpWidget(MyApp());
  final button = find.byType(ElevatedButton);
  expect(button, findsOneWidget);
});
```

### Integration Tests

Write integration tests for:
- Complete user flows
- Firebase integration
- Authentication flows

## Documentation

### Code Comments

- Comment complex logic
- Use doc comments for public APIs
- Keep comments up to date

```dart
/// Calculates the total credit amount including interest.
///
/// Returns the sum of principal and interest based on
/// [amount], [interestRate], and [months].
double calculateCreditTotal(double amount, double rate, int months) {
  // Implementation
}
```

### README Updates

Update README.md when:
- Adding new features
- Changing setup process
- Adding dependencies
- Updating requirements

## Commit Message Convention

Follow conventional commits:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

Examples:
```
feat: add credit payment tracking
fix: resolve order status update issue
docs: update setup instructions
```

## Pull Request Guidelines

### PR Title

Use the same convention as commit messages:
```
feat: implement trainer appointment system
```

### PR Description

Include:
1. What changed and why
2. Related issue numbers
3. Screenshots (for UI changes)
4. Testing performed
5. Breaking changes (if any)

### PR Checklist

Before submitting:
- [ ] Code follows style guidelines
- [ ] Tests added and passing
- [ ] Documentation updated
- [ ] No console errors or warnings
- [ ] Tested on multiple devices/platforms
- [ ] Branch is up to date with main

## Review Process

1. Automated checks run (tests, linting)
2. Code review by maintainers
3. Address feedback
4. Approval and merge

## Development Setup

See [SETUP.md](SETUP.md) for detailed setup instructions.

## Project Structure

```
lib/
├── models/           # Data models
├── providers/        # State management
├── screens/          # UI screens
├── services/         # Business logic
├── utils/           # Utilities
└── widgets/         # Reusable widgets
```

## Getting Help

- Check existing documentation
- Search closed issues
- Ask in discussions
- Contact maintainers

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

## Recognition

Contributors will be recognized in:
- README.md
- Release notes
- Project documentation

Thank you for contributing to Apollo Agriculture! 🌾

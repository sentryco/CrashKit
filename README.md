# CrashKit

Minimal crashlytics for iOS and macOS

### Features:
- This implementation catches both exceptions and signals that can cause crashes.
- It creates a detailed crash log with information like exception name, reason, stack trace, and timestamp.
- The crash log can be sent to a server using the callback crash handler
- This implementation runs in an unsafe state after a crash, so it's crucial to minimize operations in the crash handler.

### Competitors:

**1. PLCrashReporter**
PLCrashReporter is an open-source library that provides reliable crash reporting for iOS, macOS, and tvOS 3. Key features include:

Detects crashes and generates detailed reports
Provides information on application, system, process, thread, etc.
Supports symbolication of stack traces
Can be integrated via CocoaPods, Carthage, or Swift Package Manager

**2. Fabric Crashlytics**
Fabric is a popular SDK suite that includes Crashlytics, a powerful crash reporting tool 1. It offers features like:

Automatic crash detection and reporting
Detailed stack traces and reproducible steps
Customizable data collection
Integration with other Fabric tools

**3. HockeySDK**
HockeySDK is an open-source SDK for iOS apps that provides crash reporting along with other features 1. Key capabilities include:

Automatic crash reporting
User feedback integration
Analytics and distribution
4. Firebase Crash Reporting
Firebase Crash Reporting is part of Google's Firebase platform and offers:

Real-time crash reports
Customizable data collection
Integration with other Firebase services

**5. Bugsnag**
Bugsnag is a comprehensive error monitoring solution that provides:

Real-time error tracking
User feedback mechanisms
Customizable notification settings
Best Practices:
When choosing a crash reporting library, consider factors such as:

Ease of integration
Feature set (e.g., symbolication, user feedback)
Performance impact on your app
Data privacy and security measures
Pricing model (if applicable)
It's worth noting that while third-party libraries offer more robust solutions, Apple also provides built-in crash reporting tools through Xcode and iTunes Connect 2. However, these may not provide the level of detail and customization offered by dedicated crash reporting services.

Remember to carefully review each library's documentation and consider your specific needs when selecting the best crash reporting solution for your app.

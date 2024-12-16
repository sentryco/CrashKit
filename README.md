[![Tests](https://github.com/sentryco/CrashKit/actions/workflows/Tests.yml/badge.svg)](https://github.com/sentryco/CrashKit/actions/workflows/Tests.yml)
[![codebeat badge](https://codebeat.co/badges/07327740-2f56-4b15-8e62-9f5f78543ffe)](https://codebeat.co/projects/github-com-sentryco-crashkit-main)

# CrashKit

> Minimal crashlytics for iOS and macOS

<img width="403" alt="img" src="https://s7.gifyu.com/images/SJBsk.gif">

Video of using GA4 as endpoint for crash-reporting via [https://github.com/sentryco/Telemetric](https://github.com/sentryco/Telemetric)

### Features:
- Catch both exceptions and signal crashes
- Log exception name, reason, stack trace, and timestamp
- Send crash log to a server using the callback crash handler. Use your own endpoint. or [https://github.com/sentryco/Telemetric](https://github.com/sentryco/Telemetric)
- Crash logs are stored on file and sent to a server on subsequent app run
- Built in crash log sanitization, or supply your own custom sanitizer logic
- Filter out log properties based on your own privacy criteria

### Examples:
- Setup crashlytic in the didFinishLaunchin of your iOS and macOS app
- For swiftUI use the init method in your app scope (iOS and macOS)
- Use your own analytics endpoint. Like GA4 via [https://github.com/sentryco/Telemetric](https://github.com/sentryco/Telemetric) 
- Use the built-in or custom sanitizer logic to redact personal information

```swift
import SwiftUI
import CrashKit
import Telemetric

@main
struct MyApp: App {
    init() {
        Crashlytic.shared.sendCrashReportToServer = { crashLog in
            let sanitizedCrashLog = redactSensitiveInfo(crashLog: crashLog) 
            let exceptionEvent = Event.exception(params: sanitizedCrashLog) 
            let tracker = Tracker(measurementID: "G-1234567890", apiSecret: "1234567890")
            tracker.sendEvent(event: exceptionEvent) 
        }
        Crashlytic.shared.processCrashReport() // Send cached crashlogs
        Crashlytic.shared.setUpCrashHandler() // Listen to crashes
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

> [!CAUTION]  
> Recording crash to logs only works when xcode is detached. Run the app directly from the system without xcode attached or press "debug" -> "detach from xcode" if you run the app from xcode. Run the app from xcode after a crash and see the crash log being sent to the server.

### Installation
There is also an xcode example project in this repository. `ExampleDemo` where crashing can be tested

```swift
.package(url: "https://github.com/sentryco/CrashKit", branch: "main")
```

> [!NOTE]  
> Telemetric https://github.com/sentryco/Telemetric is added to the testing target and in the ExampleDemo xcode project

### Real-device vs Simulator vs Unit-test 
1. On Device: This will work effectively on actual iOS devices. Uncaught exceptions, such as those thrown by Objective-C code or unhandled NSExceptions, will be captured by this handler.
2. In Simulator: The behavior in the simulator should be similar to that on an actual device. The simulator is designed to emulate the behavior of iOS hardware closely, including the handling of exceptions. However, there might be slight differences in how some low-level system interactions occur.
3. In Unit Tests: Typically, unit tests are designed to run in isolation and handle exceptions internally to report test failures. If an uncaught exception occurs during a unit test, it might not be handled by the NSSetUncaughtExceptionHandler unless the testing framework is explicitly configured to allow it. Most modern testing frameworks in Swift, like XCTest, have their mechanisms to handle exceptions and might bypass or override the behavior of NSSetUncaughtExceptionHandler.

### Resources: 
- To handle or not to handle crashes your self: https://medium.com/swlh/building-your-own-crash-report-in-swift-think-twice-before-doing-it-795ee7e23ee8
- Error causes: https://medium.com/@ankuriosdev/writing-custom-crash-logs-in-swift-for-your-ios-app-42ee513d4f4b
- NSException: https://developer.apple.com/documentation/foundation/nsexception
- SO related: https://stackoverflow.com/questions/51672291/how-to-implement-exception-error-handling-in-swift-4-with-native-crash-reporting
- Opensource crash framework for iOS: https://github.com/kstenerud/KSCrash

### Best Practices for Crash Handling

- Minimize Logging in Signal Handlers: Signal handlers run in an unpredictable state, so minimize work done in these handlers. Ideally, just record the crash details and exit.
- Avoid Blocking Calls: Signal handlers should avoid blocking calls (e.g., file I/O, network I/O) as these can lead to deadlocks or undefined behavior.
- Use Existing Crash Reporting Tools: Consider integrating robust crash reporting tools like Firebase Crashlytics, Sentry, or Bugsnag, which offer advanced features like user metrics, session tracking, and automatic reporting.
- Test Signal Handlers: Test your signal handlers thoroughly to ensure they work correctly in different scenarios. Simulate crashes to see how well your handlers perform.
- Privacy and Security: Ensure that crash logs do not contain sensitive user information. Adhere to privacy policies and regulations (like GDPR) when handling user data.

### Competitors:

**1. PLCrashReporter**
PLCrashReporter is an open-source library that provides reliable crash reporting for iOS, macOS, and tvOS 3. Key features include:

- Detects crashes and generates detailed reports
- Provides information on application, system, process, thread, etc.
- Supports symbolication of stack traces
- Can be integrated via CocoaPods, Carthage, or Swift Package Manager

**2. Fabric Crashlytics**
Fabric is a popular SDK suite that includes Crashlytics, a powerful crash reporting tool 1. It offers features like:

- Automatic crash detection and reporting
- Detailed stack traces and reproducible steps
- Customizable data collection
- Integration with other Fabric tools

**3. HockeySDK**
HockeySDK is an open-source SDK for iOS apps that provides crash reporting along with other features 1. Key capabilities include:

- Automatic crash reporting
- User feedback integration
- Analytics and distribution
- Firebase Crash Reporting
- Firebase Crash Reporting is part of Google's Firebase platform and offers:
- Real-time crash reports
- Customizable data collection
- Integration with other Firebase services

**5. Bugsnag**
Bugsnag is a comprehensive error monitoring solution that provides:

- Real-time error tracking
- User feedback mechanisms
- Customizable notification settings
- Best Practices:
- When choosing a crash reporting library, consider factors such as:

**6. Firebase crashlytics:**

Firebase Crashlytics is a powerful crash reporting tool that offers several advantages and some limitations for app developers.

**Pros**

1. Real-time crash reporting: Crashlytics provides immediate notifications about crashes, allowing developers to quickly identify and address issues[1][3].

2. Detailed crash analytics: It offers comprehensive crash reports, including stack traces and device information, making debugging easier[2][3].

3. Prioritization of issues: Crashlytics groups crashes into manageable issues based on their impact on users, helping developers focus on the most critical problems[3].

4. Integration with development tools: It seamlessly integrates with popular tools like Jira, Slack, and Android Studio, streamlining the debugging process[3].

5. Free to use: Crashlytics is available at no cost on both Spark and Blaze plans[1].

6. Cross-platform support: It works with Android, iOS, Flutter, and Unity apps[3].

7. AI-powered insights: Crashlytics leverages Gemini AI to provide actionable insights for faster root cause analysis[3].

**Cons**

1. Learning curve: The user interface can be challenging for new users to understand initially[2].

2. Limited API crash reporting: Some users have noted that API crash reporting could be improved[2].

3. Feature overload: With Firebase offering numerous features, it can be overwhelming to navigate and fully utilize all available tools[7].

4. Dependency on Google ecosystem: As part of Firebase, Crashlytics is tied to Google's ecosystem, which may not be ideal for all developers.

5. Data privacy concerns: Some developers may have reservations about sharing crash data with Google, especially for sensitive applications.

Overall, Firebase Crashlytics offers robust crash reporting capabilities that can significantly improve app stability and user experience, despite some minor drawbacks.
 
### Ease of integration
- Feature set (e.g., symbolication, user feedback)
- Performance impact on your app
- Data privacy and security measures
- Pricing model (if applicable)
- It's worth noting that while third-party libraries offer more robust solutions, Apple also provides built-in crash reporting tools through Xcode and iTunes Connect 2. However, these may not provide the level of detail and customization offered by dedicated crash reporting services.

Remember to carefully review each library's documentation and consider your specific needs when selecting the best crash reporting solution for your app.

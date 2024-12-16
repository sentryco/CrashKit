import Foundation

public class Crashlytic {
   /**
    * Callback to send crash log to server
    */
   public var sendCrashReportToServer: ((_ crashDetails: [String: String]) -> Void)? = { _ in print("⚠️️ No server configured ⚠️️") }
   public static let shared = Crashlytic()
}
/**
 * Config
 * - Description: Function to set up the crash handler
 * - Note: Initialize crash handler when app launches for iOS: AppDelegate didFinishLaunchingWithOptions
 */
extension Crashlytic {
   /**
    * - Description: Set up the crash handler
    * - Note: This handler captures Objective-C exceptions, not Swift errors or crashes caused by things like segmentation faults or stack overflows.
    * - Note: You cannot recover from or handle fatal errors like force unwrapping nil.
    */
   public func setUpCrashHandler() {
      #if DEBUG
      if isDebug { Swift.print("setUpCrashHandler") }
      #endif
      // Handle uncaught exceptions
      NSSetUncaughtExceptionHandler { exception in
         let crashLog: [String: String] = exceptionHandler(from: exception)
         saveCrashReport(crashLog)
         // Note: Do not attempt to make network requests here, as the app is unstable
      }
      // Handle various signals that can cause crashes
      // Crashes caused by signals (e.g., SIGABRT, SIGSEGV) or low-level errors captured here.
      signal(SIGABRT) { _ in handleSignal() }
      signal(SIGILL) { _ in handleSignal() }
      signal(SIGSEGV) { _ in handleSignal() }
      signal(SIGFPE) { _ in handleSignal() }
      signal(SIGBUS) { _ in handleSignal() }
      signal(SIGPIPE) { _ in handleSignal() }
   }
}
/**
 * Server
 */
extension Crashlytic {
   /**
    * Proces local crash report if available and send to server
    * - Note: Call this on app launch
    */
   public func processCrashReport() {
      #if DEBUG
      if isDebug { Swift.print("processCrashReport") }
      #endif
      let crashReportPath = FileManager.getDocumentsDirectory().appendingPathComponent("last_crash.json")
      if let crashData = try? Data(contentsOf: crashReportPath),
         let crashDetails: [String: String] = try? JSONSerialization.jsonObject(with: crashData, options: []) as? [String: String] {
         #if DEBUG
         if isDebug {
            Swift.print("crashData.count \(crashData.count)")
            let multilineString = crashDetails
               .map { "\($0.key): \($0.value)" }
               .joined(separator: "\n")
            print(multilineString)
         }
         #endif
         // Send the crash details to your endpoint
         sendCrashReportToServer?(crashDetails)
         // Delete the crash report after sending it
         try? FileManager.default.removeItem(at: crashReportPath)
      } else {
         #if DEBUG
         if isDebug { Swift.print("No crashReport on file") }
         #endif
      }
   }
}
let isDebug: Bool = false

import Foundation

public class Crashlytic {
   /**
    * Callback to send crash log to server
    */
   internal var sendCrashReportToServer: ((_ crashDetails: [String: String]) -> Void)?
   public static let shared = Crashlytic()
   init(sendCrashReportToServer: ((_: [String : String]) -> Void)? = nil) {
      self.sendCrashReportToServer = sendCrashReportToServer
   }
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
      // Set up uncaught exception handler
      NSSetUncaughtExceptionHandler { exception in
         let crashLog: [String: String] = exceptionHandler(from: exception)
         saveCrashReport(crashLog)
         // Note: Do not attempt to make network requests here, as the app is unstable
      }
      // Set up signal handlers
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
      let crashReportPath = FileManager.getDocumentsDirectory().appendingPathComponent("last_crash.json")
      if let crashData = try? Data(contentsOf: crashReportPath),
         let crashDetails: [String: String] = try? JSONSerialization.jsonObject(with: crashData, options: []) as? [String: String] {
         // Send the crash details to your endpoint
         sendCrashReportToServer?(crashDetails)
         // Delete the crash report after sending it
         try? FileManager.default.removeItem(at: crashReportPath)
      }
   }
}


import Foundation
/**
 * Handler
 * - Note: must be global function, due to c-pointer limitations
 * - Note: Function to create crash log
 */
internal func exceptionHandler(from exception: NSException) -> [String: String] {
   let crashLog = [
      "name": "\(exception.name.rawValue)",
      "reason": "\(exception.reason ?? "No reason provided")",
      "userInfo": "\(exception.userInfo ?? [:])",
      "stackTrace": "\(exception.callStackSymbols.joined(separator: "\n"))",
      "timestamp": "\(Date())"
   ]
   // Note: Save the crash details locally (e.g., in UserDefaults or a file)
   return crashLog
}

/**
 * Handle signals
 */
internal func handleSignal() {
   let crashLog: [String: String] = exceptionHandler(from: NSException(name: NSExceptionName(rawValue: "Critical Argument Error"), reason: "Unhandled signal", userInfo: nil))
   saveCrashReport(crashLog)
   // Note: Do not attempt to make network requests here, as the app is unstable
}
/**
 * File
 */
internal func saveCrashReport(_ details: [String: String]) {
   let crashReport = try? JSONSerialization.data(withJSONObject: details, options: [])
   let crashReportPath = FileManager.getDocumentsDirectory().appendingPathComponent("last_crash.json")
   try? crashReport?.write(to: crashReportPath)
}


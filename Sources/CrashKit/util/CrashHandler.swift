import Foundation
/**
 * Handles uncaught exceptions by creating a crash log and saving it.
 * - Note: Do not attempt to make network requests here, as the app is unstable.
 * - Parameter exception: The uncaught NSException that caused the crash.
 */
func handleException(_ exception: NSException) {
   let crashLog: [String: String] = createCrashLog(from: exception)
   saveCrashReport(crashLog)
}
/**
 * Handles crashes caused by signals by creating a crash log and saving it.
 * - Parameter signal: The signal that caused the crash.
 */
func handleSignal(_ signal: Int32) {
   let crashLog: [String: String] = createCrashLog(from: signal)
   saveCrashReport(crashLog)
}
/**
 * Creates a crash log from a signal.
 * - Fixme: ⚠️️ we can unpack more info here. see issue tracker for more info
 * - Parameter signal: The signal that caused the crash.
 * - Returns: A dictionary containing the crash details.
 */
func createCrashLog(from signal: Int32) -> [String: String] {
   #if DEBUG
   if isDebug { Swift.print("createCrashLog(signal:)") }
   #endif
   let crashLog = [
      "Signal": "\(signal)",
      "reason": "\(Date())",
   ]
   // Note: Save the crash details locally (e.g., in UserDefaults or a file)
   return crashLog
}
/**
 * Creates a crash log from an exception.
 * This function captures detailed information about an exception that can be used for debugging and logging purposes.
 * - Note: Must be a global function due to c-pointer limitations.
 * - Parameter exception: The NSException instance from which to create the log.
 * - Returns: A dictionary containing keys such as 'name', 'reason', 'userInfo', 'stackTrace', and 'timestamp' with corresponding values describing the exception.
 */
internal func createCrashLog(from exception: NSException) -> [String: String] {
   #if DEBUG
   if isDebug { Swift.print("createCrashLog(exception:)") }
   #endif
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
 * Saves the crash report to a file.
 * This function serializes the crash details into JSON format and writes them to a file
 * in the app's documents directory. The file is named "last_crash.json".
 * - Parameter details: A dictionary containing the crash details to be saved.
 */
internal func saveCrashReport(_ details: [String: String]) {
   #if DEBUG
   if isDebug { Swift.print("saveCrashReport") }
   #endif
   let crashReport = try? JSONSerialization.data(withJSONObject: details, options: [])
   let crashReportPath = FileManager.getDocumentsDirectory().appendingPathComponent("last_crash.json")
   try? crashReport?.write(to: crashReportPath)
}


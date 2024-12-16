import Foundation
/**
 * - Note: Do not attempt to make network requests here, as the app is unstable
 */
func handleException(_ exception: NSException) {
   let crashLog: [String: String] = createCrashLog(from: exception)
   saveCrashReport(crashLog)
}
/**
 * - Fixme: ⚠️️ add doc
 */
func handleSignal(_ signal: Int32) {
   let crashLog: [String: String] = createCrashLog(from: signal)
   saveCrashReport(crashLog)
}
/**
 * - Fixme: ⚠️️ add doc
 * - Fixme: ⚠️️ we can unpack more info here. see issue tracker for more info
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
 * - Note: must be global function, due to c-pointer limitations
 * - Note: Function to create crash log
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
 * File
 */
internal func saveCrashReport(_ details: [String: String]) {
   #if DEBUG
   if isDebug { Swift.print("saveCrashReport") }
   #endif
   let crashReport = try? JSONSerialization.data(withJSONObject: details, options: [])
   let crashReportPath = FileManager.getDocumentsDirectory().appendingPathComponent("last_crash.json")
   try? crashReport?.write(to: crashReportPath)
}


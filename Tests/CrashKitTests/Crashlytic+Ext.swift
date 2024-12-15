import Foundation
@testable import CrashKit

// for testing
extension Crashlytic {
   func handleException(_ exception: NSException) {
      let crashLog: [String: String] = exceptionHandler(from: exception)
      saveCrashReport(crashLog)
   }
}

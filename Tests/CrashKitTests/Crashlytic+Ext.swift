import Foundation
@testable import CrashKit

// for testing
extension Crashlytic {
   func exceptionHandler(_ exception: NSException) {
      let crashLog: [String: String] = createCrashLog(from: exception)
      saveCrashReport(crashLog)
   }
}

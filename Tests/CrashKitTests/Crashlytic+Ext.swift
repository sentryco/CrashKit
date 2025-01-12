import Foundation
@testable import CrashKit

// for testing
extension Crashlytic {
   /**
    * - Fixme: ⚠️️ isnt this the same as handler? whats the idea here?
    */
   func exceptionHandler(_ exception: NSException) {
      let crashLog: [String: String] = createCrashLog(from: exception)
      saveCrashReport(crashLog)
   }
}

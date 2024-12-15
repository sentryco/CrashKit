import Testing
@testable import CrashKit
import Telemetric

@Test func example() async throws {
   // 1. Hock up crash report callback to send to GA4
   Crashlytic.shared.sendCrashReportToServer = { crashDetails in
      let tracker = Tracker(measurementID: "G-1234567890", apiSecret: "1234567890")
      // send to GA4
      tracker.send(event: Event.exception, params: crashDetails)
   }
   // 2. config crash handler
   Crashlytic.shared.setUpCrashHandler()
   // 3. Process and send crash report to server, clear crash report after sending
   Crashlytic.shared.processCrashReport()
   // Simulate crash
   sleep(3) // wait a bit
   let crashes = [ 
      {
         let crash = NSException(name: NSExceptionName(rawValue: "Critical Argument Error"), reason: "Unhandled signal", userInfo: nil)
         crash.raise()
      },
      {
         fatalError("Test crash")
      }
   ]
   print("Triggering crash")
   crashes.randomElement()?() // trigger crash
}

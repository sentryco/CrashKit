

import XCTest
@testable import Telemetric

@testable import CrashKit
import Telemetric

class TelemetricTests: XCTestCase {
   func testProcessingCrash() throws {
      let expectation = self.expectation(description: "crash test")
      // 1. Hock up crash report callback to send to GA4
      Crashlytic.shared.sendCrashReportToServer = { crashDetails in
         let tracker = Tracker(measurementID: "G-1234567890", apiSecret: "1234567890")
         // 3. send to GA4
         tracker.sendEvent(event: Event.exception(params: crashDetails)) { _ in
            expectation.fulfill()
            Swift.print("Crash report delivered")
         }
      }
      // 2. Process and send crash report to server, clear crash report after sending
      Crashlytic.shared.processCrashReport()
      self.wait(for: [expectation], timeout: 10.0)
   }
   func testCrash() throws {
      // 1. config crash handler to save crash repots to file
      Crashlytic.shared.setUpCrashHandler()
      // 2. Simulate crash
      sleep(3) // wait a bit
      let crash1: () -> Void = {
         let crash = NSException(name: NSExceptionName(rawValue: "Critical Argument Error"), reason: "Unhandled signal", userInfo: nil)
         crash.raise()
      }
      let crash2: () -> Void = {
         fatalError("Test crash")
      }
      let crashes = [crash1, crash2]
      print("Triggering crash 💥")
      crashes.randomElement()?() // trigger crash
   }
}

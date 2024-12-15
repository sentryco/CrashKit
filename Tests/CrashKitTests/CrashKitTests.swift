

import XCTest
@testable import Telemetric

@testable import CrashKit
import Telemetric

class TelemetricTests: XCTestCase {
   func testCrash() throws {
      // 1. config crash handler to save crash repots to file
      Crashlytic.shared.setUpCrashHandler()
      // 2. Simulate crash
      sleep(3) // wait a bit
      let crash1: () -> Void = {
         Swift.print("NSException err")
         let crash = NSException(name: NSExceptionName(rawValue: "Critical Argument Error"), reason: "Unhandled signal", userInfo: nil)
         crash.raise()
      }
      let crash2: () -> Void = {
         Swift.print("fatalError")
         fatalError("Test crash")
      }
      let crash3: () -> Void = { // SIGPIPE (Broken Pipe)
         Swift.print("SIGPIPE err")
         let str: Any = "test"
         let number: Double = str as! Double // fails
      }
      let crash4: () -> Void = { // SIGBUS (Bus Error)
         Swift.print("SIGBUS err")
         var buffer = UnsafeMutableRawPointer.allocate(byteCount: 4, alignment: 4)
         buffer.storeBytes(of: 0, as: Int.self)
         let misalignedPointer = buffer.advanced(by: 1)
         let value = misalignedPointer.load(as: Int.self)  // Causes SIGBUS
      }
      let crash5: () -> Void = { // SIGFPE (Floating-Point Exception)
         Swift.print("SIGFPE err")
         let y = 1 / (0 == 0 ? 0 : 0)  // Causes another SIGFPE
      }
      let crash6: () -> Void = {
         Swift.print("SIGSEGV err")
         var array = [1, 2, 3]
         let outOfBoundsIndex = 5
         print(array[outOfBoundsIndex])  // Causes SIGSEGV
      }
      let crash7: () -> Void = { // SIGABRT
         Swift.print("SIGABRT err")
         assert(0 != 0)
      }
      let crash8: () -> Void = { // SIGILL (Illegal Instruction)
         Swift.print("SIGILL err")
         var array = [1, 2, 3]
         array.reserveCapacity(-1)  // Causes SIGILL
      }
      let crashes = [crash1, crash2, crash3, crash4, crash5, crash6, crash7, crash8]
      print("Triggering crash 💥")
      crashes.randomElement()?() // trigger crash
   }
   func testProcessingCrash() throws {
      let expectation = self.expectation(description: "crash test")
      // 1. Hock up crash report callback to send to GA4
      Crashlytic.shared.sendCrashReportToServer = { crashDetails in
         let tracker = Tracker(measurementID: "G-1234567890", apiSecret: "1234567890")
         // 3. redact personal information
         let redactedCrashDetails = redactSensitiveInfo(crashLog: crashDetails)
         // 4. send to GA4
         tracker.sendEvent(event: Event.exception(params: redactedCrashDetails)) { _ in
            expectation.fulfill()
            Swift.print("Crash report delivered")
         }
      }
      // 2. Process and send crash report to server, clear crash report after sending
      Crashlytic.shared.processCrashReport()
      self.wait(for: [expectation], timeout: 10.0)
   }
}


import XCTest
import Telemetric
@testable import CrashKit

class TelemetricTests: XCTestCase {
   /**
    * Test endpoint with mock error log
    */
   func testProcessingCrash() throws {
      let mockException = NSException(name: NSExceptionName(rawValue: "TestException"), reason: "TestReason", userInfo: nil)
      Crashlytic.shared.handleException(mockException)
      // Verify that the crash log is saved correctly
      // This might involve checking the file system or a mock of the saveCrashReport method
      let expectation = self.expectation(description: "crash test")
      // 1. Hock up crash report callback to send to GA4
      Crashlytic.shared.sendCrashReportToServer = { crashDetails in
         Swift.print("sendCrashReportToServer")
         let tracker = Tracker(
            measurementID: "",
            apiSecret: ""
            // apiEndpoint: "https://www.google-analytics.com/debug/mp/collect" // debug payload
         )
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
   /**
    * Test sanitazion of logs
    * - Fixme: ⚠️️ Add MockData as a testing dep to test more cases
    * - Fixme: ⚠️️ Actually spin this redaction out into a module. RedactionKit?
    */
   func testRedaction() throws {
      let crashLog: [String: String] = [
         "User": "john.doe@example.com",
         "Credit Card": "4111-1111-1111-1111",
         "IP Address": "192.168.1.1",
         "Private Key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANB...\n-----END PRIVATE KEY-----",
         "Public Key": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqh...\n-----END PUBLIC KEY-----",
         "Seed Phrase": "apple banana cherry date eggfruit fig grape juice kiwi lemon grapefruit orange",
         "URL with Sensitive Params": "https://example.com?token=abcdef123456",
         "Error": "Something went wrong."
      ]
      let sanitizedLog: [String: String] = redactSensitiveInfo(crashLog: crashLog)
      let multilineString = sanitizedLog.mapValues { value in
         return "\(value)"
      }.map { key, value in
         return "\(key): \(value)"
      }.joined(separator: "\n")
      print(multilineString)
      // Assert that sensitive fields are redacted
      XCTAssertEqual(sanitizedLog["User"], RedactionPattern.email.replacement)
      XCTAssertEqual(sanitizedLog["Credit Card"], RedactionPattern.creditCard.replacement)
      XCTAssertEqual(sanitizedLog["IP Address"], RedactionPattern.ipAddress.replacement)
      XCTAssertEqual(sanitizedLog["Private Key"], RedactionPattern.privateKey.replacement)
      XCTAssertEqual(sanitizedLog["Public Key"], RedactionPattern.publicKey.replacement)
      XCTAssertEqual(sanitizedLog["Seed Phrase"], RedactionPattern.seedPhrase.replacement)
      XCTAssertEqual(sanitizedLog["URL with Sensitive Params"], RedactionPattern.urlWithSensitiveParams.replacement)
      // Assert that non-sensitive fields are not redacted
      XCTAssertEqual(sanitizedLog["Error"], "Something went wrong.")
   }
}



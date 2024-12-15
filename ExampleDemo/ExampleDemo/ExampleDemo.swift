import SwiftUI
import CrashKit
import Telemetric

@main
struct ExampleDemo: App {
   init() {
      Swift.print("ExampleDemo.init()")
      Crashlytic.shared.sendCrashReportToServer = { crashLog in
         let sanitizedCrashLog = redactSensitiveInfo(crashLog: crashLog)
         let exceptionEvent = Event.exception(params: sanitizedCrashLog)
         let tracker = Tracker(measurementID: "", apiSecret: "")
         tracker.sendEvent(event: exceptionEvent)
      }
      Crashlytic.shared.processCrashReport() // Send cached crashlogs
      Crashlytic.shared.setUpCrashHandler()
   }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
// - Fixme: ⚠️️ test osLog to see if data is processed etc?
struct ContentView: View {
    var body: some View {
        VStack {
            Button("Crash") {
               print("Triggering crash 💥")
               // 2. Simulate crash
//               crash1() // 🚫
//               crash2() // 🚫
//               crash3() // ✅ (works for macOS, run the app outside xcode first then inside xcode to verify sending to server)
//               crash4() // 🚫
//               crash5() // 🚫
//               crash6() // 🚫
//               crash7() // 🚫
//               crash8() // 🚫
                 crashes.randomElement()?() // trigger crash (Seems like more crash types work for iOS, but some don't)
               print("after crash 🧹")
            }
        }
    }
} 

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
   let _: Double = str as! Double // fails
}
let crash4: () -> Void = { // SIGBUS (Bus Error)
   Swift.print("SIGBUS err")
   let buffer = UnsafeMutableRawPointer.allocate(byteCount: 4, alignment: 4)
   buffer.storeBytes(of: 0, as: Int.self)
   let misalignedPointer = buffer.advanced(by: 1)
   let _ = misalignedPointer.load(as: Int.self)  // Causes SIGBUS
}
let crash5: () -> Void = { // SIGFPE (Floating-Point Exception)
   Swift.print("SIGFPE err")
   let _ = 1 / (0 == 0 ? 0 : 0)  // Causes another SIGFPE
}
let crash6: () -> Void = {
   Swift.print("SIGSEGV err")
   let array = [1, 2, 3]
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

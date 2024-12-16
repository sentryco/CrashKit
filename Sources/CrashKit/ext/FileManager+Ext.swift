import Foundation

extension FileManager {
   static func getDocumentsDirectory() -> URL {
      return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
   }
}

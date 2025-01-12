import Foundation

extension FileManager {
   // fixme: make this optional and call .first?
   static func getDocumentsDirectory() -> URL {
      return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
   }
}

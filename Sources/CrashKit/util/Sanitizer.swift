import Foundation

// Be cautious about what information is included in crash logs in the first place, especially for apps dealing with highly sensitive data
public func redactSensitiveInfo(crashLog: [String: String]) -> [String: String] {
    return crashLog.mapValues { redactSensitiveInfo(from: $0) }
}

fileprivate func redactSensitiveInfo(from log: String) -> String {
   // Define patterns for sensitive information
   let patterns: [String: String] = [
      // Example: Email address
      "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}": "[REDACTED_EMAIL]",
      
      // Example: Password (e.g., key-value pair with "password")
      "(?i)password\\s*[:=]\\s*[^\\s]+": "password=[REDACTED]",
      
      // Example: Phone number (basic pattern, adjust as needed)
      "\\b\\d{3}[-.\\s]?\\d{3}[-.\\s]?\\d{4}\\b": "[REDACTED_PHONE]",
      
      // Example: API Key or Token (alphanumeric, 16-64 chars)
      "\\b[a-zA-Z0-9]{16,64}\\b": "[REDACTED_API_KEY]"
   ]
   
   var redactedLog = log
   
   // Apply each pattern to the log
   for (pattern, replacement) in patterns {
      if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
         redactedLog = regex.stringByReplacingMatches(
            in: redactedLog,
            options: [],
            range: NSRange(location: 0, length: redactedLog.utf16.count),
            withTemplate: replacement
         )
      }
   }
   
   return redactedLog
}

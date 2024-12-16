import Foundation

// Be cautious about what information is included in crash logs in the first place, especially for apps dealing with highly sensitive data
/**
 * - Fixme: ⚠️️ add doc
 */
public func redactSensitiveInfo(crashLog: [String: String]) -> [String: String] {
    return crashLog.mapValues { redactSensitiveInfo(from: $0) }
}
/**
 * - Fixme: ⚠️️ add doc
 */
fileprivate func redactSensitiveInfo(from log: String) -> String {
   var redactedLog = log
   for pattern in redactionPatterns {
      redactedLog = pattern.regex.stringByReplacingMatches(
         in: redactedLog,
         options: [],
         range: NSRange(location: 0, length: redactedLog.utf16.count),
         withTemplate: pattern.replacement
      )
   }
   return redactedLog
}
/**
 * - Fixme: ⚠️️ add doc
 */
public enum RedactionPattern: String, CaseIterable {
    case email = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"
    case creditCard = "\\b(?:\\d[ -]*?){13,16}\\b"
    case ipAddress = "\\b(?:\\d{1,3}\\.){3}\\d{1,3}\\b"  // IPv4 pattern
    case authToken = "Bearer\\s+[a-zA-Z0-9\\-\\._~\\+\\/]+=*"  // Authentication tokens
    case privateKey = #"-----BEGIN PRIVATE KEY-----(?:.|\n)+?-----END PRIVATE KEY-----"#
    case publicKey = #"-----BEGIN PUBLIC KEY-----(?:.|\n)+?-----END PUBLIC KEY-----"#
    case seedPhrase = #"(\b\w+\b[\s]*){12,24}"#
    case urlWithSensitiveParams = #"https?:\/\/\S+\?(?:\S*?(token|key|secret)=\S+)+"#
    var replacement: String {
        switch self {
        case .email:
            return "[REDACTED_EMAIL]"
        case .creditCard:
            return "[REDACTED_CREDIT_CARD]"
        case .ipAddress:
            return "[REDACTED_IP_ADDRESS]"
        case .authToken:
            return "Bearer [REDACTED_TOKEN]"
        case .privateKey:
            return "[REDACTED PRIVATE KEY]"
        case .publicKey:
            return "[REDACTED PUBLIC KEY]"
        case .seedPhrase:
            return "[REDACTED_SEED_PHRASE]"
        case .urlWithSensitiveParams:
            return "[REDACTED_URL]"
        }
    }
    var regex: NSRegularExpression {
        return try! NSRegularExpression(pattern: self.rawValue, options: [])
    }
}

fileprivate let redactionPatterns: [RedactionPattern] = {
    return RedactionPattern.allCases
}()

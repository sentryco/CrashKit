import Foundation
/**
 * Redacts sensitive information from a dictionary representing a crash log.
 * - Description: This function iterates over each key-value pair in the provided dictionary,
 * applying redaction to the value to remove sensitive information such as
 * emails, IP addresses, and other patterns defined in `redactionPatterns`.
 * It returns a new dictionary with the same keys but with redacted values.
 * - Note: Be cautious about what information is included in crash logs in the first place, especially for apps dealing with highly sensitive data
 * - Parameter crashLog: A dictionary representing the crash log, where keys are
 *                       identifiers and values are the corresponding log entries.
 * - Returns: A new dictionary with the same keys as the input `crashLog`, but
 *            with each value redacted to remove sensitive information.
 */
public func redactSensitiveInfo(crashLog: [String: String]) -> [String: String] {
    return crashLog.mapValues { redactSensitiveInfo(from: $0) }
}
/**
 * Redacts sensitive information from a given log string.
 * - Description: This function iterates over predefined patterns of sensitive data (like emails, IP addresses, etc.)
 * and replaces occurrences with a generic redacted message. This helps in ensuring that sensitive
 * information is not exposed in log outputs.
 * - Parameter log: The original log string containing potential sensitive information.
 * - Returns: A redacted version of the log string with sensitive information obscured.
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
 * Enumerates patterns of sensitive data that need to be redacted from logs.
 * - Description: This enum provides regular expressions for identifying sensitive information
 * in strings and specifies the replacement text for each type of sensitive data.
 * It supports redaction of emails, credit card numbers, IP addresses, authentication tokens,
 * private keys, public keys, seed phrases, and URLs with sensitive parameters.
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
/**
 * A collection of all redaction patterns.
 * - Description: This array contains all the cases of the `RedactionPattern` enum, which represent
 * different types of sensitive data that need to be redacted from logs.
 */
fileprivate let redactionPatterns: [RedactionPattern] = {
    return RedactionPattern.allCases
}()

import Foundation

public extension Int {
    
    var roman: String? {
        
        var result = ""
        var number = self
        
        if number > 0 && number < 4000 {
            for entry in RomanToIntConversion.allCases {
                while number - entry.rawValue >= 0 {
                    number -= entry.rawValue
                    result += String(describing: entry)
                }
            }
        }
        
        return result.isEmpty ? nil : result
    }
}

enum RomanToIntConversion: Int, CaseIterable {
    case M = 1000
    case CM = 900
    case D = 500
    case CD = 400
    case C = 100
    case XC = 90
    case L = 50
    case XL = 40
    case X = 10
    case IX = 9
    case V = 5
    case IV = 4
    case I = 1
}

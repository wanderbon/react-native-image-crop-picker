//
//  ColorsHelper.swift
//  react-native-image-crop-picker
//
//  Created by e.kozhich on 17.12.2020.
//

import Foundation

struct ColorsHelper {
    static func parseColor(color: String) -> UIColor {
        if(color.contains("#")) {
            let stringWithoutHex = color.replacingOccurrences(of: "#", with: "")
            return UIColor(hex: stringWithoutHex)
        } else if(color.contains("rgb")) {
            return getUIColor(colors: getArrayColors(color: color))
        }
        
        return UIColor(hex: "000000")
    }
    
    static func getArrayColors(color: String) -> [String] {
        let firstString = color.replacingOccurrences(of: "rgba(", with: "")
        let secondString = firstString.replacingOccurrences(of: "rgb(", with: "")
        let thirdString = secondString.replacingOccurrences(of: ")", with: "")
        
        let colors: Array<Substring> = thirdString
            .split(separator: ",")
        
        var result: Array<String> = [];
        
        for index in 0..<colors.count {
            result.append(colors[index].trimmingCharacters(in: .whitespacesAndNewlines))
        }
            
        return result;
    }
    
    static func getUIColor(colors: Array<String>) -> UIColor {
        let a: Float = 3 >= colors.count ? 1.0 : (colors[3] as NSString).floatValue;
        let r: Float = (colors[0] as NSString).floatValue
        let g: Float = (colors[1] as NSString).floatValue
        let b: Float = (colors[2] as NSString).floatValue
        
        let color: UIColor = UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: CGFloat(a))

        return color;
    }
}

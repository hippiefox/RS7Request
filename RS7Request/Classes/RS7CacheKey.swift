//
//  RS7CacheKey.swift
//  RS7Request
//
//  Created by pulei yu on 2023/10/30.
//

import Foundation
import Cache

public struct RS7CacheKey{
    public static func keyOf(url: String, params: [String:Any]?)->String{
        MD5(url+sort(params ?? [:]))
    }
    
    public static func sort(_ params: [String:Any])-> String{
        var result = ""
        let keys = params.keys.sorted { $0 < $1}
        keys.forEach {result += "\($0)=\(params[$0] ?? "")"}
        return result
    }
}

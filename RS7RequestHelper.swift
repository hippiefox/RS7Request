//
//  RS7RequestHelper.swift
//  RS7Request
//
//  Created by pulei yu on 2023/11/1.
//

import Foundation
 
public protocol RS7RequestHelperProtocol{
     func decrypt(rawStr: String) -> String?
}

public final class RS7RequestHelper{
    public static let shared = RS7RequestHelper()
    
    public var helper: RS7RequestHelperProtocol?
    
    private init(){}
}

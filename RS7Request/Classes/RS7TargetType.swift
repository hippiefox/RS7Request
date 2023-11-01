//
//  RS7TargetType.swift
//  RS7Request
//
//  Created by pulei yu on 2023/10/30.
//

import Foundation
import Moya


public enum RS7CacheType{
    case onlyRequest
    case requestCache
    case onlyReadCache
}


public protocol RS7TargetType: TargetType {
    var cacheType: RS7CacheType { get }
    var needsHUD: Bool { get }
    var timeoutInterval: TimeInterval { get }
    var params: [String: Any] { get }
    var isRespEncrypted: Bool{  get}
}


public struct RS7Response {
    /// code
    public let code: RS7ResponseCode
    /// map解析后的data
    public var data: [AnyHashable: Any] = [:]
    /// 是否为缓存的数据
    public var isCache: Bool = false
    /// 原始的data，当code为error时，会带有
    public var rawData: Data?
}

public enum RS7ResponseCode {
    case ok
    case unknownError
    case networkFailed
    case parseFailed
    case decryptFailed
}

public typealias RS7RequestCompletion = (_ result:RS7Response) -> Void


//
//  RS7Request.swift
//  RS7Request
//
//  Created by pulei yu on 2023/10/30.
//

import Foundation
import Moya

public class RS7Request<Target: RS7TargetType> {
    
    public static func request(_ target: Target, completion: @escaping RS7RequestCompletion) {
        let url = target.baseURL.absoluteString + target.path
        let urlCacheKey = RS7CacheKey.keyOf(url: url, params: target.params)

        // 读取缓存
        if target.cacheType == .onlyReadCache || target.cacheType == .requestCache {
            if let cachedData = RS7RequestCache.default.object(for: urlCacheKey)?.data,
               let json = try? JSONSerialization.jsonObject(with: cachedData, options: []),
               let dic = json as? [AnyHashable: Any] {
                var resp = RS7Response(code: .ok)
                resp.data = dic
                resp.isCache = true
                completion(resp)
                if target.cacheType == .onlyReadCache {
                    return
                }
            }
        }

        RS7Request.provide(timeout: target.timeoutInterval).request(target) { result in
            switch result {
            case let .success(resp):
                guard let str = try? resp.mapString() else {
                    var rs7_resp = RS7Response(code: .parseFailed)
                    rs7_resp.rawData = resp.data
                    completion(rs7_resp)
                    return
                }

                var respStr = str
                // decrypt if resp is encrypted
                if target.isRespEncrypted {
                    guard let decryptedStr = self.decrypt(rawStr: str) else {
                        var rs7_resp = RS7Response(code: .decryptFailed)
                        rs7_resp.rawData = resp.data
                        completion(rs7_resp)
                        return
                    }
                    respStr = decryptedStr
                }
                respStr = respStr.trimmingCharacters(in: .controlCharacters)

                guard let jsonData = respStr.data(using: .utf8),
                      let _dic = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed),
                      let dic = _dic as? [AnyHashable: Any]
                else {
                    var rs7_resp = RS7Response(code: .parseFailed)
                    rs7_resp.rawData = resp.data
                    completion(rs7_resp)
                    return
                }
                // cache result if needed
                if target.cacheType == .requestCache,
                   let data = try? JSONSerialization.data(withJSONObject: dic, options: .fragmentsAllowed)
                {
                    let cacheModel = RS7CacheModel(data: data)
                    RS7RequestCache.default.setCache(value: cacheModel, for: urlCacheKey)
                }
                // parse success without logic judgement
                var rs7_resp = RS7Response(code: .ok)
                rs7_resp.data = dic
                rs7_resp.rawData = resp.data
                completion(rs7_resp)
            case let .failure(moyaError):
                if moyaError.errorCode == 6 {
                    completion(RS7Response(code: .networkFailed))
                } else {
                    completion(RS7Response(code: .unknownError))
                }
            }
        }
    }

    public static func decrypt(rawStr: String) -> String? {
        RS7RequestHelper.shared.helper?.decrypt(rawStr: rawStr)
    }

    static func provide(timeout: TimeInterval) -> MoyaProvider<Target> {
        let requestTimeoutClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider<Target>.RequestResultClosure) in
            do {
                var request = try endpoint.urlRequest()
                request.timeoutInterval = timeout
                done(.success(request))
            } catch {
                done(.failure(MoyaError.underlying(RS7FooError(), nil)))
                return
            }
        }
        let provider = MoyaProvider<Target>(requestClosure: requestTimeoutClosure)
        return provider
    }
}

public struct RS7FooError: Error {}

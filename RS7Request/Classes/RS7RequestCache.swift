//
//  RS7Cache.swift
//  RS7Request
//
//  Created by pulei yu on 2023/10/30.
//

import Cache
import Foundation

public struct RS7CacheModel: Codable {
    var data: Data?
}

public final class RS7RequestCache {
    public static let `default` = RS7RequestCache()

    private var diskStorage: DiskStorage<String, RS7CacheModel>?

    private init() {
        let bid = Bundle.main.bundleIdentifier ?? "RS7RequestCache"
        let conf = DiskConfig(name: bid)
        let transform = TransformerFactory.forCodable(ofType: RS7CacheModel.self)
        diskStorage = try? DiskStorage<String, RS7CacheModel>(config: conf, transformer: transform)
    }

    public func removeAll() {
        try? diskStorage?.removeAll()
    }

    public func removeObject(for key: String) {
        try? diskStorage?.removeObject(forKey: key)
    }

    public func object(for key: String) -> RS7CacheModel? {
        if let result = try? diskStorage?.object(forKey: key) {
            return result
        }
        return nil
    }

    public func setCache(value: RS7CacheModel, for key: String) {
        DispatchQueue.global().async {
            try? self.diskStorage?.setObject(value, forKey: key, expiry: nil)
        }
    }
}

import Foundation

extension Dictionary {
    public subscript(key: Key?) -> Value? {
        guard let key = key else {
            return nil
        }
        return self[key]
    }
}

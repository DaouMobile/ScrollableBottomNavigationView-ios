import Foundation

public struct BottomMenuItem: Codable {
    public let id: String
    public let appName: String
    public let localizedName: String
    public var seq: Int
    public let url: URL?
    
    public init(id: String, appName: String, localizedName: String, seq: Int, url: URL? = nil) {
        self.id = id
        self.appName = appName
        self.localizedName = localizedName
        self.seq = seq
        
        if url?.description.contains("native") == true {
            self.url = nil
        } else {
            self.url = url
        }
    }
    
    public mutating func setSeq(_ seq: Int) {
        self.seq = seq
    }
}

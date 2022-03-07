import UIKit

public protocol MenuImageMapper {
    func mapToImage(from name: String) -> UIImage?
    
    func mapToActivatedImage(from name: String) -> UIImage?
    func mapToUnactivatedImage(from name: String) -> UIImage?
}

public extension MenuImageMapper {
    func mapToActivatedImage(from name: String) -> UIImage? {
        mapToImage(from: name)
    }
    func mapToUnactivatedImage(from name: String) -> UIImage? {
        mapToImage(from: name)
    }
}


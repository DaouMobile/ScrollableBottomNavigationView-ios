import UIKit

public protocol BottomMenuImageMapper {
    func mapToImage(from name: String) -> UIImage?
    
    func mapToActivatedImage(from name: String) -> UIImage?
    func mapToUnactivatedImage(from name: String) -> UIImage?
}

public extension BottomMenuImageMapper {
    func mapToActivatedImage(from name: String) -> UIImage? {
        mapToImage(from: name)
    }
    func mapToUnactivatedImage(from name: String) -> UIImage? {
        mapToImage(from: name)
    }
}


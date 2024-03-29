import UIKit

public protocol BottomMenuImageMapper {
    func mapToSelectedImage(from name: String) -> UIImage?
    func mapToUnselectedImage(from name: String) -> UIImage?
}

public extension BottomMenuImageMapper {
    func mapToSelectedImage(from name: String) -> UIImage? {
        return UIImage(named: "board")
    }
    func mapToUnselectedImage(from name: String) -> UIImage? {
        return UIImage(named: "board")
    }
}


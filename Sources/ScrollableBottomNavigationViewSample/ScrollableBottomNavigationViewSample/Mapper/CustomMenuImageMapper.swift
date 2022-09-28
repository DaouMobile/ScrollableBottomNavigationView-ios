import UIKit

struct CustomMenuImageMapper: BottomMenuImageMapper {
    
    func mapToImage(from name: String) -> UIImage? {
        // TODO: Should implement
        return UIImage(named: "board")?.withRenderingMode(.alwaysOriginal)
    }
}

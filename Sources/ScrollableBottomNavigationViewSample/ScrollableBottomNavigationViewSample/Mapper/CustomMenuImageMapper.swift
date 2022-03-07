import UIKit
import ScrollableBottomNavigationView_ios

struct CustomMenuImageMapper: MenuImageMapper {
    func mapToImage(from name: String) -> UIImage? {
        // TODO: Should implement
        return UIImage(named: "board")?.withRenderingMode(.alwaysOriginal)
    }
}

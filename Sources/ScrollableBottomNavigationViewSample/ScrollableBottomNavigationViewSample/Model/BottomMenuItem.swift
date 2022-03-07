import Foundation
import ScrollableBottomNavigationView_ios

struct BottomMenuItem: MenuItem {
    let id: String
    let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

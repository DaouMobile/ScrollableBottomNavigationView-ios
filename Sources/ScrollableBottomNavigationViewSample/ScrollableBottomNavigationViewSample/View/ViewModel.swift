import Foundation
import RxSwift
import RxCocoa
import ScrollableBottomNavigationView_ios

final class ViewModel {
    
    private let _bottomMenuItems: BehaviorRelay<[MenuItem]>
    var bottomMenuItems: Driver<[MenuItem]> {
        _bottomMenuItems.asDriver()
    }
    
    init() {
        // MARK: ViewModel에서 BottomView에 사용될 데이터 초기화
        _bottomMenuItems = .init(value: [
            BottomMenuItem(id: "040", name: "투데이"),
            BottomMenuItem(id: "041", name: "대화"),
            BottomMenuItem(id: "042", name: "조직도"),
            BottomMenuItem(id: "043", name: "알림1"),
            BottomMenuItem(id: "044", name: "알림2"),
            BottomMenuItem(id: "045", name: "알림3"),
            BottomMenuItem(id: "046", name: "알림4")
        ])
    }
}

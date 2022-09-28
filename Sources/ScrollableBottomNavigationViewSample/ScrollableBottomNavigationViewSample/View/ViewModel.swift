import Foundation
import RxSwift
import RxCocoa

final class ViewModel {
    
    private let _bottomMenuItems: BehaviorRelay<[BottomMenuItem]>
    var bottomMenuItems: Driver<[BottomMenuItem]> {
        _bottomMenuItems.asDriver()
    }
    
    init() {
        // MARK: ViewModel에서 BottomView에 사용될 데이터 초기화
        _bottomMenuItems = .init(value: [
            BottomMenuItem(id: "040", appName: "투데이", localizedName: "메뉴명이좀길것같습니다", seq: 1),
            BottomMenuItem(id: "041", appName: "대화", localizedName: "메뉴명이좀길것같습니다", seq: 2),
            BottomMenuItem(id: "042", appName: "조직도", localizedName: "조직도", seq: 3),
            BottomMenuItem(id: "043", appName: "알림", localizedName: "알림", seq: 4)
        ])
    }
}

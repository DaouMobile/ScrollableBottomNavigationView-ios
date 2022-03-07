import UIKit
import RxSwift
import ScrollableBottomNavigationView_ios

class ViewController: UIViewController {

    private let _viewModel: ViewModel = .init()
    private let _disposeBag: DisposeBag = .init()

    private let _contentView: UIView = .init(frame: .zero)
    
    // MARK: MenuImageMapper 프로토콜을 충족하는 객체를 주입
    private let _bottomNavigationView: ScrollableBottomNavigationView = .init(menuImageMapper: CustomMenuImageMapper())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // MARK: ViewController에서 BottomNavigaitonView를 subView로 구성
        view.addSubview(_bottomNavigationView)
        _bottomNavigationView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            maker.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        _contentView.backgroundColor = .green
        view.addSubview(_contentView)
        _contentView.snp.makeConstraints { (maker) in
            maker.leading.top.trailing.equalToSuperview()
            maker.bottom.equalTo(_bottomNavigationView.snp.top)
        }
        
        // MARK: BottomNavigationView의 view data 초기화
        _bottomNavigationView.menuItems = _viewModel.bottomMenuItems
        _bind()
    }
    
    private func _bind() {
        // MARK: Scrollable 메뉴들이 tap 되는 경우
        _bottomNavigationView.tapMenuItem
            .emit(onNext: { (item) in
                print("tapped item: \(item.name)")
            })
            .disposed(by: _disposeBag)

        // MARK: Fixed 메뉴가 tap 되는 경우
        _bottomNavigationView.tapFixedMenuItem
            .emit(onNext: { (isActivated) in
                print("tapped fixed item isActivate: \(isActivated)")
            })
            .disposed(by: _disposeBag)
    }
}


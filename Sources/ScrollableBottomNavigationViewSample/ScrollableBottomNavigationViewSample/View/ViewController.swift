import UIKit
import RxSwift
import ScrollableBottomNavigationView_ios

class ViewController: UIViewController {

    private let _viewModel: ViewModel = .init()
    private let _disposeBag: DisposeBag = .init()

    private let _contentView: UIView = .init(frame: .zero)
    
    private let _bottomNavigationView: ScrollableBottomNavigationView = .init(menuImageMapper: CustomMenuImageMapper())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
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
        
        _bind()
    }
    
    private func _bind() {
        _bottomNavigationView.tapMenuItem
            .emit(onNext: { (item) in
                print("tapped item: \(item.name)")
            })
            .disposed(by: _disposeBag)

        _bottomNavigationView.tapFixedMenuItem
            .emit(onNext: { (isActivated) in
                print("tapped fixed item isActivate: \(isActivated)")
            })
            .disposed(by: _disposeBag)
    }
}


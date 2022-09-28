import UIKit
import RxSwift
import RxCocoa
import RxGesture

public final class ScrollableBottomNavigationView: UIView {
    static let tabBarWidth: CGFloat = UIScreen.main.bounds.width
    static let maximumPresentableMenuItemCount: Int = 5
    static let height: CGFloat = 50

    // MARK: - Basic Components
    private let _bottomMenuImageMapper: BottomMenuImageMapper
    private let _disposeBag: DisposeBag = .init()
    private var _menuItemDisposables: [Disposable] = []
    private var _fixedMenuItemDisposable: Disposable? = nil
    private var _menuItemsCount: Int = 0
    private var _menuItemWidth: CGFloat = 0
    
    public var menuItems: Binder<[BottomMenuItem]> {
        return .init(self) { (view, items) in
            guard !items.isEmpty else { return }
            view._menuItemsCount = items.count
            view._rightChevronImageView.isHidden = items.count <= Self.maximumPresentableMenuItemCount
            
            view.removeAllMenuItems()
            
            let presentableMenuItemCount: Int = items.count <= Self.maximumPresentableMenuItemCount ? items.count : Self.maximumPresentableMenuItemCount
            let menuItemWidth: CGFloat = (Self.tabBarWidth - (items.count <= Self.maximumPresentableMenuItemCount ? 0 : 16)) / CGFloat(presentableMenuItemCount + 1)
            view._menuItemWidth = menuItemWidth
            
            self._fixedMenuItemView.snp.remakeConstraints { (maker) in
                maker.height.equalTo(Self.height)
                maker.width.equalTo(menuItemWidth)
                maker.leading.equalToSuperview()
                maker.top.equalToSuperview()
            }
            
            view._menuItemsScrollView.snp.remakeConstraints({ (maker) in
                maker.height.equalTo(Self.height)
                maker.leading.equalTo(view._fixedMenuItemView.snp.trailing)
                maker.top.bottom.equalToSuperview()
                if items.count <= Self.maximumPresentableMenuItemCount {
                    maker.trailing.equalToSuperview()
                }
            })
            
            items
                .compactMap({ view._makeMenuItemView(menuItem: $0) })
                .forEach({ (menuItemView) in
                    menuItemView.isSelected = menuItemView.appName == view._selectedMenuItemName
                    view._menuItemsStackView.addArrangedSubview(menuItemView)
                    menuItemView.snp.makeConstraints { (maker) in
                        maker.height.equalTo(Self.height)
                        maker.width.equalTo(menuItemWidth)
                    }
                    view._bind(menuItemView)
                })
        }
    }
    
    private var _selectedMenuItemName: String = "" {
        didSet {
            guard let menuItemsViews = _menuItemsStackView.arrangedSubviews as? [BottomTabBarMenuItemView] else {
                return
            }
            menuItemsViews.forEach {
                $0.isSelected = $0.appName == _selectedMenuItemName
            }
        }
    }
    public var selectedMenuItemName: Binder<String> {
        return .init(self) { (view, appName) in
            view._selectedMenuItemName = appName
        }
    }
    
    private let _fixedMenuItemView: BottomTabBarMenuItemView
    
    public var menuBadgeCount: BehaviorRelay<[String: Observable<Int>]> = .init(value: [:])

    private let _menuItemsStackView: UIStackView = {
        let stackView: UIStackView = .init(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let _menuItemsScrollView: UIScrollView = {
        let scrollView: UIScrollView = .init(frame: .zero)
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let _leftChevronImageView: UIImageView = {
        let imageView: UIImageView = .init(image: UIImage(named: "ic_chevron_left_dark_16"))
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        return imageView
    }()
    private let _rightChevronImageView: UIImageView = {
        let imageView: UIImageView = .init(image: UIImage(named: "ic_chevron_right_dark_16"))
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        return imageView
    }()
    
    private var _isLeftEdge: Driver<Bool> {
        _menuItemsScrollView.rx.contentOffset.asDriver()
            .map({ $0.x })
            .map({ [weak self] (x) in
                guard let owner = self, owner._menuItemsCount > 5 else { return true }
                return x <= (owner._menuItemWidth / 2)
            })
    }
    private var _isRightEdge: Driver<Bool> {
        _menuItemsScrollView.rx.contentOffset.asDriver()
            .map({ $0.x })
            .map({ [weak self] (x) in
                guard let owner = self, owner._menuItemsCount > 5 else { return true }
                return CGFloat(x) + (owner._menuItemWidth * 5) >= (owner._menuItemWidth * CGFloat(owner._menuItemsCount)) - (owner._menuItemWidth / 2)
            })
    }
    
    // MARK: - UI event control
    private let _tapMenuItem: PublishRelay<String> = .init()
    public var tapMenuItem: Signal<String> {
        _tapMenuItem.asSignal()
    }
    
    private let _tapFixedMenuItem: PublishRelay<Bool> = .init()
    public var tapFixedMenuItem: Signal<Bool> {
        _tapFixedMenuItem.asSignal()
    }
    
    public init(bottomMenuImageMapper: BottomMenuImageMapper) {
        _bottomMenuImageMapper = bottomMenuImageMapper
        _fixedMenuItemView = .init(appName: "menu", localizedName: "메뉴",bottomMenuImageMapper: bottomMenuImageMapper)
        super.init(frame: .zero)
        _render()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func resizeMenuItemViews(deviceWidth: CGFloat) {
        let menuItemsCount: Int = {
            self._menuItemsStackView.arrangedSubviews.count < 6 ? self._menuItemsStackView.arrangedSubviews.count : 5
        }()
        let tabBarWidth: CGFloat = deviceWidth
        let menuItemWidth: CGFloat = tabBarWidth / CGFloat(menuItemsCount + 1)
        
        self._fixedMenuItemView.snp.remakeConstraints { (maker) in
            maker.width.equalTo(menuItemWidth)
            maker.leading.equalToSuperview().offset(28)
            maker.top.equalToSuperview()
        }
        self._menuItemsStackView.arrangedSubviews
            .forEach {
                $0.snp.remakeConstraints { (maker) in
                    maker.width.equalTo(menuItemWidth - 0.1)
                }
            }
    }
    
    private func _toggleFixedMenuItem() {
        _fixedMenuItemView.isSelected.toggle()
        _tapFixedMenuItem.accept((_fixedMenuItemView.isSelected))
    }
    
    private func _render() {
        backgroundColor = .white
        snp.makeConstraints { (maker) in
            maker.height.equalTo(Self.height)
        }
    
        let fixedMenuItemDisposable = _fixedMenuItemView.rx.tapGesture().when(.recognized).map { _ in }
            .bind(onNext: _toggleFixedMenuItem)
        _fixedMenuItemDisposable = fixedMenuItemDisposable
        addSubview(_fixedMenuItemView)
        _fixedMenuItemView.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview()
        }
        
        _menuItemsScrollView.addSubview(_menuItemsStackView)
        addSubview(_menuItemsScrollView)
        
        _menuItemsStackView.snp.makeConstraints { (maker) in
            maker.height.equalToSuperview()
            maker.leading.trailing.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
        
        _menuItemsScrollView.snp.makeConstraints { (maker) in
            maker.height.equalTo(Self.height)
            maker.leading.equalTo(_fixedMenuItemView.snp.trailing)
            maker.top.bottom.equalToSuperview()
        }

        _leftChevronImageView.isHidden = true
        addSubview(_leftChevronImageView)
        _leftChevronImageView.snp.makeConstraints({ (maker) in
            maker.width.equalTo(16)
            maker.height.equalTo(Self.height)
            maker.centerY.equalToSuperview()
            maker.centerX.equalTo(_fixedMenuItemView.snp.trailing)
        })
        
        _rightChevronImageView.isHidden = true
        addSubview(_rightChevronImageView)
        _rightChevronImageView.snp.makeConstraints({ (maker) in
            maker.width.equalTo(16)
            maker.height.equalTo(Self.height)
            maker.centerY.equalToSuperview()
            maker.leading.equalTo(_menuItemsScrollView.snp.trailing)
            maker.trailing.equalToSuperview().offset(-8)
        })
        
        _isLeftEdge
            .drive(_leftChevronImageView.rx.isHidden)
            .disposed(by: _disposeBag)
        _isRightEdge
            .drive(_rightChevronImageView.rx.isHidden)
            .disposed(by: _disposeBag)
    }
    
    private func _makeMenuItemView(menuItem: BottomMenuItem) -> BottomTabBarMenuItemView? {
        let bottomTabBarMenuItemView: BottomTabBarMenuItemView = .init(appName: menuItem.appName, localizedName: menuItem.localizedName, bottomMenuImageMapper: self._bottomMenuImageMapper)
        return bottomTabBarMenuItemView
    }
    
    private func _bind(_ menuItemView: BottomTabBarMenuItemView) {
        let tapDisposable: Disposable = menuItemView.rx.tapGesture().when(.recognized)
            .bind(with: self, onNext: { (owner, _) in
                owner._tapMenuItem.accept(menuItemView.appName)
            })
        _menuItemDisposables.append(tapDisposable)
        
        let menuBadgesDisposable: Disposable = self.menuBadgeCount
            .bind(with: self, onNext: { (owner, menuBadgesCount) in
                guard let menuBadgesCount = menuBadgesCount[menuItemView.appName] else {
                    return
                }
                
                let badgeCountDisposable: Disposable = menuBadgesCount.bind(to: menuItemView.badgeCount)
                owner._menuItemDisposables.append(badgeCountDisposable)
            })
        _menuItemDisposables.append(menuBadgesDisposable)
    }
    
    private func removeAllMenuItems() {
        _menuItemDisposables.forEach({ $0.dispose() })
        _menuItemDisposables = []
        _menuItemsStackView.arrangedSubviews.forEach {
            $0.snp.removeConstraints()
            $0.removeFromSuperview()
        }
    }
    
    public func optionalyToggleFixedMenuItem() {
        if _fixedMenuItemView.isSelected {
            _toggleFixedMenuItem()
        }
    }
}

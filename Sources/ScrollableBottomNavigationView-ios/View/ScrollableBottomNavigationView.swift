import UIKit
import RxSwift
import RxCocoa
import RxGesture

public final class ScrollableBottomNavigationView: UIView {
    typealias Tapped = () -> Void
    
    static let height: CGFloat = 50

    // MARK: - Basic Components
    private let _bottomMenuImageMapper: BottomMenuImageMapper
    private let _disposeBag: DisposeBag
    
    // MARK: - UI components
    
    public var fixedMenuItem: Driver<BottomMenuItem> = .empty() {
        willSet(newValue) {
            _updateFixedMenuItem(newValue)
        }
    }
    
    public var menuItems: Driver<[BottomMenuItem]> = .empty() {
        willSet(newValue) {
            _updateMenuItems(newValue)
        }
    }

    private let _activatedMenuItemView: BehaviorRelay<BottomTabBarMenuItemView?> = .init(value: nil)
    
    private let _fixedMenuItemView: BottomTabBarMenuItemView

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
    
    // MARK: - UI event control
    private let _tapMenuItem: PublishRelay<BottomMenuItem?> = .init()
    public var tapMenuItem: Signal<BottomMenuItem> {
        _tapMenuItem.asSignal().compactMap { $0 }
    }
    
    private let _tapFixedMenuItem: PublishRelay<Bool> = .init()
    public var tapFixedMenuItem: Signal<Bool> {
        _tapFixedMenuItem.asSignal()
    }
    
    public init(bottomMenuImageMapper: BottomMenuImageMapper) {
        _bottomMenuImageMapper = bottomMenuImageMapper
        _disposeBag = .init()
        _fixedMenuItemView = .init(appName: "menu", localizedName: "메뉴", bottomMenuImageMapper: bottomMenuImageMapper)
        super.init(frame: .zero)
        _render()
        _bind()
        
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func resizeMenuItemViews(deviceWidth: CGFloat) {
        let menuItemsCount: Int = {
            self._menuItemsStackView.arrangedSubviews.count < 6 ? self._menuItemsStackView.arrangedSubviews.count : 5
        }()
        let tabBarWidth: CGFloat = deviceWidth - 56
        let menuItemWidth: CGFloat = tabBarWidth / CGFloat(menuItemsCount + 1)
        
        self._fixedMenuItemView.snp.remakeConstraints { (maker) in
            maker.width.equalTo(menuItemWidth)
            maker.leading.equalToSuperview().offset(28)
            maker.centerY.equalToSuperview()
        }
        self._menuItemsStackView.arrangedSubviews
            .forEach {
                $0.snp.remakeConstraints { (maker) in
                    maker.width.equalTo(menuItemWidth - 0.1).priority(1000)
                }
            }
    }
    
    private func toggleFixedMenuItem() {
        _fixedMenuItemView.isActivated.toggle()
        _fixedMenuItemView.isActivated
            ? _activatedMenuItemView.accept(self._fixedMenuItemView)
            : _activatedMenuItemView.accept(nil)
        
        _tapFixedMenuItem.accept((self._fixedMenuItemView.isActivated))
    }
    
    private func _render() {
        snp.makeConstraints { (maker) in
            maker.height.equalTo(Self.height)
        }
        
        addSubview(_fixedMenuItemView)
        _menuItemsScrollView.addSubview(_menuItemsStackView)
        addSubview(_menuItemsScrollView)
        
        _fixedMenuItemView.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview().offset(28)
            maker.centerY.equalToSuperview()
        }
        
        _menuItemsStackView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
        
        _menuItemsScrollView.snp.makeConstraints { (maker) in
            maker.height.equalTo(Self.height)
            maker.leading.equalTo(_fixedMenuItemView.snp.trailing)
            maker.top.bottom.equalToSuperview()
            maker.trailing.equalToSuperview().offset(-28)
        }
    }
    
    private func _bind() {
        _fixedMenuItemView.rx.tapGesture().when(.recognized).map { _ in }
            .bind(onNext: { [weak self] in
                self?.toggleFixedMenuItem()
            })
            .disposed(by: _disposeBag)
        
        _activatedMenuItemView
            .subscribe(onNext: { [weak self] in
                if $0?.appName != self?._fixedMenuItemView.appName { self?._fixedMenuItemView.isActivated = false }
            })
            .disposed(by: _disposeBag)
    }
    
    private func _updateFixedMenuItem(_ menuItem: Driver<BottomMenuItem>) {
        menuItem
            .drive(onNext: { [weak self] (menuItem) in
                self?._fixedMenuItemView.appName = menuItem.appName
            })
            .disposed(by: _disposeBag)
    }
    
    private func _updateMenuItems(_ menuItems: Driver<[BottomMenuItem]>) {
        menuItems
            .map { (menuItems) in
                menuItems.compactMap { [weak self] (menuItem) -> (Tapped, BottomTabBarMenuItemView)? in
                    guard let self = self else { return nil }
                    let menuItemsCount: Int = {
                        menuItems.count < 6 ? menuItems.count : 5
                    }()
                    let tabBarWidth: CGFloat = UIScreen.main.bounds.width - 56
                    let menuItemWidth: CGFloat = tabBarWidth / CGFloat(menuItemsCount + 1)
                    let bottomTabBarMenuItemView: BottomTabBarMenuItemView = .init(appName: menuItem.appName, localizedName: menuItem.localizedName, bottomMenuImageMapper: self._bottomMenuImageMapper)

                    self._fixedMenuItemView.snp.remakeConstraints { (maker) in
                        maker.width.equalTo(menuItemWidth)
                        maker.leading.equalToSuperview().offset(28)
                        maker.centerY.equalToSuperview()
                    }
                    bottomTabBarMenuItemView.snp.makeConstraints { (maker) in
                        maker.width.equalTo(menuItemWidth - 0.1).priority(1000)
                    }
                    return (tapped: { [weak self] in self?._tapMenuItem.accept(menuItem) }, view: bottomTabBarMenuItemView)
                }}
            .drive(onNext: { [weak self] in
                $0.forEach { (tapped, view) in
                    guard let self = self else { return }
                    
                    view.rx.tapGesture().when(.recognized).map { _ in }
                    .bind(onNext: { [weak self] in
                        tapped()
                        if view.appName != self?._activatedMenuItemView.value?.appName {
                            view.isActivated.toggle()
                            self?._activatedMenuItemView.accept(view)
                        }
                    })
                    .disposed(by: self._disposeBag)
                    
                    self._activatedMenuItemView
                        .subscribe(onNext: {
                            if $0?.appName != view.appName {
                                view.isActivated = false
                            }
                        })
                        .disposed(by: self._disposeBag)
                    self._menuItemsStackView.addArrangedSubview(view)
                }
            })
            .disposed(by: _disposeBag)
    }
    
    public func optionalyToggleFixedMenuItem() {
        if _fixedMenuItemView.isActivated {
            toggleFixedMenuItem()
        }
    }
}

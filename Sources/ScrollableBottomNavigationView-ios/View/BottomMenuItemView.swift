import UIKit
import RxSwift
import RxRelay
import SnapKit

public final class BottomTabBarMenuItemView: UIView {
    
    private let _menuImageMapper: MenuImageMapper
    
    // MARK: - UI Components
    private let _iconImageView: UIImageView = {
        let imageView: UIImageView = .init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.sizeToFit()
        imageView.snp.makeConstraints { (maker) in
            maker.size.equalTo(24)
        }
        return imageView
    }()
    private let _nameLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.textColor = .darkGray
        label.sizeToFit()
        return label
    }()
    
    let name: String
    
    var isActivated: Bool = false {
        willSet(newValue) {
            _setViewState(isActivated: newValue)
        }
    }
    
    init(name: String, menuImageMapper: MenuImageMapper) {
        self.name = name
        _menuImageMapper = menuImageMapper
        super.init(frame: .zero)
        
        _setViewState(isActivated: false)
        
        addSubview(_iconImageView)
        _iconImageView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.centerX.equalToSuperview()
        }
        
        _nameLabel.text = name
        addSubview(_nameLabel)
        _nameLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(_iconImageView.snp.bottom).offset(2)
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _setViewState(isActivated: Bool) {
        if isActivated {
            _iconImageView.image = _menuImageMapper.mapToImage(from: name)
            _nameLabel.font = .systemFont(ofSize: 10, weight: .bold)
        } else {
            _iconImageView.image = _menuImageMapper.mapToImage(from: name)
            _nameLabel.font = .systemFont(ofSize: 10, weight: .light)
        }
    }
}


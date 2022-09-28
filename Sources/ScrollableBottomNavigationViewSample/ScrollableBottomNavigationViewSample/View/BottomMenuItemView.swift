import UIKit
import RxSwift
import RxRelay
import SnapKit

public final class BottomTabBarMenuItemView: UIView {
    
    private let _bottomMenuImageMapper: BottomMenuImageMapper
    
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
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .darkGray
        label.sizeToFit()
        return label
    }()
    private let _badgeView: UIView = {
        let view: UIView = .init(frame: .zero)
        view.backgroundColor = .init(rgb: 0xFF4545)
        view.layer.cornerRadius = 8
        view.snp.makeConstraints { (maker) in
            maker.height.equalTo(16)
        }
        return view
    }()
    private let _badgeCountLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    public let appName: String
    public let localizedName: String
    public var isSelected: Bool = false {
        didSet {
            if isSelected {
                _iconImageView.image = _bottomMenuImageMapper.mapToSelectedImage(from: appName)
                _nameLabel.font = .systemFont(ofSize: 10, weight: .bold)
            } else {
                _iconImageView.image = _bottomMenuImageMapper.mapToUnselectedImage(from: appName)
                _nameLabel.font = .systemFont(ofSize: 10, weight: .light)
            }
        }
    }
    
    var badgeCount: Binder<Int> {
        Binder(self) { (view, count) in
            guard count >= 0 else { return }
            view._badgeView.isHidden = (count == 0)
            view._badgeCountLabel.text = count < 999 ? count.description : "\(count.description)+"
        }
    }
    
    public init(appName: String, localizedName: String, bottomMenuImageMapper: BottomMenuImageMapper) {
        self.appName = appName
        self.localizedName = localizedName
        _bottomMenuImageMapper = bottomMenuImageMapper
        super.init(frame: .zero)
        
        _iconImageView.image = _bottomMenuImageMapper.mapToUnselectedImage(from: appName)
        addSubview(_iconImageView)
        _iconImageView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.centerX.equalToSuperview()
        }
        
        _nameLabel.text = localizedName
        addSubview(_nameLabel)
        _nameLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(_iconImageView.snp.bottom).offset(2)
            maker.leading.equalToSuperview().offset(1)
            maker.trailing.equalToSuperview().offset(-1)
        }
        
        _badgeView.isHidden = true
        addSubview(_badgeView)
        _badgeView.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(_iconImageView.snp.trailing)
            maker.centerY.equalTo(_iconImageView.snp.top).offset(4)
        }
        
        _badgeView.addSubview(_badgeCountLabel)
        _badgeCountLabel.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(3)
            maker.bottom.equalToSuperview().offset(-3)
            maker.leading.equalToSuperview().offset(6)
            maker.trailing.equalToSuperview().offset(-6)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


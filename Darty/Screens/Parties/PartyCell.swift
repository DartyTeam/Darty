//
//  PartyCell.swift
//  Darty
//
//  Created by Руслан Садыков on 18.07.2021.
//

import UIKit
import SDWebImage

class PartyCell: UICollectionViewCell, SelfConfiguringCell {

    static var reuseId: String = reuseIdentifier

    private enum Constants {
        static let titleFont: UIFont? = .sfProRounded(ofSize: 20, weight: .semibold)
        static let textFont: UIFont? = .sfProDisplay(ofSize: 12, weight: .semibold)
        static let userImageSize: CGFloat = 44
        static let paramFont: UIFont? = .sfProDisplay(ofSize: 8, weight: .medium)
        static let cornerRadius: CGFloat = 20
    }
    
    // MARK: - UI Elements
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textFont
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textFont
        return label
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textFont
        return label
    }()
    
    private let userRatingLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textFont
        return label
    }()
    
    private let userImage: BFImageView = {
        let imageView = BFImageView()
        imageView.layer.cornerRadius = Constants.userImageSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.needsBetterFace = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleFont
        return label
    }()
    
    private let priceView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 0.5)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.paramFont
        return label
    }()
    
    private let typeView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 0.5)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.paramFont
        return label
    }()
    
    private let minAgeView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 0.5)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let minAgeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.paramFont
        return label
    }()
    
    private let mapView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    // MARK: - Formatters
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter
    }()
    
    private let secondDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd MMMM"
        return dateFormatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = Constants.cornerRadius
        setupShadows()
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let party: PartyModel = value as? PartyModel else { return }
        
        FirestoreService.shared.getUser(by: party.userId) { [weak self] (result) in
            switch result {
            
            case .success(let user):
                if user.avatarStringURL != "" {
                    self?.userImage.sd_setImage(with: URL(string: user.avatarStringURL), completed: nil)
                }
               
                self?.userNameLabel.text = user.username
                self?.userRatingLabel.text = "00000000"
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        dateLabel.text = secondDateFormatter.string(from: party.date)
        typeLabel.text = party.type
        titleLabel.text = party.name
        timeLabel.text = timeFormatter.string(from: party.startTime)
        if let endTime = party.endTime {
            timeLabel.text?.append(" 􀄫 \(timeFormatter.string(from: endTime))")
        }
      
        if party.priceType == PriceType.free.rawValue {
            priceLabel.text = PriceType.free.rawValue
        } else {
            priceLabel.text = party.price
        }
        
        minAgeLabel.text = "\(party.minAge)+"
    }
    
    private func setupShadows() {
        layer.shadowColor = UIColor(.black).cgColor
        layer.shadowRadius = 20
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -5, height: 10)
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        addSubview(mapView)
        addSubview(dateLabel)
        addSubview(timeLabel)
        addSubview(userNameLabel)
        addSubview(userRatingLabel)
        addSubview(userImage)
        addSubview(titleLabel)
        addSubview(priceView)
        priceView.addSubview(priceLabel)
        addSubview(typeView)
        typeView.addSubview(typeLabel)
        addSubview(minAgeView)
        minAgeView.addSubview(minAgeLabel)
    }
}

// MARK: - Setup constraints
extension PartyCell {
    
    private func setupConstraints() {
    
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.right.equalToSuperview().offset(-8)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.right.equalTo(timeLabel.snp.right)
            make.bottom.equalTo(timeLabel.snp.top).offset(-6)
        }
        
        userImage.snp.makeConstraints { make in
            make.size.equalTo(Constants.userImageSize)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(8)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel.snp.centerY)
            make.left.equalTo(userImage.snp.right).offset(8)
        }
        
        userRatingLabel.snp.makeConstraints { make in
            make.left.equalTo(userNameLabel.snp.left)
            make.centerY.equalTo(timeLabel.snp.centerY)
        }
        
        mapView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-59)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(12)
        }
        
        minAgeView.snp.makeConstraints { make in
            make.bottom.equalTo(mapView.snp.bottom).offset(-12)
            make.right.equalToSuperview().offset(-7)
        }
        
        minAgeLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(5)
        }
        
        priceView.snp.makeConstraints { make in
            make.bottom.equalTo(minAgeView.snp.top).offset(-7)
            make.right.equalToSuperview().offset(-7)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(5)
        }
        
        typeView.snp.makeConstraints { make in
            make.bottom.equalTo(priceView.snp.top).offset(-7)
            make.right.equalToSuperview().offset(-7)
        }
        
        typeLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(5)
        }
        
        layoutIfNeeded()
    }
}

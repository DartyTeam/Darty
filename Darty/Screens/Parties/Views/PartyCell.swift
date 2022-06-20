//
//  PartyCell.swift
//  Darty
//
//  Created by Руслан Садыков on 18.07.2021.
//

import UIKit
import MapKit
import SkeletonView
import SafeSFSymbols

class PartyCell: UICollectionViewCell, SelfConfiguringCell {

    static var reuseId: String = reuseIdentifier

    // MARK: - Constants
    private enum Constants {
        static let userImageSize: CGFloat = 44
        static let cornerRadius: CGFloat = 20
    }
    
    // MARK: - UI Elements
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .textOnPlate
        label.textColor = Colors.Text.secondary
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .textOnPlate
        label.textColor = Colors.Text.secondary
        label.textAlignment = .right
        return label
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .subtitle
        label.textColor = Colors.Text.main
        return label
    }()
    
    private let userRatingLabel: UILabel = {
        let label = UILabel()
        label.font = .subtitle
        label.textColor = Colors.Text.secondary
        return label
    }()

    private lazy var aboutUserStackView = UIStackView(
        arrangedSubviews: [userNameLabel, userRatingLabel],
        axis: .vertical,
        spacing: 4
    )
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.userImageSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .title
        label.textColor = Colors.Text.main
        label.numberOfLines = 0
        label.textAlignment = .natural
        return label
    }()
    
    private let priceView: BlurEffectView = {
        let view = BlurEffectView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .smallest
        label.textColor = Colors.Text.secondary
        return label
    }()
    
    private let typeView: BlurEffectView = {
        let view = BlurEffectView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .smallest
        label.textColor = Colors.Text.secondary
        return label
    }()
    
    private let minAgeView: BlurEffectView = {
        let view = BlurEffectView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let minAgeLabel: UILabel = {
        let label = UILabel()
        label.font = .smallest
        label.textColor = Colors.Text.secondary
        return label
    }()
    
    private let mapImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        imageView.isSkeletonable = true
        imageView.skeletonCornerRadius = Float(imageView.layer.cornerRadius)
        return imageView
    }()

    private let redView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Statuses.error.withAlphaComponent(0.5)
        return view
    }()

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.font = .title
        label.text = "Отклонено"
        label.textColor = Colors.Text.main
        return label
    }()

    private let infoView: BlurEffectView = {
        let view = BlurEffectView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .smallest
        label.textColor = Colors.Text.secondary
        return label
    }()

    // MARK: - Properties
    private var lon: Double?
    private var lat: Double?

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCornerRadius()
        setupShadows()
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        mapImageView.image = nil
        mapImageView.showSkeleton()
        mapImageView.layoutSubviews()
        infoLabel.text?.removeAll()
        infoView.isHidden = true
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let party: PartyModel = value as? PartyModel else { return }
        dateLabel.text = DateFormatter.ddMMMM.string(from: party.date)
        typeLabel.text = party.type.description
        titleLabel.text = party.name
        timeLabel.text = DateFormatter.HHmm.string(from: party.startTime)
        if let endTime = party.endTime {
            timeLabel.text?.append(" 􀄫 \(DateFormatter.HHmm.string(from: endTime))")
        }
      
        if party.priceType == .free {
            priceLabel.text = PriceType.free.description
        } else if party.priceType == .money {
            priceLabel.text = party.priceType.description + " р."
        } else if party.priceType == .another {
            priceLabel.text = party.anotherPrice
        }
        minAgeLabel.text = "\(party.minAge)+"
        lon = party.location.longitude
        lat = party.location.latitude
        setupMapImageViewFor(latitude: party.location.latitude, longitude: party.location.longitude)

        redView.isHidden = !party.isCanceled
        warningLabel.isHidden = !party.isCanceled
        warningLabel.text = party.isCanceled ? "Отменена" : "Отклонено"
    }

    private let mapSnapshotOptions = MKMapSnapshotter.Options()
    var snapShotter: MKMapSnapshotter {
        return MKMapSnapshotter(options: self.mapSnapshotOptions)
    }
    func setupMapImageViewFor(latitude: Double, longitude: Double) {
        // Set the region of the map that is rendered.
        let location = CLLocationCoordinate2DMake(latitude, longitude) // Apple HQ
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapSnapshotOptions.region = region

        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale

        // Set the size of the image output.
        mapSnapshotOptions.size = mapImageView.bounds.size

        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.pointOfInterestFilter = MKPointOfInterestFilter(including: [
            .airport,
            .amusementPark,
            .aquarium,
            .atm,
            .bakery,
            .bank,
            .beach,
            .brewery,
            .cafe,
            .campground,
            .carRental,
            .evCharger,
            .fireStation,
            .fitnessCenter,
            .foodMarket,
            .gasStation,
            .hospital,
            .hotel,
            .laundry,
            .library
        ])
    }

    func setMap(image: UIImage?) {
        mapImageView.image = image
        mapImageView.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.3))
    }

    func setUser(rating: String?, username: String, avatarStringUrl: String) {
        userImageView.setImage(stringUrl: avatarStringUrl)
        userNameLabel.text = username
        userRatingLabel.text = rating
        userRatingLabel.isHidden = userRatingLabel.text?.isEmpty ?? true
    }

    func setDeletedUser() {
        userImageView.image = "🕸".textToImage(bgColor: .systemGray4, needMoreSmallText: true)
        userNameLabel.text = "Пользователь удален"
        userRatingLabel.isHidden = true
    }
    
    func setRejected() {
        redView.isHidden = false
        warningLabel.isHidden = false
    }
    
    func setRequests(count: Int) {
        infoLabel.text = count.requests()
        infoView.isHidden = false
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupShadows()
        mapImageView.image = nil
        guard let lat = lat, let lon = lon else { return }
        setupMapImageViewFor(latitude: lat, longitude: lon)
    }

    private func setupCornerRadius() {
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
    }
    
    private func setupShadows() {
        layer.shadowColor = isDarkMode ? UIColor.white.withAlphaComponent(0.3).cgColor : UIColor.black.withAlphaComponent(0.7).cgColor
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    private func setupViews() {
        contentView.backgroundColor = SkeletonAppearance.default.tintColor
        contentView.addSubview(mapImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(aboutUserStackView)
        contentView.addSubview(userImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceView)
        priceView.contentView.addSubview(priceLabel)
        contentView.addSubview(typeView)
        typeView.contentView.addSubview(typeLabel)
        contentView.addSubview(minAgeView)
        minAgeView.contentView.addSubview(minAgeLabel)
        contentView.addSubview(infoView)
        infoView.contentView.addSubview(infoLabel)
        contentView.addSubview(redView)
        contentView.addSubview(warningLabel)
    }
}

// MARK: - Setup constraints
extension PartyCell {
    private func setupConstraints() {
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.right.equalToSuperview().offset(-12)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.right.equalTo(timeLabel.snp.right)
            make.bottom.equalTo(timeLabel.snp.top).offset(-6)
        }
        
        userImageView.snp.makeConstraints { make in
            make.size.equalTo(Constants.userImageSize)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(8)
        }

        aboutUserStackView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.top)
            make.left.equalTo(userImageView.snp.right).offset(8)
            make.right.equalTo(timeLabel.snp.left).offset(-24)
            make.bottom.equalTo(timeLabel.snp.bottom)
        }
        
        mapImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-59)
        }
        
        minAgeView.snp.makeConstraints { make in
            make.bottom.equalTo(mapImageView.snp.bottom).offset(-12)
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
        
        infoView.snp.makeConstraints { make in
            make.bottom.equalTo(typeView.snp.top).offset(-7)
            make.right.equalToSuperview().offset(-7)
        }

        infoLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(5)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().inset(12)
            make.right.equalToSuperview().offset(-128)
            make.bottom.lessThanOrEqualTo(mapImageView.snp.bottom).inset(32)
        }

        redView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        warningLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        layoutIfNeeded()
    }
}

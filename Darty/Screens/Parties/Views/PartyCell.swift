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
        label.font = Constants.titleFont
        return label
    }()
    
    private let priceView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3.withAlphaComponent(0.5)
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
        view.backgroundColor = .systemGray3.withAlphaComponent(0.5)
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
        view.backgroundColor = .systemGray3.withAlphaComponent(0.5)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let minAgeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.paramFont
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
        view.backgroundColor = .systemRed.withAlphaComponent(0.5)
        return view
    }()

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleFont
        label.text = "Отклонено"
        return label
    }()

    private let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3.withAlphaComponent(0.5)
        view.layer.cornerRadius = 10
        view.isHidden = true
        return view
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.paramFont
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
        typeLabel.text = party.type
        titleLabel.text = party.name
        timeLabel.text = DateFormatter.HHmm.string(from: party.startTime)
        if let endTime = party.endTime {
            timeLabel.text?.append(" 􀄫 \(DateFormatter.HHmm.string(from: endTime))")
        }
      
        if party.priceType == PriceType.free.rawValue {
            priceLabel.text = PriceType.free.rawValue
        } else if party.priceType == PriceType.money.rawValue {
            priceLabel.text = party.priceType + " р."
        } else if party.priceType == PriceType.another.rawValue {
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

    func setUser(rating: String, username: String, avatarStringUrl: String) {
        userImageView.setImage(stringUrl: avatarStringUrl)
        userNameLabel.text = username
        userRatingLabel.text = rating
        userRatingLabel.isHidden = userRatingLabel.text?.isEmpty ?? true
    }

    func setDeletedUser() {
        userImageView.image = "👾".textToImage(bgColor: .random)
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
        priceView.addSubview(priceLabel)
        contentView.addSubview(typeView)
        typeView.addSubview(typeLabel)
        contentView.addSubview(minAgeView)
        minAgeView.addSubview(minAgeLabel)
        contentView.addSubview(infoView)
        infoView.addSubview(infoLabel)
        contentView.addSubview(redView)
        contentView.addSubview(warningLabel)
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
        
        userImageView.snp.makeConstraints { make in
            make.size.equalTo(Constants.userImageSize)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(8)
        }

        aboutUserStackView.snp.makeConstraints { make in
            make.left.equalTo(userImageView.snp.right).offset(8)
            make.top.equalTo(dateLabel.snp.top)
            make.bottom.equalTo(timeLabel.snp.bottom)
        }
        
        mapImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-59)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(12)
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

        redView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        warningLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        layoutIfNeeded()
    }
}

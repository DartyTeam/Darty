//
//  FourthCreateVC.swift
//  Darty
//
//  Created by Руслан Садыков on 13.07.2021.
//

import UIKit
import FirebaseAuth
import SnapKit

final class FourthCreateVC: UIViewController {
    
    private enum Constants {
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 16, weight: .semibold)
        static let countFont: UIFont? = .sfProDisplay(ofSize: 22, weight: .semibold)
        static let segmentFont: UIFont? = .sfProRounded(ofSize: 16, weight: .medium)
    }
    
    // MARK: - UI Elements
    private let logoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "darty.logo"))
        return imageView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemPurple
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let maxGuestsLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleFont
        label.text = "Кол-во гостей"
        return label
    }()
    
    private lazy var countMaxLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.countFont
        label.text = String(Int(maxGuestsStepper.value))
        return label
    }()
    
    private lazy var maxGuestsStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 100
        stepper.tintColor = .systemPurple
        stepper.addTarget(self, action: #selector(maxGuestsChangedAction(_:)), for: .valueChanged)
        return stepper
    }()
    
    private let minAgeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleFont
        label.text = "Мин. возраст"
        return label
    }()
    
    private lazy var ageCountLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.countFont
        label.text = String(Int(minAgeStepper.value))
        return label
    }()
    
    private lazy var minAgeStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 130
        stepper.tintColor = .systemPurple
        stepper.value = 18
        stepper.addTarget(self, action: #selector(minAgeChangedAction(_:)), for: .valueChanged)
        return stepper
    }()
    
    private let priceTypeSegment: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [PriceType.free.rawValue, PriceType.money.rawValue, PriceType.another.rawValue])
        segmentedControl.selectedSegmentIndex = 0
        let attr = NSDictionary(object: Constants.segmentFont!, forKey: NSAttributedString.Key.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any] , for: .normal)
        segmentedControl.addTarget(self, action: #selector(typeChangedAction(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    private let priceTextField: TextField = {
        let textField = TextField(color: .systemPurple, placeholder: "Стоимость")
        textField.isHidden = true
        return textField
    }()
    
    // MARK: - Properties
    private let currentUser: UserModel
    private var setuppedParty: SetuppedParty
    
    // MARK: - Lifecycle
    init(currentUser: UserModel, setuppedParty: SetuppedParty) {
        self.currentUser = currentUser
        self.setuppedParty = setuppedParty
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(withColor: .systemPurple, title: "Создание вечеринки")
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(logoView)
        view.addSubview(nextButton)
        view.addSubview(maxGuestsLabel)
        view.addSubview(countMaxLabel)
        view.addSubview(maxGuestsStepper)
        
        view.addSubview(ageCountLabel)
        view.addSubview(minAgeLabel)
        view.addSubview(minAgeStepper)
        
        view.addSubview(priceTypeSegment)
        view.addSubview(priceTextField)
    }
    
    // MARK: - Handlers
    @objc private func nextButtonTapped() {

        
    }
    
    @objc private func typeChangedAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewSlideHide(view: priceTextField)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.priceTextField.isHidden = true
            }
        case 1:
            if priceTextField.isHidden {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.priceTextField.isHidden = false
                }
        
                viewSlideShow(view: priceTextField)
            }
        case 2:
            if priceTextField.isHidden {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.priceTextField.isHidden = false
                }
                viewSlideShow(view: priceTextField)
            }
        default:
            break
        }
    }
    
    @objc private func maxGuestsChangedAction(_ sender: UIStepper) {
        countMaxLabel.text = String(Int(sender.value))
    }
    
    @objc private func minAgeChangedAction(_ sender: UIStepper) {
        ageCountLabel.text = String(Int(sender.value))
    }
    
    func viewSlideShow(view: UIView) -> Void {
        let transition:CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.isRemovedOnCompletion = true
        view.layer.add(transition, forKey: kCATransition)
    }
    
    func viewSlideHide(view: UIView) -> Void {
        let transition:CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        transition.isRemovedOnCompletion = true
        view.layer.add(transition, forKey: kCATransition)
    }
}

// MARK: - Setup constraints
extension FourthCreateVC {
    
    private func setupConstraints() {
                        
        logoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
        
        ageCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
   
        countMaxLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-32)
        }
        
        maxGuestsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(countMaxLabel.snp.centerY)
            make.left.equalToSuperview().offset(20)
        }
        
        maxGuestsStepper.snp.makeConstraints { make in
            make.centerY.equalTo(countMaxLabel.snp.centerY)
            make.right.equalToSuperview().offset(-20)
        }
        
        ageCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(countMaxLabel.snp.top).offset(-32)
        }
        
        minAgeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(ageCountLabel.snp.centerY)
            make.left.equalToSuperview().offset(20)
        }
        
        minAgeStepper.snp.makeConstraints { make in
            make.centerY.equalTo(ageCountLabel.snp.centerY)
            make.right.equalToSuperview().offset(-20)
        }
        
        priceTypeSegment.snp.makeConstraints { make in
            make.bottom.equalTo(ageCountLabel.snp.top).offset(-32)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        priceTextField.snp.makeConstraints { make in
            make.bottom.equalTo(priceTypeSegment.snp.top).offset(-16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

//
//  PartyPriceAndGuestsVC.swift
//  Darty
//
//  Created by Руслан Садыков on 13.07.2021.
//

import UIKit

final class PartyPriceAndGuestsVC: UIViewController {

    // MARK: - Constants
    private enum Constants {
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 16, weight: .semibold)
        static let countFont: UIFont? = .sfProDisplay(ofSize: 22, weight: .semibold)
        static let segmentFont: UIFont? = .sfProRounded(ofSize: 16, weight: .medium)
    }
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)
        return scrollView
    }()
    
    private let logoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "darty.logo"))
        return imageView
    }()
    
    private lazy var nextButton: DButton = {
        let button = DButton(title: "Далее 􀰑")
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
        stepper.maximumValue = Double(GlobalConstants.maximumGuests)
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
    
    private lazy var priceTextField: TextField = {
        let textField = TextField(color: .systemPurple, placeholder: "Цена за вход")
        textField.isHidden = true
        textField.returnKeyType = .done
        textField.delegate = self
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleFont
        label.text = "Цена за вход"
        return label
    }()
    
    // MARK: - Properties
    private var savedInfo = SavedInfo()
    
    // MARK: - Delegate
    weak var delegate: PartyPriceAndGuestsDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setupNavBar()
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup views
    private func setupNavBar() {
        setNavigationBar(withColor: .systemPurple, title: "Создание вечеринки")
        let cancelIconConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .bold))
        let cancelIconImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: cancelIconConfig)?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
        let cancelBarButtonItem = UIBarButtonItem(image: cancelIconImage, style: .plain, target: self, action: #selector(cancleAction))
        navigationItem.rightBarButtonItem = cancelBarButtonItem
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(logoView)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(maxGuestsLabel)
        scrollView.addSubview(countMaxLabel)
        scrollView.addSubview(maxGuestsStepper)
        
        scrollView.addSubview(ageCountLabel)
        scrollView.addSubview(minAgeLabel)
        scrollView.addSubview(minAgeStepper)
        
        scrollView.addSubview(priceTypeSegment)
        scrollView.addSubview(priceLabel)
        scrollView.addSubview(priceTextField)
    }
    
    // MARK: - Handlers
    @objc private func keyboardWillHide(notification: NSNotification) {

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
           contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
        
        scrollView.scrollRectToVisible(nextButton.frame, animated: true)

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    @objc private func nextButtonTapped() {
        savedInfo.minAge = Int(minAgeStepper.value)
        savedInfo.maxGuests = Int(maxGuestsStepper.value)

        switch priceTypeSegment.selectedSegmentIndex {
        case 0:
            savedInfo.priceType = .free
            savedInfo.moneyPrice = nil
            savedInfo.anotherPrice = nil
        case 1:
            guard let price = priceTextField.text, !price.isEmptyOrWhitespaceOrNewLines() else {
                priceTextField.setError(message: "Либо введите цену, либо переключите не Бесплатно")
                return
            }
            savedInfo.priceType = .money
            savedInfo.moneyPrice = Int(price)
            savedInfo.anotherPrice = nil
        case 2:
            guard let price = priceTextField.text, !price.isEmptyOrWhitespaceOrNewLines() else {
                priceTextField.setError(message: "Либо введите цену, либо переключите не Бесплатно")
                return
            }
            savedInfo.priceType = .another
            savedInfo.anotherPrice = price
            savedInfo.moneyPrice = nil
        default:
            break
        }

        delegate?.goNext(
            priceType: savedInfo.priceType,
            moneyPrice: savedInfo.moneyPrice,
            anotherPrice: savedInfo.anotherPrice,
            minAge: savedInfo.minAge,
            maxGuests: savedInfo.maxGuests
        )
    }
    
    @objc private func typeChangedAction(_ sender: UISegmentedControl) {
        priceTextField.resignFirstResponder()
        switch sender.selectedSegmentIndex {
        case 0:
            priceTextField.viewSlideHide()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.priceTextField.isHidden = true
            }
        case 1:
            priceTextField.keyboardType = .numberPad
            priceTextField.text = "\(savedInfo.moneyPrice ?? 0)"
            if priceTextField.isHidden {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.priceTextField.isHidden = false
                }
                priceTextField.viewSlideShow()
            }
            priceTextField.becomeFirstResponder()
        case 2:
            priceTextField.text = savedInfo.anotherPrice
            priceTextField.keyboardType = .default
            if priceTextField.isHidden {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.priceTextField.isHidden = false
                }
                priceTextField.viewSlideShow()
            }
            priceTextField.becomeFirstResponder()
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
    
    @objc private func tapAction() {
        view.endEditing(true)
    }
    
    @objc private func cancleAction() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Setup constraints
extension PartyPriceAndGuestsVC {
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        logoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.centerX.equalToSuperview()
        }
        
        var topSafeAreaHeight: CGFloat = 0
        var bottomSafeAreaHeight: CGFloat = 0
        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        topSafeAreaHeight = safeFrame.minY
        bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
        
        nextButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(view.frame.size.height - topSafeAreaHeight - bottomSafeAreaHeight - navigationController!.navigationBar.frame.size.height - (32 * 2 + 16))
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
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
            make.width.equalToSuperview().inset(20)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.bottom.equalTo(priceTypeSegment.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        }
    }
}

// MARK: - UITextFieldDelegate
extension PartyPriceAndGuestsVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.keyboardType == .numberPad {
            savedInfo.moneyPrice = Int(textField.text ?? "") ?? 0
        } else {
            savedInfo.anotherPrice = textField.text ?? ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.keyboardType == .numberPad {
            if !CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {

                // Present alert so the user knows what went wrong
                   print("This field accepts only numeric entries.")

                // Invalid characters detected, disallow text change
                return false
            }
            
            if let text = textField.text,
               let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange,
                                                           with: string)
                if let number = Int(updatedText) {
                    return number <= GlobalConstants.maximumPrice
                }
            }
        }
        
        return false
    }
}

extension PartyPriceAndGuestsVC {
    struct SavedInfo {
        var priceType: PriceType = .free
        var anotherPrice: String?
        var moneyPrice: Int?
        var minAge: Int = 0
        var maxGuests: Int = 1
    }
}

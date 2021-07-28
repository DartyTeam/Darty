//
//  FilterVC.swift
//  Darty
//
//  Created by Руслан Садыков on 22.07.2021.
//

import UIKit
import rubber_range_picker

enum QuerySign: String {
    case isGreaterThanOrEqualTo
    case isLessThanOrEqualTo
    case isEqual
}

protocol FilterVCDelegate {
    func didChangeFilter(_ filter: [String: Any])
}

final class FilterVC: UIViewController {
    
    private enum Constants {
        static let topLineHeight: CGFloat = 6
        
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 20, weight: .medium)
        static let titleText = "Фильтр"

        static let maxGuestsText = "Макс. кол-во гостей"
        static let paramNameFont: UIFont? = .sfProRounded(ofSize: 16, weight: .semibold)
        
        static let typeText = "Тематика"
        
        static let dateText = "Дата"
        
        static let priceTypeText = "Цена"
        
        static let sortingText = "Сортировка"
    }
    
    // MARK: - UI Elements
    private lazy var topLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Constants.topLineHeight / 2
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.tintColor = .systemOrange
        button.addTarget(self, action: #selector(closeAction), for: .touchDown)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleText
        label.font = Constants.titleFont
        label.numberOfLines = 0
        return label
    }()
    
    private let maxGuestsLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.maxGuestsText
        label.font = Constants.paramNameFont
        label.numberOfLines = 0
        return label
    }()
    
    private let maxGuestsPicker: RubberRangePicker = {
        let rubberRangePicker = RubberRangePicker()
        rubberRangePicker.minimumValue = 1
        rubberRangePicker.tintColor = .systemOrange
        rubberRangePicker.maximumValue = Double(GlobalConstants.maximumGuests)
        rubberRangePicker.addTarget(self, action: #selector(maxGuestsUpdated), for: .valueChanged)
        rubberRangePicker.thumbSize = 26
        rubberRangePicker.lineColor = .systemGray4
        return rubberRangePicker
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.typeText
        label.font = Constants.paramNameFont
        return label
    }()
        
    private lazy var typePicker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    private let typeBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8235294118, green: 0.8274509804, blue: 0.831372549, alpha: 1)
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var typeTextField: TextFieldWithoutInteract = {
        let textFieldWithoutInteract = TextFieldWithoutInteract()
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(typeDoneTapped))
        doneButton.tintColor = .systemOrange
        let anyButton = UIBarButtonItem(title: "Любой", style: .plain, target: self, action: #selector(typeAnyTapped))
        anyButton.tintColor = .systemOrange
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([anyButton, flexibleSpace, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        textFieldWithoutInteract.inputAccessoryView = toolBar
        textFieldWithoutInteract.font = UIFont.boldSystemFont(ofSize: 16)
        textFieldWithoutInteract.inputView = typePicker
        textFieldWithoutInteract.delegate = self
        textFieldWithoutInteract.text = "Любой"
        textFieldWithoutInteract.textColor = .systemOrange
        
        textFieldWithoutInteract.font = Constants.paramNameFont
        
        return textFieldWithoutInteract
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.dateText
        label.font = Constants.paramNameFont
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.minimumDate = Date()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = .current
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private let dateSegmentControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["от", "до", "="])
        let attr = NSDictionary(object: Constants.paramNameFont!, forKey: NSAttributedString.Key.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any] , for: .normal)
        segmentedControl.addTarget(self, action: #selector(dateSegmentChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private let priceTypeLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.priceTypeText
        label.font = Constants.paramNameFont
        return label
    }()
    
    private let priceTypeSegment: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [PriceType.free.rawValue, PriceType.money.rawValue, PriceType.another.rawValue])
        segmentedControl.selectedSegmentIndex = 0
        let attr = NSDictionary(object: Constants.paramNameFont!, forKey: NSAttributedString.Key.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any] , for: .normal)
        segmentedControl.addTarget(self, action: #selector(priceTypeChangedAction(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    private let priceRangePicker: RubberRangePicker = {
        let rubberRangePicker = RubberRangePicker()
        rubberRangePicker.minimumValue = 1
        rubberRangePicker.tintColor = .systemOrange
        rubberRangePicker.maximumValue = Double(GlobalConstants.maximumPrice)
        rubberRangePicker.addTarget(self, action: #selector(priceRangeUpdated), for: .valueChanged)
        rubberRangePicker.isHidden = true
        rubberRangePicker.thumbSize = 26
        rubberRangePicker.lineColor = .systemGray4
        return rubberRangePicker
    }()
    
    private let sortingLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.sortingText
        label.font = Constants.paramNameFont
        return label
    }()
    
    private let sortingTypeSegment: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Цена 􀖥", "Дата 􀉉", "Кол 􀝊"])
        let attr = NSDictionary(object: Constants.paramNameFont!, forKey: NSAttributedString.Key.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any] , for: .normal)
        return segmentedControl
    }()
    
    private let ascSegment: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["􀄨", "􀄩"])
        let attr = NSDictionary(object: Constants.paramNameFont!, forKey: NSAttributedString.Key.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any] , for: .normal)
        return segmentedControl
    }()
    
    private let blurEffect = UIBlurEffect(style: .systemThinMaterial)
    private lazy var blurEffectView = UIVisualEffectView(effect: blurEffect)
    
    // MARK: - Properties
    private var filterParams: [String: Any] = [:]
    private var pickedType: PartyType? = nil
    
    private let delegate: FilterVCDelegate
    
    // MARK: - Lifecycle
    init(delegate: FilterVCDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterParams["date"] = Date()
        setupViews()
        setupConstraints()
    }
    private func setupViews() {
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.insertSubview(blurEffectView, at: 0)
        
        blurEffectView.contentView.addSubview(closeButton)
        blurEffectView.contentView.addSubview(topLineView)
        blurEffectView.contentView.addSubview(titleLabel)
        blurEffectView.contentView.addSubview(maxGuestsLabel)
        blurEffectView.contentView.addSubview(maxGuestsPicker)
        blurEffectView.contentView.addSubview(typeLabel)
        blurEffectView.contentView.addSubview(typeBackgroundView)
        typeBackgroundView.addSubview(typeTextField)
        blurEffectView.contentView.addSubview(priceTypeLabel)
        blurEffectView.contentView.addSubview(priceTypeSegment)
        blurEffectView.contentView.addSubview(priceRangePicker)
        blurEffectView.contentView.addSubview(dateLabel)
        blurEffectView.contentView.addSubview(datePicker)
        blurEffectView.contentView.addSubview(dateSegmentControl)
        blurEffectView.contentView.addSubview(sortingLabel)
        blurEffectView.contentView.addSubview(sortingTypeSegment)
        blurEffectView.contentView.addSubview(ascSegment)
    }
    
    private func setupConstraints() {
        topLineView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.width.equalTo(64)
            make.centerX.equalToSuperview()
            make.height.equalTo(6)
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.equalToSuperview().inset(32)
            make.right.equalToSuperview().inset(32)
        }
        
        maxGuestsLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        
        maxGuestsPicker.snp.makeConstraints { make in
            make.top.equalTo(maxGuestsLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(24)
        }
        
        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(maxGuestsPicker.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(24)
        }
        
        typeBackgroundView.snp.makeConstraints { make in
            make.centerY.equalTo(typeLabel.snp.centerY)
            make.left.equalTo(typeLabel.snp.right).offset(10)
        }
        
        typeTextField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.left.right.equalToSuperview().inset(12)
        }
        
        priceTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(24)
        }
        
        priceRangePicker.snp.makeConstraints { make in
            make.centerY.equalTo(priceTypeLabel.snp.centerY)
            make.left.equalToSuperview().offset(156)
            make.right.equalToSuperview().inset(24)
        }
        
        priceTypeSegment.snp.makeConstraints { make in
            make.top.equalTo(priceTypeLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(priceTypeSegment.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(24)
        }
        
        datePicker.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel.snp.centerY)
            make.right.equalToSuperview().offset(-24)
        }
        
        dateSegmentControl.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel.snp.centerY)
            make.left.equalTo(dateLabel.snp.right).offset(10)
            make.right.equalToSuperview().inset(156)
        }
        
        sortingLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(24)
        }
        
        ascSegment.snp.makeConstraints { make in
            make.top.equalTo(sortingLabel.snp.bottom).offset(16)
            make.right.equalToSuperview().inset(24)
        }
        
        sortingTypeSegment.snp.makeConstraints { make in
            make.centerY.equalTo(ascSegment.snp.centerY)
            make.left.equalToSuperview().offset(24)
            make.right.equalTo(ascSegment.snp.left).offset(-10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
    }
    
    // MARK: - Handlers
    @objc private func closeAction() {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func maxGuestsUpdated() {
        maxGuestsLabel.text = String(format:"\(Constants.maxGuestsText): \(Int(maxGuestsPicker.lowerValue)) - \(Int(maxGuestsPicker.upperValue))")
        filterParams["maxGuestsLower"] = Int(maxGuestsPicker.lowerValue)
        filterParams["maxGuestsUpper"] = Int(maxGuestsPicker.upperValue)
        commonFilterUpdate()
    }
    
    @objc private func typeDoneTapped() {
        typeTextField.resignFirstResponder()
    }
    
    @objc private func typeAnyTapped() {
        pickedType = nil
        typeTextField.text = "Любой"
        typeTextField.resignFirstResponder()
        
        filterParams["type"] = nil
        commonFilterUpdate()
    }
    
    @objc private func priceTypeChangedAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            priceRangePicker.isHidden = true
            priceTypeLabel.text = Constants.priceTypeText
            filterParams["priceType"] = PriceType.free
        case 1:
            priceRangePicker.isHidden = false
            priceTypeLabel.text = String(format:"\(Constants.priceTypeText): \(Int(priceRangePicker.lowerValue)) - \(Int(priceRangePicker.upperValue))")
            filterParams["priceType"] = PriceType.money
        case 2:
            priceRangePicker.isHidden = true
            priceTypeLabel.text = Constants.priceTypeText
            filterParams["priceType"] = PriceType.another
        default:
            break
        }
        
        commonFilterUpdate()
    }
    
    @objc private func priceRangeUpdated() {
        priceTypeLabel.text = String(format:"\(Constants.priceTypeText): \(Int(priceRangePicker.lowerValue)) - \(Int(priceRangePicker.upperValue))")
        if priceTypeSegment.selectedSegmentIndex == 1 {
            filterParams["priceLower"] = Int(priceRangePicker.lowerValue)
            filterParams["priceUpper"] = Int(priceRangePicker.upperValue)
        }
        
        commonFilterUpdate()
    }
    
    @objc private func dateSegmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filterParams["dateSign"] = QuerySign.isGreaterThanOrEqualTo
        case 1:
            filterParams["dateSign"] = QuerySign.isLessThanOrEqualTo
        case 2:
            filterParams["dateSign"] = QuerySign.isEqual
        default:
            break
        }
        
        commonFilterUpdate()
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        filterParams["date"] = sender.date
        commonFilterUpdate()
    }
    
    private func commonFilterUpdate() {
        delegate.didChangeFilter(filterParams)
    }
}

extension FilterVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    private func setPickedType(_ type: PartyType?) {
        pickedType = type
        typeTextField.text = pickedType?.rawValue
        filterParams["type"] = pickedType
        commonFilterUpdate()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        setPickedType(PartyType.allCases.first)
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PartyType.allCases.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PartyType.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setPickedType(PartyType.allCases[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        
        label.textColor = .black
        label.textAlignment = .center
        label.font = .sfProDisplay(ofSize: 18, weight: .semibold)
        
        // where data is an Array of String
        label.text = PartyType.allCases[row].rawValue
        
        return label
    }
}

extension FilterVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

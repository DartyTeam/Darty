//
//  FilterVC.swift
//  Darty
//
//  Created by Руслан Садыков on 22.07.2021.
//

import UIKit
import rubber_range_picker

enum QuerySign: String, CaseIterable {
    case isGreaterThanOrEqualTo
    case isLessThanOrEqualTo
    case isEqual

    var index: Int {
        switch self {
        case .isGreaterThanOrEqualTo:
            return 0
        case .isLessThanOrEqualTo:
            return 1
        case .isEqual:
            return 2
        }
    }

    var segmentTitle: String {
        switch self {
        case .isGreaterThanOrEqualTo:
            return "от"
        case .isLessThanOrEqualTo:
            return "до"
        case .isEqual:
            return "="
        }
    }

    static var allCasesForSegmentedControl: [String] {
        var array = [String]()
        for item in self.allCases {
            array.append(item.segmentTitle)
        }
        return array
    }
}

protocol FilterVCDelegate {
    func didChangeFilter(_ filterParams: FilterManager.FilterParams)
}

// MARK: - FilterManager
final class FilterManager {
    static let shared = FilterManager()

    private init() {}

    var filterParams = FilterParams()

    struct FilterParams: Equatable {
        var dateSign: QuerySign = .isLessThanOrEqualTo
        var priceLower: Int?
        var priceUpper: Int?
        var maxGuestsLower: Int?
        var maxGuestsUpper: Int?
        var priceType: PriceType?
        var city: String?
        var type: PartyType?
        var date: Date = Date()
        var sortingType: SortingType = .date
        var ascendingType: AscendingType = .desc
    }

    enum SortingType: String, CaseIterable {
        case price = "Цена 􀖥"
        case date = "Дата 􀉉"
        case guests = "Кол 􀝊"

        var index: Int {
            switch self {
            case .price:
                return 0
            case .date:
                return 1
            case .guests:
                return 2
            }
        }

        static var allCasesForSegmentedControl: [String] {
            var array = [String]()
            for item in self.allCases {
                array.append(item.rawValue)
            }
            return array
        }

        static subscript(_ index: Int) -> SortingType? {
            return SortingType.allCases.first(where: { $0.index == index })
        }
    }

    enum AscendingType: String, CaseIterable {
        case asc = "􀄨"
        case desc = "􀄩"

        var index: Int {
            switch self {
            case .asc:
                return 0
            case .desc:
                return 1
            }
        }

        static var allCasesForSegmentedControl: [String] {
            var array = [String]()
            for item in self.allCases {
                array.append(item.rawValue)
            }
            return array
        }

        static subscript(_ index: Int) -> AscendingType? {
            return AscendingType.allCases.first(where: { $0.index == index })
        }
    }
}

final class FilterVC: UIViewController {

    // MARK: - Constants
    private enum Constants {
        static let topLineHeight: CGFloat = 6
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 20, weight: .medium)
        static let titleText = "Фильтр"
        static let maxGuestsText = "Макс. кол-во гостей"
        static let paramNameFont: UIFont? = .sfProRounded(ofSize: 16, weight: .semibold)
        static let typeTFFont: UIFont? = .sfProRounded(ofSize: 16, weight: .semibold)
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
    
    private lazy var typeBackgroundView: BlurEffectView = {
        let view = BlurEffectView(style: .light)
        view.layer.cornerRadius = priceTypeSegment.layer.cornerRadius
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var typeTextField: TextFieldWithoutInteract = {
        let textFieldWithoutInteract = TextFieldWithoutInteract()
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(typeDoneTapped))
        doneButton.tintColor = .systemOrange
        let anyButton = UIBarButtonItem(title: "Любая", style: .plain, target: self, action: #selector(typeAnyTapped))
        anyButton.tintColor = .systemOrange
        toolBar.backgroundColor = .gray
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([anyButton, flexibleSpace, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        textFieldWithoutInteract.inputAccessoryView = toolBar
        textFieldWithoutInteract.font = Constants.typeTFFont
        textFieldWithoutInteract.inputView = typePicker
        textFieldWithoutInteract.delegate = self
        textFieldWithoutInteract.text = "Любая"
        textFieldWithoutInteract.textColor = .systemOrange
        textFieldWithoutInteract.textAlignment = .center
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
    
    private lazy var dateSegmentControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: QuerySign.allCasesForSegmentedControl)
        let attr = NSDictionary(object: Constants.paramNameFont!, forKey: NSAttributedString.Key.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any], for: .normal)
        segmentedControl.addTarget(self, action: #selector(dateSegmentChanged), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = filterParams.dateSign.index
        return segmentedControl
    }()
    
    private let priceTypeLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.priceTypeText
        label.font = Constants.paramNameFont
        return label
    }()
    
    private lazy var priceTypeSegment: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: PriceType.allCasesForSegmentedControl)
        if let priceTypeIndex = filterParams.priceType?.index {
            segmentedControl.selectedSegmentIndex = priceTypeIndex
            priceTypeChangedAction(segmentedControl)
        }
        let attr = NSDictionary(object: Constants.paramNameFont!, forKey: NSAttributedString.Key.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any] , for: .normal)
        segmentedControl.addTarget(self, action: #selector(priceTypeChangedAction(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var priceRangePicker: RubberRangePicker = {
        let rubberRangePicker = RubberRangePicker()
        rubberRangePicker.minimumValue = 1
        rubberRangePicker.lowerValue = 1
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
    
    private lazy var sortingTypeSegment: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: FilterManager.SortingType.allCasesForSegmentedControl)
        let attr = NSDictionary(object: Constants.paramNameFont!, forKey: NSAttributedString.Key.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any] , for: .normal)
        segmentedControl.selectedSegmentIndex = filterParams.sortingType.index
        segmentedControl.addTarget(self, action: #selector(sortingTypeChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var ascSegment: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: FilterManager.AscendingType.allCasesForSegmentedControl)
        let attr = NSDictionary(object: Constants.paramNameFont!, forKey: NSAttributedString.Key.font as NSCopying)
        segmentedControl.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any] , for: .normal)
        segmentedControl.selectedSegmentIndex = filterParams.ascendingType.index
        segmentedControl.addTarget(self, action: #selector(ascendingTypeChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    private let blurEffect = UIBlurEffect(style: .systemThinMaterial)
    private lazy var blurEffectView = UIVisualEffectView(effect: blurEffect)
    
    // MARK: - Properties
    private var filterParams = FilterManager.shared.filterParams

    // MARK: - Delegate
    private let delegate: FilterVCDelegate

    // MARK: - Init
    init(delegate: FilterVCDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let type = filterParams.type {
            setPickedType(type)
        }
        setupViews()
        setupConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard filterParams != FilterManager.shared.filterParams else { return }
        FilterManager.shared.filterParams = filterParams
        delegate.didChangeFilter(filterParams)
    }

    // MARK: - Setup views
    private func setupViews() {
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        blurEffectView.contentView.addSubview(closeButton)
        blurEffectView.contentView.addSubview(topLineView)
        blurEffectView.contentView.addSubview(titleLabel)

        let maxGuestsView = UIView()
        maxGuestsView.addSubview(maxGuestsLabel)
        maxGuestsView.addSubview(maxGuestsPicker)

        let typeView = UIView()
        typeView.addSubview(typeLabel)
        typeView.addSubview(typeBackgroundView)
        typeBackgroundView.contentView.addSubview(typeTextField)

        let priceView = UIView()
        priceView.addSubview(priceTypeLabel)
        priceView.addSubview(priceTypeSegment)
        priceView.addSubview(priceRangePicker)

        let dateView = UIView()
        dateView.addSubview(dateLabel)
        dateView.addSubview(datePicker)
        dateView.addSubview(dateSegmentControl)

        let sortingView = UIView()
        sortingView.addSubview(sortingLabel)
        sortingView.addSubview(sortingTypeSegment)
        sortingView.addSubview(ascSegment)

        let stackView = UIStackView(
            arrangedSubviews: [
                maxGuestsView,
                typeView,
                priceView,
                dateView,
                sortingView
        ],
            axis: .vertical,
            spacing: 24
        )
        blurEffectView.contentView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
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
        filterParams.maxGuestsLower = Int(maxGuestsPicker.lowerValue)
        filterParams.maxGuestsUpper = Int(maxGuestsPicker.upperValue)
    }
    
    @objc private func typeDoneTapped() {
        typeTextField.resignFirstResponder()
    }
    
    @objc private func typeAnyTapped() {
        filterParams.type = nil
        typeTextField.text = "Любой"
        typeTextField.resignFirstResponder()
    }
    
    @objc private func priceTypeChangedAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            priceRangePicker.isHidden = true
            priceTypeLabel.text = Constants.priceTypeText
            filterParams.priceType = PriceType.free
        case 1:
            priceRangePicker.isHidden = false
            priceTypeLabel.text = String(format:"\(Constants.priceTypeText): \(Int(priceRangePicker.lowerValue)) - \(Int(priceRangePicker.upperValue))")
            filterParams.priceType = PriceType.money
        case 2:
            priceRangePicker.isHidden = true
            priceTypeLabel.text = Constants.priceTypeText
            filterParams.priceType = PriceType.another
        default:
            break
        }
    }
    
    @objc private func priceRangeUpdated() {
        priceTypeLabel.text = String(format:"\(Constants.priceTypeText): \(Int(priceRangePicker.lowerValue)) - \(Int(priceRangePicker.upperValue))")
        if priceTypeSegment.selectedSegmentIndex == 1 {
            filterParams.priceLower = Int(priceRangePicker.lowerValue)
            filterParams.priceUpper = Int(priceRangePicker.upperValue)
        }
    }
    
    @objc private func dateSegmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filterParams.dateSign = QuerySign.isGreaterThanOrEqualTo
        case 1:
            filterParams.dateSign = QuerySign.isLessThanOrEqualTo
        case 2:
            filterParams.dateSign = QuerySign.isEqual
        default:
            break
        }
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        filterParams.date = sender.date
    }

    @objc private func sortingTypeChanged(_ sender: UISegmentedControl) {
        filterParams.sortingType = FilterManager.SortingType[sender.selectedSegmentIndex] ?? filterParams.sortingType
    }

    @objc private func ascendingTypeChanged(_ sender: UISegmentedControl) {
        filterParams.ascendingType = FilterManager.AscendingType[sender.selectedSegmentIndex] ?? filterParams.ascendingType
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension FilterVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    private func setPickedType(_ type: PartyType?) {
        filterParams.type = type
        typeTextField.text = type?.rawValue
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

// MARK: - Setup constraints
extension FilterVC {
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
            make.left.top.right.equalToSuperview()
        }

        maxGuestsPicker.snp.makeConstraints { make in
            make.top.equalTo(maxGuestsLabel.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }

        typeLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
        }

        typeBackgroundView.snp.makeConstraints { make in
            make.centerY.equalTo(typeLabel.snp.centerY)
            make.left.equalTo(typeLabel.snp.right).offset(18)
            make.bottom.right.equalToSuperview()
        }

        typeTextField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.left.right.equalToSuperview().inset(12)
        }

        priceTypeLabel.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }

        priceRangePicker.snp.makeConstraints { make in
            make.centerY.equalTo(priceTypeLabel.snp.centerY)
            make.left.equalToSuperview().offset(156)
            make.right.equalToSuperview()
        }

        priceTypeSegment.snp.makeConstraints { make in
            make.top.equalTo(priceTypeLabel.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }

        dateLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
        }

        datePicker.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel.snp.centerY)
            make.right.equalToSuperview()
        }

        dateSegmentControl.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel.snp.centerY)
            make.left.equalTo(dateLabel.snp.right).offset(10)
            make.right.equalToSuperview().inset(156)
            make.bottom.equalToSuperview()
        }

        sortingLabel.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }

        ascSegment.snp.makeConstraints { make in
            make.top.equalTo(sortingLabel.snp.bottom).offset(16)
            make.right.equalToSuperview()
        }

        sortingTypeSegment.snp.makeConstraints { make in
            make.centerY.equalTo(ascSegment.snp.centerY)
            make.right.equalTo(ascSegment.snp.left).offset(-10)
            make.left.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITextFieldDelegate
extension FilterVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

//
//  PartyTimeVC.swift
//  Darty
//
//  Created by Руслан Садыков on 12.07.2021.
//

import UIKit

final class PartyTimeVC: UIViewController {

    // MARK: - Constants
    private enum Constants {
        static let textFont: UIFont? = .sfProDisplay(ofSize: 20, weight: .semibold)
        static let startTime = "Начало"
        static let endTime = "Конец"
        static let defaultDisabledEndTimePicker = true
    }
    
    // MARK: - UI Elements
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

    private let startLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textFont
        label.text = Constants.startTime
        return label
    }()
    private let startTimePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .inline
        return datePicker
    }()
    private lazy var startTimeStackView = UIStackView(
        arrangedSubviews: [startLabel, startTimePicker],
        axis: .horizontal,
        spacing: 16
    )

    private let endLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textFont
        label.text = Constants.endTime
        return label
    }()
    private let endTimeSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = !Constants.defaultDisabledEndTimePicker
        switcher.addTarget(self, action: #selector(endTimeSwitcherChanged(_:)), for: .valueChanged)
        return switcher
    }()
    private let endTimePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .inline
        datePicker.isHidden = Constants.defaultDisabledEndTimePicker
        datePicker.addTarget(self, action: #selector(endTimeChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    private lazy var endTimeStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [endLabel, endTimeSwitch, endTimePicker],
            axis: .horizontal,
            spacing: 16
        )
        stackView.alignment = .leading
        return stackView
    }()

    private let errorTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .sfProText(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0
        label.text = "Время конца не должно совпадать со временем начала"
        label.isHidden = true
        return label
    }()

    private lazy var timeStackView = UIStackView(
        arrangedSubviews: [startTimeStackView, endTimeStackView, errorTimeLabel],
        axis: .vertical,
        spacing: 16
    )

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textFont
        label.text = "Дата"
        return label
    }()
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        datePicker.preferredDatePickerStyle = .wheels
        return datePicker
    }()
    
    // MARK: - Delegate
    weak var delegate: PartyTimeDelegate?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setIsTabBarHidden(true)
        setNavigationBar(withColor: .systemPurple, title: "Создание вечеринки")
    }

    // MARK: - Setup views
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(logoView)
        view.addSubview(nextButton)
        view.addSubview(datePicker)
        view.addSubview(timeStackView)
        view.addSubview(dateLabel)
    }
    
    // MARK: - Handlers
    @objc private func endTimeSwitcherChanged(_ sender: UISwitch) {
        endTimePicker.isHidden = !sender.isOn
    }

    @objc private func endTimeChanged(_ sender: UIDatePicker) {
        let isSameDate = startTimePicker.date == endTimePicker.date
        print("asdioasjdasdaosasdasdasd: ", isSameDate)
        errorTimeLabel.isHidden = !isSameDate
    }

    @objc private func nextButtonTapped() {
        if endTimeSwitch.isOn {
            guard startTimePicker.date != endTimePicker.date else {
                errorTimeLabel.isHidden = false
                return
            }
        }

        delegate?.goNext(
            startTime: startTimePicker.date,
            endTime: endTimeSwitch.isOn ? endTimePicker.date : nil,
            date: datePicker.date
        )
    }
}

// MARK: - Setup constraints
extension PartyTimeVC {
    private func setupConstraints() {
        logoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(UIButton.defaultButtonHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
        
        datePicker.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(nextButton.snp.top).offset(-32)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalTo(datePicker.snp.centerX)
            make.bottom.equalTo(datePicker.snp.top).offset(16)
        }

        timeStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(dateLabel.snp.top).offset(-32)
        }
    }
}

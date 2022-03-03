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
        static let textFont: UIFont? = .sfProDisplay(ofSize: 16, weight: .semibold)
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
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textFont
        label.text = "Дата"
        return label
    }()
    
    private let startLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textFont
        label.text = "Начало"
        return label
    }()
    
    private let endLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textFont
        label.text = "Конец"
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        datePicker.preferredDatePickerStyle = .wheels
        return datePicker
    }()
    
    private let startTimePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .inline
        return datePicker
    }()
    
    private let endTimePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .inline
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
        view.addSubview(startTimePicker)
        view.addSubview(endTimePicker)
        view.addSubview(dateLabel)
        view.addSubview(startLabel)
        view.addSubview(endLabel)
    }
    
    // MARK: - Handlers
    @objc private func nextButtonTapped() {
        delegate?.goNext(startTime: startTimePicker.date, endTime: endTimePicker.date, date: datePicker.date)
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
            make.height.equalTo(50)
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
        
        startTimePicker.snp.makeConstraints { make in
            make.bottom.equalTo(dateLabel.snp.top).offset(-32)
            make.centerX.equalToSuperview().offset(-88)
        }
        
        startLabel.snp.makeConstraints { make in
            make.centerX.equalTo(startTimePicker.snp.centerX)
            make.bottom.equalTo(startTimePicker.snp.top).offset(-4)
        }
        
        endTimePicker.snp.makeConstraints { make in
            make.centerY.equalTo(startTimePicker.snp.centerY)
            make.centerX.equalToSuperview().offset(88)
        }
        
        endLabel.snp.makeConstraints { make in
            make.centerX.equalTo(endTimePicker.snp.centerX)
            make.bottom.equalTo(endTimePicker.snp.top).offset(-4)
        }
    }
}

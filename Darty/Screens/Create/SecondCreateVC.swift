//
//  SecondCreateVC.swift
//  Darty
//
//  Created by Руслан Садыков on 12.07.2021.
//

import UIKit
import FirebaseAuth
import SnapKit

final class SecondCreateVC: UIViewController {
    
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
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        return datePicker
    }()
    
    private let startTimePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            // Fallback on earlier versions
        }
        return datePicker
    }()
    
    private let endTimePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        return datePicker
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
        view.addSubview(datePicker)
        view.addSubview(startTimePicker)
        view.addSubview(endTimePicker)
        view.addSubview(dateLabel)
        view.addSubview(startLabel)
        view.addSubview(endLabel)
    }
    
    // MARK: - Handlers
    @objc private func nextButtonTapped() {
        let startTime = startTimePicker.date
        let endTime = endTimePicker.date
        let date = datePicker.date
        
        setuppedParty.startTime = startTime
        setuppedParty.endTime = endTime
        setuppedParty.date = date
        let thirdCreateVC = ThirdCreateVC(currentUser: currentUser, setuppedParty: setuppedParty)
        navigationController?.pushViewController(thirdCreateVC, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("asdijasodiadsiojaiodj: ", view.safeAreaInsets.bottom)
    }
}

// MARK: - Setup constraints
extension SecondCreateVC {
    
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

//
//  SexSetupProfileVC.swift
//  Darty
//
//  Created by Руслан Садыков on 02.07.2021.
//

private struct SexButtonModel {
    let title: String
    let iconImage: UIImage?
    let backgroundColor: UIColor
    let sex: Sex
}

private enum Constants {
    static let sizeSexButton: CGFloat = UIScreen.main.bounds.height / 8.13
    static let textFont: UIFont? = .sfProDisplay(ofSize: 18, weight: .semibold)
    static let infoText = "You may not choose"
}

import UIKit
import FirebaseAuth

final class SexSetupProfileVC: UIViewController {
    
    // MARK: - UI Elements
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑")
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.textFont
        label.text = Constants.infoText
        return label
    }()
    
    private let sexStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
//        stackView.spacing = 44
        return stackView
    }()
    
    // MARK: - Properties
    private let sexArray: [SexButtonModel] = [
        SexButtonModel(title: "Man", iconImage: "🙋‍♂️".textToImage(), backgroundColor: #colorLiteral(red: 0.1607843137, green: 0.3921568627, blue: 0.6509803922, alpha: 1), sex: .man),
        SexButtonModel(title: "Woman", iconImage: "🙋‍♀️".textToImage(), backgroundColor: #colorLiteral(red: 0.5019607843, green: 0.1450980392, blue: 0.5764705882, alpha: 1), sex: .woman),
        SexButtonModel(title: "Another", iconImage: "🙋".textToImage(), backgroundColor: #colorLiteral(red: 0.631372549, green: 0.631372549, blue: 0.631372549, alpha: 1), sex: .another)
    ]
    
    private var selectedSex: Sex?
    private let currentUser: User
    
    // MARK: - Lifecycle
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(withColor: .systemBlue, title: "Пол")
        setupViews()
        setupConstraints()
        setupSexes()
    }
    
    private func setupViews() {
        if let image = UIImage(named: "sex.setup.background")?.withTintColor(.systemBlue.withAlphaComponent(0.5)) {
            addBackground(image)
        }
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(infoLabel)
        view.addSubview(nextButton)
        view.addSubview(sexStackView)
    }
    
    private func setupSexes() {
        for item in sexArray {
            let sexSelector = SexSelector(title: item.title, iconImage: item.iconImage, backgroundColor: item.backgroundColor, size: Constants.sizeSexButton, delegate: self, sex: item.sex)
            sexStackView.addArrangedSubview(sexSelector)
        }
    }
    
    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        let aboutSetupProfileVC = BirthdaySetupProfileVC(currentUser: currentUser)
        navigationController?.pushViewController(aboutSetupProfileVC, animated: true)
    }
}

// MARK: - Setup constraints
extension SexSetupProfileVC {
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            infoLabel.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -27),
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            sexStackView.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            sexStackView.bottomAnchor.constraint(greaterThanOrEqualTo: infoLabel.topAnchor, constant: -44),
            sexStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

extension SexSetupProfileVC: SexSelectorDelegate {
    func sexDeselected(_ sex: Sex) {
        if selectedSex == sex {
            selectedSex = nil
        }
    }
    
    func sexSelected(_ sex: Sex) {
        selectedSex = sex
        for item in sexStackView.arrangedSubviews {
            let item = item as? SexSelector
            if item?.sex != sex {
                item?.isSelected = false
            }
        }
    }
}

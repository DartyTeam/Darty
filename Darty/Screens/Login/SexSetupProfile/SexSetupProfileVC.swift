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
}

private enum Constants {
    static let sizeSexButton: CGFloat = 100
    static let textFont: UIFont? = .sfProDisplay(ofSize: 18, weight: .semibold)
    static let infoText = "You may not choose"
}

import UIKit
import FirebaseAuth

final class SexSetupProfileVC: UIViewController {
    
    // MARK: - UI Elements
    private lazy var nextButton: UIButton = {
        let button = UIButton(title: "Далее 􀰑", color: .blue)
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
    
    private let sexesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 44
        return stackView
    }()
    
    // MARK: - Properties
    private let sexesArray: [SexButtonModel] = [
        SexButtonModel(title: "Man", iconImage: "🙋‍♂️".textToImage(), backgroundColor: #colorLiteral(red: 0.1607843137, green: 0.3921568627, blue: 0.6509803922, alpha: 1)),
        SexButtonModel(title: "Woman", iconImage: "🙋‍♀️".textToImage(), backgroundColor: #colorLiteral(red: 0.5019607843, green: 0.1450980392, blue: 0.5764705882, alpha: 1)),
        SexButtonModel(title: "Another", iconImage: "🙋".textToImage(), backgroundColor: #colorLiteral(red: 0.631372549, green: 0.631372549, blue: 0.631372549, alpha: 1))
    ]
    
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
        if let image = UIImage(named: "sex.setup.background")?.withTintColor(.systemBlue.withAlphaComponent(0.75)) {
            addBackground(image)
        }
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(infoLabel)
        view.addSubview(nextButton)
        view.addSubview(sexesStackView)
    }
    
    private func setupSexes() {
        for sex in sexesArray {
            let sexSelector = SexSelector(title: sex.title, iconImage: sex.iconImage, backgroundColor: sex.backgroundColor, size: Constants.sizeSexButton)
            sexesStackView.addArrangedSubview(sexSelector)
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
            sexesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sexesStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

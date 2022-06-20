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

import UIKit
import FirebaseAuth

final class SexSetupProfileVC: BaseController {

    // MARK: - Constants
    private enum Constants {
        static let sizeSexButton: CGFloat = UIScreen.main.bounds.height / 8.13
        static let textFont: UIFont? = .sfProDisplay(ofSize: 18, weight: .semibold)
        static let infoText = "Вы можете не выбирать"
    }

    // MARK: - UI Elements
    private lazy var nextButton: DButton = {
        let button = DButton(title: "Далее 􀰑")
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
        return stackView
    }()
    
    // MARK: - Properties
    private let sexArray: [SexButtonModel] = [
        SexButtonModel(
            title: "Man",
            iconImage: "🙋‍♂️".textToImage(),
            backgroundColor: #colorLiteral(red: 0.1607843137, green: 0.3921568627, blue: 0.6509803922, alpha: 1), sex: .man
        ),
        SexButtonModel(
            title: "Woman",
            iconImage: "🙋‍♀️".textToImage(),
            backgroundColor: #colorLiteral(red: 0.5019607843, green: 0.1450980392, blue: 0.5764705882, alpha: 1),
            sex: .woman
        ),
        SexButtonModel(
            title: "Another",
            iconImage: UIImage(named: "anotherSex"),
            backgroundColor: Colors.Elements.element.withAlphaComponent(0.5),
            sex: .another
        )
    ]
    
    private var selectedSex: Sex?

    // MARK: - Delegate
    weak var delegate: SexSetupProfileDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Пол"
        setupViews()
        setupConstraints()
        setupSexes()
    }

    // MARK: - Setup views
    private func setupViews() {
        if let image = UIImage(named: "sex.setup.background")?.withTintColor(Colors.Elements.element.withAlphaComponent(0.5)) {
            addBackground(image)
        }
        view.backgroundColor = .systemBackground
        view.addSubview(infoLabel)
        view.addSubview(nextButton)
        view.addSubview(sexStackView)
    }

    // MARK: - Functions
    private func setupSexes() {
        for item in sexArray {
            let sexSelector = SexSelector(
                title: item.title,
                iconImage: item.iconImage,
                backgroundColor: item.backgroundColor,
                elementSize: Constants.sizeSexButton,
                delegate: self,
                sex: item.sex
            )
            sexStackView.addArrangedSubview(sexSelector)
        }
    }
    
    // MARK: - Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        delegate?.goNext(with: selectedSex)
    }
}

// MARK: - Setup constraints
extension SexSetupProfileVC {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44),
            nextButton.heightAnchor.constraint(equalToConstant: DButtonStyle.fill.height)
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

// MARK: - SexSelectorDelegate
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

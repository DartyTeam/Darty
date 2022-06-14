//
//  InterestsSetupProfile.swift
//  Darty
//
//  Created by Руслан Садыков on 26.03.2022.
//

import UIKit
import FirebaseAuth
import Magnetic
import SafeSFSymbols
import SpriteKit
import SPAlert

final class InterestsSetupProfile: BaseController {

    // MARK: - UI Elements
    private lazy var nextButton: DButton = {
        let button = DButton(title: "Готово 􀆅")
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()

    private let bottomView: UIVisualEffectView = {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blurEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blurEffectView.layer.cornerRadius = 30
        blurEffectView.layer.cornerCurve = .continuous
        blurEffectView.layer.masksToBounds = true
        return blurEffectView
    }()

    private lazy var searchController = UISearchController(searchResultsController: nil)

    // MARK: - Properties
    private var isFiltering: Bool {
        return !searchBarIsEmpty
    }

    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }

    private var selectedInterests = [Int]()
    private var magnetic: Magnetic?

    // MARK: - Delegate
    weak var delegate: InterestsSetupProfileDelegate?

    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        let magneticView = MagneticView(frame: self.view.bounds)
        magnetic = magneticView.magnetic
        magnetic?.magneticDelegate = self
        self.view.addSubview(magneticView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Интересы"
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupInterests()
    }

    private func setupNavigationBar() {
        clearNavBar = false
        let image = UIImage(.magnifyingglass, font: .boldSystemFont(ofSize: 18))
        let magniyingglassButton = UIBarButtonItem(
            image: image.withTintColor(
                .systemBlue,
                renderingMode: .alwaysOriginal
            ),
            style: .plain,
            target: self,
            action: #selector(searchAction)
        )
        navigationItem.rightBarButtonItem = magniyingglassButton
    }

    private func setupViews() {
        magnetic?.backgroundColor = .systemBackground
        view.addSubview(bottomView)
        bottomView.contentView.addSubview(nextButton)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        magnetic?.backgroundColor = .systemBackground
        updateChildNodesAfterChangeDarkMode()
    }

    private func updateChildNodesAfterChangeDarkMode() {
        let alertView = SPAlertView(title: "Обновление интересов после смены темы", preset: .spinner)
        alertView.duration = 3
        alertView.dismissInTime = true
        alertView.dismissByTap = true
        alertView.present()
        self.magnetic?.removeAllChildren()
        setupInterests()
    }

    private func setupInterests() {
        guard !ConfigService.shared.interestsArray.isEmpty else {
            let alertView = SPAlertView(title: "Загрузка списка интересов", preset: .spinner)
            alertView.present()
            ConfigService.shared.getInterests { result in
                DispatchQueue.main.async {
                    alertView.dismiss()
                    switch result {
                    case .success(_):
                        self.addInterestsNodes()
                    case .failure(_):
                        SPAlert.present(
                            title: "Ошибка загрузки списка интересов",
                            message: "Пропробуйте снова позже",
                            preset: .error
                        )
                    }
                }
            }
            return
        }
        self.addInterestsNodes()
    }

    private func addInterestsNodes() {
        DispatchQueue.global(qos: .userInitiated).async {
            for (i, interest) in ConfigService.shared.interestsArray.enumerated() {
                let bubbleColors = [
                    Colors.Bubbles.indigoBubble,
                    Colors.Bubbles.orangeBubble,
                    Colors.Bubbles.pinkBubble,
                    Colors.Bubbles.purplrBubble
                ]
                let randomColor = bubbleColors.randomElement() ?? .systemPurple
                let image = interest.emoji.textToImage(bgColor: randomColor, needMoreSmallText: true)
                let interestNode = InterestNode(
                    text: interest.title,
                    image: image,
                    color: randomColor,
                    radius: 20,
                    marginScale: 2
                )
                interestNode.index = i
                self.magnetic?.addChild(interestNode)
                if self.selectedInterests.contains(i) {
                    interestNode.isSelected = true
                }
            }
        }
    }

    private func getAllNodes() -> [InterestNode] {
        guard let magnetic = magnetic else { return [] }
        return magnetic.children.compactMap { $0 as? InterestNode }
    }

    // MARK: - Handlers
    @objc private func doneButtonTapped() {
        delegate?.goNext(with: selectedInterests)
    }

    @objc private func searchAction() {
        delegate?.showSearch(with: selectedInterests, selectionDelegate: self)
    }
}

// MARK: - Setup constraints
extension InterestsSetupProfile {
    private func setupConstraints() {
        bottomView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
        }

        nextButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(UIButton.defaultButtonHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
    }
}

extension InterestsSetupProfile: MagneticDelegate {
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
        guard let node = node as? InterestNode else { return }
        selectedInterests.removeAll(where: { $0 == node.index })
    }

    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
        guard let node = node as? InterestNode else { return }
        selectedInterests.append(node.index)
    }
}

extension InterestsSetupProfile: SearchInterestsSetupProfileSelectionDelegate {
    func selected(interests: [Int]) {
        selectedInterests = interests
        let children = getAllNodes()
        for item in children {
            if selectedInterests.contains(item.index), !item.isSelected {
                item.isSelected = true
                item.selectedAnimation()
            } else if !selectedInterests.contains(item.index), item.isSelected {
                item.isSelected = false
                item.deselectedAnimation()
            }
        }
    }
}

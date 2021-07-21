//
//  WelcomeVC.swift
//  Darty
//
//  Created by Руслан Садыков on 29.06.2021.
//

private struct AboutInfoModel {
    let title: String
    let subtitle: String
    let iconImage: UIImage?
    let iconBackgroundColor: UIColor
}

import UIKit

final class WelcomeVC: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor : UIColor.black, .paragraphStyle: paragraph]

        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor : UIColor.systemPurple, .paragraphStyle: paragraph]

        let attributedString1 = NSMutableAttributedString(string:"Что можно делать в", attributes:attrs1)

        let attributedString2 = NSMutableAttributedString(string:" Darty?", attributes:attrs2)

        attributedString1.append(attributedString2)
        label.attributedText = attributedString1
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(AboutCell.self, forCellReuseIdentifier: AboutCell.reuseIdentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(title: "Веселиться!")
        button.backgroundColor = .systemPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(continueAction), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Variables
    private let aboutArray = [
        AboutInfoModel(title: "Создавать и искать вечеринки",
                       subtitle: "Вписка или танцевальная вечеринка? А может, домашний хакатон? Все это уже в твоих руках",
                       iconImage: UIImage(systemName: "flame")?.withTintColor(.white, renderingMode: .alwaysOriginal),
                       iconBackgroundColor: .systemOrange),
        AboutInfoModel(title: "Общаться и заводить новых друзей",
                       subtitle: "Обменивайся сообщениями не выходя из приложения",
                       iconImage: UIImage(systemName: "message")?.withTintColor(.white, renderingMode: .alwaysOriginal),
                       iconBackgroundColor: .systemTeal),
        AboutInfoModel(title: "Рассказать о себе всему миру",
                       subtitle: "Заполни профиль и отправляй заявки на вечеринки. Организатор и другие гости обязательно оценят твою карточку",
                       iconImage: UIImage(systemName: "person")?.withTintColor(.white, renderingMode: .alwaysOriginal),
                       iconBackgroundColor: .systemBlue),
        AboutInfoModel(title: "Читать и оставлять отзывы",
                       subtitle: "Делись эмоциями и узнавай больше о наших тусовщиках",
                       iconImage: UIImage(systemName: "hand.thumbsup")?.withTintColor(.white, renderingMode: .alwaysOriginal),
                       iconBackgroundColor: .systemYellow),
        AboutInfoModel(title: "Весело проводить время",
                       subtitle: "Хватит это читать. Скорее жми кнопку ниже и начинай веселье!",
                       iconImage: UIImage(systemName: "face.smiling")?.withTintColor(.white, renderingMode: .alwaysOriginal),
                       iconBackgroundColor: .systemGreen),
        
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        
        view.addSubview(tableView)
        view.addSubview(continueButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -(UIScreen.main.bounds.height / 3)),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
        
        NSLayoutConstraint.activate([
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44)
        ])
    }
    
    // MARK: - Handlers
    @objc private func continueAction() {
        UserDefaults.standard.isPrevLaunched = true
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension WelcomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aboutArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AboutCell.reuseIdentifier) as? AboutCell else { return UITableViewCell() }
        let data = aboutArray[indexPath.row]
        cell.setupCell(backIconColor: data.iconBackgroundColor, iconImage: data.iconImage, title: data.title, subtitle: data.subtitle)
        
        return cell
    }
}

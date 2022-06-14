//
//  NotificationSettingsVC.swift
//  Darty
//
//  Created by Руслан Садыков on 30.04.2022.
//

import UIKit

final class NotificationSettingsVC: BaseController {

    // MARK: - Constants
    private enum Constants {
        static let spaceBetweenCells: CGFloat = 24
    }

    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            NotificationSettingsCell.self,
            forCellReuseIdentifier: NotificationSettingsCell.reuseIdentifier
        )
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    // MARK: - Properties
    private var notificationSettings: [NotificationSettingsModel] = [
        NotificationSettingsModel(title: "Сообщения", isEnabled: true),
        NotificationSettingsModel(title: "Об отмене вечеринок", isEnabled: true),
        NotificationSettingsModel(title: "О приглашении на вечеринку", isEnabled: true),
        NotificationSettingsModel(title: "Об отказе в приглашении", isEnabled: true)
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Уведомления"
        setupViews()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setIsTabBarHidden(true)
    }

    // MARK: - Setup
    private func setupViews() {
        view.addSubview(tableView)
    }
}

// MARK: - Setup constraints
extension NotificationSettingsVC {
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension NotificationSettingsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return notificationSettings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationSettingsCell.reuseIdentifier,
            for: indexPath
        ) as? NotificationSettingsCell else {
            return UITableViewCell()
        }
        let model = notificationSettings[indexPath.section]
        cell.configure(with: model)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.spaceBetweenCells
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}

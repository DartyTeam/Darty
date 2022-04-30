//
//  NotificationSettingsCell.swift
//  Darty
//
//  Created by Руслан Садыков on 30.04.2022.
//

import UIKit

protocol NotificationSettingsDelegate: AnyObject {
    func notification(isEnabled: Bool)
}

final class NotificationSettingsCell: UITableViewCell {

    // MARK: - Constants
    private enum Constants {
        static let titleFont: UIFont? = .sfProDisplay(ofSize: 20, weight: .semibold)
        static let elementsSpacing: CGFloat = 16
    }

    // MARK: - UI Elements
    private let selectionEffectView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray.withAlphaComponent(0.3)
        view.alpha = 0
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleFont
        label.numberOfLines = 0
        return label
    }()

    private let switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.addTarget(
            self,
            action: #selector(switcherChanged(_:)),
            for: .valueChanged
        )
        switcher.onTintColor = .systemIndigo
        return switcher
    }()

    private let backView = UIView()

    // MARK: - Delegate
    weak var delegate: NotificationSettingsDelegate?

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        backView.backgroundColor = .tertiarySystemBackground
        backView.layer.cornerRadius = 12
        backView.layer.cornerCurve = .continuous
        backView.clipsToBounds = true
        contentView.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        backView.addSubview(selectionEffectView)
        selectionEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backView.addSubview(titleLabel)
        backView.addSubview(switcher)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.left.equalToSuperview().inset(Constants.elementsSpacing)
            make.right.equalTo(switcher.snp.left).inset(Constants.elementsSpacing)
        }
        switcher.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.right.equalToSuperview().inset(Constants.elementsSpacing)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(with model: NotificationSettingsModel) {
        titleLabel.text = model.title
        switcher.isOn = model.isEnabled
    }

    // MARK: - Handlers
    @objc private func switcherChanged(_ sender: UISwitch) {
        delegate?.notification(isEnabled: sender.isOn)
    }

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.selectionEffectView.alpha = 1
            } completion: { _ in
                self.selectionEffectView.alpha = 0
            }
            switcher.setOn(!switcher.isOn, animated: true)
        }
    }
}

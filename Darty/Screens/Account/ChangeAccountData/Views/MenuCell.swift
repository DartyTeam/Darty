//
//  MenuCell.swift
//  Darty
//
//  Created by Руслан Садыков on 17.06.2022.
//

import UIKit

class MenuCell: UITableViewCell {

    // MARK: - UI Elements
    private let selectedEffectView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Backgorunds.plate
        return view
    }()

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.Elements.element
        label.font = .button
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.Elements.element
        label.font = .button
        label.textAlignment = .left
        return label
    }()

    private let rightArrowLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.Elements.element
        label.font = .button
        label.text = "􀆊"
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.selectedEffectView.alpha = 1
            } completion: { _ in
                self.selectedEffectView.alpha = 0
            }
        }
    }

    // MARK: - Setup
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(selectedEffectView)
        contentView.addSubview(iconLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(rightArrowLabel)
    }

    private func setupConstraints() {
        selectedEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(13)
            make.left.equalToSuperview().offset(28)
        }

        rightArrowLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-28)
            make.centerY.equalTo(iconLabel.snp.centerY)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconLabel.snp.centerY)
            make.right.lessThanOrEqualTo(rightArrowLabel.snp.left).offset(-12)
            make.left.equalTo(iconLabel.snp.right).offset(12)
        }
    }

    func configure(with context: Context) {
        iconLabel.text = context.icon
        titleLabel.text = context.title
        iconLabel.textColor = context.color
        titleLabel.textColor = context.color
        rightArrowLabel.textColor = context.color
    }
}

extension MenuCell {
    struct Context {
        let title: String
        let icon: String
        var color: UIColor = Colors.Elements.element
    }
}

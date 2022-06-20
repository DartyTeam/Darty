//
//  AudioRecordView.swift
//  Darty
//
//  Created by Руслан Садыков on 05.04.2022.
//

import UIKit

protocol AudioRecordViewDelegate: AnyObject {
    func cancelTapped()
}

final class AudioRecordView: UIVisualEffectView {

    // MARK: - Constants
    private enum Constants {
        static let statusRecordViewSize: CGFloat = 8
        static let startTimerText = "00:00"
    }

    // MARK: - UI Elements
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.startTimerText
        return label
    }()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "􀆉  Влево – отмена"
        label.font = .sfProDisplay(ofSize: 14, weight: .medium)
        return label
    }()
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отмена", for: UIControl.State())
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.systemTeal, for: UIControl.State())
        button.isHidden = true
        return button
    }()
    private let statusRecordView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Elements.element
        view.layer.cornerRadius = Constants.statusRecordViewSize / 2
        return view
    }()

    // MARK: - Properties
    private var recordAudioTimer: Timer?
    private var recordAudioCounter: Int = 0

    // MARK: - Observation
    private var observation: NSKeyValueObservation?

    // MARK: - Delegate
    weak var delegate: AudioRecordViewDelegate?
    private let cancelTappableViewRightInset: CGFloat

    // MARK: - Init
    init(effect: UIVisualEffect?, cancelTappableViewRightInset: CGFloat) {
        self.cancelTappableViewRightInset = cancelTappableViewRightInset
        super.init(effect: effect)
        observation = observe(\.isHidden, options: .new) { (object, change) in
            if change.newValue == false {
                object.startTimer()
            } else {
                object.invalidateTimer()
            }
        }
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(statusRecordView)
        statusRecordView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.size.equalTo(Constants.statusRecordViewSize)
            make.left.equalToSuperview().offset(32)
        }

        contentView.addSubview(timerLabel)
        timerLabel.snp.makeConstraints { make in
            make.left.equalTo(statusRecordView.snp.right).offset(16)
            make.centerY.equalTo(statusRecordView.snp.centerY)
        }

        contentView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(statusRecordView.snp.centerY)
        }
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(statusRecordView.snp.centerY)
            make.height.equalTo(44)
        }
    }

    // MARK: - Functions
    private func startTimer() {
        recordAudioTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordAudioCounter += 1
            let components = DateComponents(second: self.recordAudioCounter)
            guard let date = Calendar.current.date(from: components) else { return }
            self.timerLabel.text = DateFormatter.mmSS.string(from: date)
        }
    }

    func startInfoLabelAnimation() {
        self.infoLabel.center.x -= 10
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.infoLabel.center.x += 10
        }, completion: nil)
    }

    private func invalidateTimer() {
        recordAudioTimer?.invalidate()
        recordAudioTimer = nil
        recordAudioCounter = 0
        timerLabel.text = Constants.startTimerText
    }

    func setTapToCancel() {
        cancelButton.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        contentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
        infoLabel.isHidden = true
        cancelButton.isHidden = false
    }

    func setSwipeToCancel() {
        infoLabel.alpha = 1
        infoLabel.isHidden = false
        cancelButton.isHidden = true
    }

    @objc private func cancelAction(_ sender: UIGestureRecognizer) {
        delegate?.cancelTapped()
    }

    private var animationCompleted = false
    func slideInfoLabel(offset: CGFloat) {
        if infoLabel.alpha == 1 {
            UIView.animate(withDuration: 0.6) {
                self.infoLabel.alpha = offset / 1000
            } completion: { _ in
                self.animationCompleted = true
            }
        } else if animationCompleted {
            infoLabel.layer.removeAllAnimations()
        }
        infoLabel.center.x = offset - 100
    }
}

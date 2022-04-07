//
//  AudioRecordView.swift
//  Darty
//
//  Created by Руслан Садыков on 05.04.2022.
//

import UIKit

final class AudioRecordView: UIView {

    // MARK: - Constants
    private enum Constants {
        static let statusRecordViewSize: CGFloat = 4
    }
    // MARK: - UI Elements
    private let timerLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let leftToCancelLabel: UILabel = {
        let label = UILabel()
        label.text = "􀆉  Влево – отмена"
        label.font = .sfProDisplay(ofSize: 14, weight: .medium)
        return label
    }()

    private let statusRecordView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange
        view.layer.cornerRadius = Constants.statusRecordViewSize / 2
        return view
    }()

    // MARK: - Properties
    private var recordAudioTimer: Timer?
    private var recordAudioCounter: Int = 0

    // MARK: - Observation
    private var observation: NSKeyValueObservation?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        observation = observe(\.isHidden, options: .new) { (object, change) in
            if change.newValue == false {
                object.startTimer()
            } else {
                object.invalidateTimer()
            }
        }
        setupViews()
        timerLabel.text = "0:00"
    }

    // MARK: - Setup
    private func setupViews() {
        addSubview(statusRecordView)
        statusRecordView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.size.equalTo(Constants.statusRecordViewSize)
            make.left.equalToSuperview().offset(32)
        }

        addSubview(timerLabel)
        timerLabel.snp.makeConstraints { make in
            make.left.equalTo(statusRecordView.snp.right).offset(16)
            make.centerY.equalTo(statusRecordView.snp.centerY)
        }

        addSubview(leftToCancelLabel)
        leftToCancelLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(statusRecordView.snp.centerY)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    private func startTimer() {
        startLeftToCacelLabelAnimation()
        recordAudioTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordAudioCounter += 1
            let components = DateComponents(second: self.recordAudioCounter)
            guard let date = Calendar.current.date(from: components) else { return }
            self.timerLabel.text = DateFormatter.mmSS.string(from: date)
        }
    }

    private func startLeftToCacelLabelAnimation() {
        self.leftToCancelLabel.center.x -= 10
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.leftToCancelLabel.center.x += 10
        }, completion: nil)
    }

    private func invalidateTimer() {
        recordAudioTimer?.invalidate()
        recordAudioTimer = nil
        recordAudioCounter = 0
        timerLabel.text = "0:00"
    }
}

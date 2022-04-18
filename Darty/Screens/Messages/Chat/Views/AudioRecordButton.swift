//
//  AudioRecordButton.swift
//  Darty
//
//  Created by Руслан Садыков on 05.04.2022.
//


import UIKit
import Lottie
import SPSafeSymbols

protocol AudioRecordButtonDelegate: AnyObject {
    func sendButtonTapped()
}

final class AudioRecordButton: UIView {

    enum State {
        case record
        case delete
        case end
        case stayRecord
    }

    // MARK: - UIElements
    private let animationView = AnimationView(name: "MicButton")
    private let deleteView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = .systemRed
        return view
    }()
    private let deleteImageView = UIImageView(image: UIImage(.trash).withTintColor(.white, renderingMode: .alwaysOriginal))
    private let sendView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemTeal
        view.alpha = 0
        return view
    }()
    private let sendButton: UIButton = {
        let button = UIButton()
        let sendImage = UIImage(.paperplane).withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(sendImage, for: UIControl.State())
        return button
    }()

    // MARK: - Delegate
    weak var delegate: AudioRecordButtonDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        super.init(frame: frame)
        layer.cornerRadius = frame.size.height / 2
        clipsToBounds = true
        addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.size.equalTo(56)
            make.edges.equalToSuperview()
        }
        animationView.contentMode = .scaleToFill

        animationView.addSubview(deleteView)
        deleteView.snp.makeConstraints { make in
            make.edges.equalTo(animationView)
        }
        deleteView.addSubview(deleteImageView)
        deleteImageView.snp.makeConstraints { make in
            make.edges.equalTo(deleteView).inset(8)
        }

        animationView.addSubview(sendView)
        sendView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        sendView.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func didMoveToSuperview() {
        guard superview != nil else { return }
        print("asodijasdiojasdoiajsdoiajsdoiasjdasdasdasdasd")
        animateAppear()
    }

    // MARK: - Functions
    private func animateAppear() {
        animationView.play()
    }

    func update(center: CGPoint, state: State, completion: (()->())? = nil) {
        let scaleValue = center.x / 400
        let scaleFinal = scaleValue <= 1 ? scaleValue : 1
        transform = CGAffineTransform(scaleX: scaleFinal, y: scaleFinal)
        switch state {
        case .record:
            self.center = center
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.deleteView.alpha = 0
            } completion: { _ in
                completion?()
            }
        case .stayRecord:
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.center = center
                self?.sendView.alpha = 1
            } completion: { _ in
                completion?()
            }
        case .delete:
            self.center = center
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.deleteView.alpha = 1
            } completion: { _ in
                completion?()
            }
        case .end:
            self.center = center
            self.deleteView.alpha = 0
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.sendView.alpha = 0
                self?.animationView.stop()
            } completion: { [weak self] _ in
                completion?()
                self?.removeFromSuperview()
            }
        }
    }

    // MARK: - Handlers
    @objc private func sendButtonTapped() {
        delegate?.sendButtonTapped()
    }
}

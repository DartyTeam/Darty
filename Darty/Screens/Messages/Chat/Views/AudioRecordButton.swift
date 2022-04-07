//
//  AudioRecordButton.swift
//  Darty
//
//  Created by Руслан Садыков on 05.04.2022.
//


import UIKit
import Lottie

final class AudioRecordButton: UIView {

    enum State {
        case record
        case delete
        case end
    }

    // MARK: - UIElements
    private let animationView = AnimationView(name: "MicButton")
    private let deleteImageView = UIImageView(image: UIImage(.trash))

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.edges.equalToSuperview()
        }
        animationView.addSubview(deleteImageView)
        deleteImageView.snp.makeConstraints { make in
            make.edges.equalTo(animationView)
        }
        deleteImageView.alpha = 0
        backgroundColor = .red
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        guard superview != nil else { return }
        print("asodijasdiojasdoiajsdoiajsdoiasjdasdasdasdasd")
        animateAppear()
    }

    // MARK: - Functions
    private func animateAppear() {
        animationView.play()
    }

    func animateDisappear() {
        UIView.animate(withDuration: 0.3,
                       animations: { [weak self] in
            self?.animationView.stop()
        },
                       completion: { [weak self] _ in
            self?.removeFromSuperview()
        })
    }

    func update(center: CGPoint, state: State) {
        self.center = center
        switch state {
        case .record:
            UIView.animate(withDuration: 0.3) { [weak self] in
            }
        case .delete:
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.deleteImageView.alpha = 1
            }
        case .end:
            animateDisappear()
        }
    }
}

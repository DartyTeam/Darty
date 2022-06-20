//
//  AudioMessageCell.swift
//  Darty
//
//  Created by Руслан Садыков on 15.06.2022.
//

import MessageKit
import SafeSFSymbols

open class DAudioMessageCell: AudioMessageCell {
    // The play button view to display on audio messages.
    lazy var dartyPlayButton: UIButton = {
        let playButton = UIButton(type: .custom)
        let playImage = UIImage(named: "play")
        let pauseImage = UIImage(named: "pause")
        playButton.setImage(playImage, for: .normal)
        playButton.setImage(pauseImage, for: .selected)
        return playButton
    }()

    /// The time duration lable to display on audio messages.
    lazy var dartyDurationLabel: UILabel = {
        let durationLabel = UILabel()
        durationLabel.font = .textOnPlate
        durationLabel.text = "0:00"
        durationLabel.textColor = Colors.Text.secondary
        return durationLabel
    }()

    private lazy var dartyActivityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.isHidden = true
        return activityIndicatorView
    }()

    lazy var dartyProgressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.0
        progressView.trackTintColor = Colors.Elements.line
        return progressView
    }()

    // MARK: - Methods

    /// Responsible for setting up the constraints of the cell's subviews.
    open override func setupConstraints() {
        dartyPlayButton.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.left.equalToSuperview().offset(8)
            make.top.bottom.equalToSuperview().inset(6)
        }

        dartyActivityIndicatorView.snp.makeConstraints { make in
            make.center.equalTo(dartyPlayButton.snp.center)
        }

        dartyProgressView.snp.makeConstraints { make in
            make.left.equalTo(dartyPlayButton.snp.right).offset(6)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
        }
        
        dartyDurationLabel.snp.makeConstraints { make in
            make.left.equalTo(dartyProgressView.snp.left)
            make.right.equalTo(dartyProgressView.snp.right)
            make.top.equalTo(dartyProgressView.snp.bottom).offset(6)
        }
    }

    open override func setupSubviews() {
        setupSubviewsFromParentClass()
        messageContainerView.addSubview(dartyPlayButton)
        messageContainerView.addSubview(dartyActivityIndicatorView)
        messageContainerView.addSubview(dartyDurationLabel)
        messageContainerView.addSubview(dartyProgressView)
        setupConstraints()
    }

    private func setupSubviewsFromParentClass() {
        contentView.addSubview(accessoryView)
        contentView.addSubview(cellTopLabel)
        contentView.addSubview(messageTopLabel)
        contentView.addSubview(messageBottomLabel)
        contentView.addSubview(cellBottomLabel)
        contentView.addSubview(messageContainerView)
        contentView.addSubview(avatarView)
        contentView.addSubview(messageTimestampLabel)
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        dartyProgressView.progress = 0
        dartyPlayButton.isSelected = false
        dartyActivityIndicatorView.stopAnimating()
        dartyPlayButton.isHidden = false
        dartyDurationLabel.text = "0:00"
    }

    /// Handle tap gesture on contentView and its subviews.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        // compute play button touch area, currently play button size is (25, 25) which is hardly touchable
        // add 10 px around current button frame and test the touch against this new frame
        let playButtonTouchArea = CGRect(
            x: dartyPlayButton.frame.origin.x - 10.0,
            y: dartyPlayButton.frame.origin.y - 10,
            width: dartyPlayButton.frame.size.width + 20,
            height: dartyPlayButton.frame.size.height + 20
        )
        let translateTouchLocation = convert(touchLocation, to: messageContainerView)
        if playButtonTouchArea.contains(translateTouchLocation) {
            delegate?.didTapPlayButton(in: self)
        } else {
            super.handleTapGesture(gesture)
        }
    }

    // MARK: - Configure Cell
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError("nilMessagesDataSource")
        }

        if !dataSource.isFromCurrentSender(message: message) {
//            playButtonLeftConstraint?.constant = 12
//            durationLabelRightConstraint?.constant = -8
        } else {
//            playButtonLeftConstraint?.constant = 5
//            durationLabelRightConstraint?.constant = -15
        }

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError("nilMessagesDisplayDelegate")
        }

        let tintColor = displayDelegate.audioTintColor(for: message, at: indexPath, in: messagesCollectionView)
        dartyPlayButton.imageView?.tintColor = tintColor
        dartyProgressView.tintColor = tintColor

        if case let .audio(audioItem) = message.kind {
            dartyDurationLabel.text = displayDelegate.audioProgressTextFormat(
                audioItem.duration,
                for: self,
                in: messagesCollectionView
            )
        }

        displayDelegate.configureAudioCell(self, message: message)
    }
}

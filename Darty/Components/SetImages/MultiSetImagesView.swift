//
//  MultiSetImagesView.swift
//  Darty
//
//  Created by Руслан Садыков on 15.07.2021.
//

import UIKit
import AVFoundation
import Photos
import PhotosUI
import Agrume

protocol MultiSetImagesViewDelegate: AnyObject {
    func showActionSheet(_ actionSheet: UIAlertController)
    func showCamera(_ imagePicker: UIImagePickerController)
    func showImagePicker(_ imagePicker: PHPickerViewController)
    func dismissImagePicker()
    func showError(_ error: String)
    func showFullscreen(_ agrume: Agrume)
}

enum ShapeImageView {
    case round
    case rect
}

final class MultiSetImagesView: UIView {
    
    // MARK: - Constants
    enum Constants {
        static let itemSpace: CGFloat = 40
        static let itemSpaceForMultiItemsInPage: CGFloat = 20
        static let leftRightInsets: CGFloat = 20
    }
    
    // MARK: - UI Elements    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(SetImageViewCell.self, forCellWithReuseIdentifier: SetImageViewCell.reuseIdentifier)
        collectionView.register(SetAddImagesViewCell.self, forCellWithReuseIdentifier: SetAddImagesViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = .fast
        return collectionView
    }()
    
    // MARK: - Properties
    var images: [UIImage] = []
    var numberOfItemInPage: CGFloat = 1
    var isPagingEnabled = true {
        didSet {
            collectionView.isPagingEnabled = isPagingEnabled
        }
    }
    weak var delegate: MultiSetImagesViewDelegate?
    private let maxPhotos: Int!
    private let shape: ShapeImageView!
    private let color: UIColor!
    
    private var cellFrame: CGRect = CGRect.zero
    
    // MARK: - Lifecycle
    init(maxPhotos: Int, shape: ShapeImageView, color: UIColor, delegate: MultiSetImagesViewDelegate? = nil) {
        self.delegate = delegate
        self.maxPhotos = maxPhotos
        self.shape = shape
        self.color = color
        super.init(frame: CGRect.zero)
        setupView()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(collectionView)
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Handlers
    @objc private func deleteAction(_ sender: UIButton) {
        images.remove(at: sender.tag)
        let indexPath = IndexPath(item: sender.tag, section: 0)
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at:[indexPath])
        }) { flag in
            self.collectionView.reloadData()
        }
    }
    
    @objc private func showFullscreenAction(_ sender: UITapGestureRecognizer) {
        sender.view?.showAnimation { [weak self] in
            // Create an array of images.
            var images: [UIImage] = []
            self?.images.forEach { image in
                images.append(image)
            }

            let button = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
//            button.tintColor = .systemOra
            
            // In case of an array of [UIImage]:
            let agrume = Agrume(images: images, startIndex: sender.view?.tag ?? 0, background: .blurred(.light), dismissal: .withPhysicsAndButton(button))
            // Or an array of [URL]:
            // let agrume = Agrume(urls: urls, startIndex: indexPath.item, background: .blurred(.light))

            agrume.didScroll = { [unowned self] index in
              self?.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: [], animated: false)
            }
            
            self?.delegate?.showFullscreen(agrume)
        }
    }
}

extension MultiSetImagesView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - (Constants.itemSpace / (numberOfItemInPage == 0 ? 1 : 2)) * numberOfItemInPage) / numberOfItemInPage
        return CGSize(width: width, height: self.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.itemSpace / (numberOfItemInPage == 0 ? 1 : 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: Constants.leftRightInsets / (numberOfItemInPage == 0 ? 1 : 2), bottom: 0, right: Constants.leftRightInsets / (numberOfItemInPage == 0 ? 1 : 2))
    }
}

//extension MultiSetImagesView: UIScrollViewDelegate {
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//
//        let pageWidth = Float(itemWidth + itemSpacing)
//        let targetXContentOffset = Float(targetContentOffset.pointee.x)
//        let contentWidth = Float(collectionView.contentSize.width  )
//        var newPage = Float(self.pageControl.currentPage)
//
//        if velocity.x == 0 {
//            newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
//        } else {
//            newPage = Float(velocity.x > 0 ? self.pageControl.currentPage + 1 : self.pageControl.currentPage - 1)
//            if newPage < 0 {
//                newPage = 0
//            }
//            if (newPage > contentWidth / pageWidth) {
//                newPage = ceil(contentWidth / pageWidth) - 1.0
//            }
//        }
//
//        self.pageControl.currentPage = Int(newPage)
//        let point = CGPoint (x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
//        targetContentOffset.pointee = point
//    }
//}

extension MultiSetImagesView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if maxPhotos == 1 {
            return 1
        } else if images.count == maxPhotos {
            return maxPhotos
        } else {
            return (images.count + 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   
        if indexPath.row == images.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SetAddImagesViewCell.reuseIdentifier, for: indexPath) as! SetAddImagesViewCell
            cell.setupCell(delegate: self, maxPhotos: (maxPhotos - images.count), shape: shape, color: color)
            cellFrame = cell.frame
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SetImageViewCell.reuseIdentifier, for: indexPath) as! SetImageViewCell
            cell.deleteButton.tag = indexPath.item
            cell.deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchDown)
            cell.setupCell(image: images[indexPath.row], shape: shape, color: color)
            cell.tag = indexPath.row
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFullscreenAction))
            tapRecognizer.numberOfTapsRequired = 1
            cell.addGestureRecognizer(tapRecognizer)
            return cell
        }
    }
}

//extension MultiSetImagesView: LightboxControllerDismissalDelegate {
//    func lightboxControllerWillDismiss(_ controller: LightboxController) {
//        collectionView.scrollToItem(at: [0,controller.currentPage], at: .centeredHorizontally, animated: false)
//    }
//}

extension MultiSetImagesView: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        #warning("Это пока не используется, т.к. controller.transitioningDelegate = self закомменченно")
        print("asdkasdioaksdoiajd: ", CGRect(x: self.frame.minX + 20, y: self.frame.minY, width: self.frame.width - 40, height: self.frame.height))
        return AnimatorPresent(startFrame: CGRect(x: self.frame.minX + 20, y: self.frame.minY, width: self.frame.width - 40, height: self.frame.height))
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatorDismiss(endFrame: CGRect(x: self.frame.minX + 20, y: self.frame.minY, width: self.frame.width - 40, height: self.frame.height))
    }
}

extension MultiSetImagesView: SetImageDelegate {
    func showActionSheet(_ actionSheet: UIAlertController) {
        delegate?.showActionSheet(actionSheet)
    }
    
    func showCamera(_ imagePicker: UIImagePickerController) {
        delegate?.showCamera(imagePicker)
    }
    
    func showImagePicker(_ imagePicker: PHPickerViewController) {
        delegate?.showImagePicker(imagePicker)
    }
    
    func imagesDidSet(_ images: [UIImage]) {
        for image in images {
            self.images.append(image)
        }
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
        collectionView.performBatchUpdates({
                            let indexSet = IndexSet(integersIn: 0...0)
                            collectionView.reloadSections(indexSet)
                        }, completion: nil)
    }
    
    func dismissImagePicker() {
        delegate?.dismissImagePicker()
    }
    
    func showError(_ error: String) {
        delegate?.showError(error)
    }
}

class AnimatorPresent: NSObject, UIViewControllerAnimatedTransitioning {
    let startFrame: CGRect

    init(startFrame: CGRect) {
        self.startFrame = startFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let vcTo = transitionContext.viewController(forKey: .to),
        let snapshot = vcTo.view.snapshotView(afterScreenUpdates: true) else {
            return
        }

        let vContainer = transitionContext.containerView

        vcTo.view.isHidden = true
        vContainer.addSubview(vcTo.view)

        snapshot.frame = self.startFrame
        vContainer.addSubview(snapshot)

        UIView.animate(withDuration: 0.3, animations: {
            snapshot.frame = (transitionContext.finalFrame(for: vcTo))
        }, completion: { success in
            vcTo.view.isHidden = false
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}

class AnimatorDismiss: NSObject, UIViewControllerAnimatedTransitioning {

    let endFrame: CGRect

    init(endFrame: CGRect) {
        self.endFrame = endFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let vcTo = transitionContext.viewController(forKey: .to),
        let vcFrom = transitionContext.viewController(forKey: .from),
        let snapshot = vcFrom.view.snapshotView(afterScreenUpdates: true) else {
            return
        }

        let vContainer = transitionContext.containerView
        vContainer.addSubview(vcTo.view)
        vContainer.addSubview(snapshot)

        vcFrom.view.isHidden = true

        UIView.animate(withDuration: 0.3, animations: {
            snapshot.frame = self.endFrame
        }, completion: { success in
            transitionContext.completeTransition(true)
        })
    }
}

//
//  UIViewController + Extensions.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import UIKit
import Inject

class BaseController: UIViewController {

    var rightBarButtonItems: [UIBarButtonItem]? {
        didSet {
            navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: true)
        }
    }

    var clearNavBar = true {
        didSet {
            navigationController?.navigationBar.setup(withClear: clearNavBar)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup(viewController: self)
        clearNavBar = true
        view.backgroundColor = Colors.Backgorunds.screen
    }
}

private func setup(viewController: UIViewController) {
    viewController.navigationController?.setNavigationBarHidden(false, animated: true)
    viewController.navigationItem.setHidesBackButton(true, animated: false)
    if let index = viewController.navigationController?.viewControllers.firstIndex(of: viewController), index > 0 {
        addBackButton(for: viewController)
    } else if let parentHost = viewController.parent,
              let index = viewController.navigationController?.viewControllers.firstIndex(of: parentHost),
              index > 0 {
        addBackButton(for: viewController)
    }

    //            let leftBarButtonItem = UIBarButtonItem(customView: view)
    //            leftBarButtonItem.setBackgroundVerticalPositionAdjustment(30, for: .default)
    //            self.navigationItem.leftBarButtonItem?.setBackButtonBackgroundVerticalPositionAdjustment(16, for: .default)

    viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    viewController.navigationController?.interactivePopGestureRecognizer?.delegate = viewController
}

private func addBackButton(for viewController: UIViewController) {
    let leftBarButtonItem = UIBarButtonItem(
        symbol: .chevron.backward,
        type: .normal,
        target: viewController,
        action: #selector(viewController.backAction)
    )
//            leftBarButtonItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)

    viewController.navigationItem.leftBarButtonItem = leftBarButtonItem
}

extension UIViewController {
    func setupBaseNavBar(withClear: Bool = true, rightBarButtonItems: [UIBarButtonItem] = []) {
        setup(viewController: self)
        navigationController?.navigationBar.setup(withClear: withClear)
        navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: true)
    }

    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension UIViewController {
    
    func showAlert(title: String, message: String, completion: @escaping () -> Void = { }) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func addBackground(_ image: UIImage) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = image
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        
        view.addSubview(imageViewBackground)
        view.sendSubviewToBack(imageViewBackground)
    }
    
    func configure<T: SelfConfiguringCell, P: Hashable>(collectionView: UICollectionView, cellType: T.Type, with value: P, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseId, for: indexPath) as? T else { fatalError("Unable to dequeue \(cellType)")}
        cell.configure(with: value)
        return cell
    }
    
    func startLoading() {
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.tag = 999
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func stopLoading() {
        for subview in view.subviews {
            if let loadingIndicator = subview as? UIActivityIndicatorView, loadingIndicator.tag == 999 {
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()
            }
        }
        view.isUserInteractionEnabled = true
    }
    
    var alertController: UIAlertController? {
        guard let alert = UIApplication.topViewController() as? UIAlertController else { return nil }
        return alert
    }

    var isDarkMode: Bool {
        if #available(iOS 13.0, *) {
            return self.traitCollection.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
}

extension UIViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

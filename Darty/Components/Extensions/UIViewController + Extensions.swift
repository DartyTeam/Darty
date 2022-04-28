//
//  UIViewController + Extensions.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import UIKit
import Inject

extension UIViewController {
    
    func showAlert(title: String, message: String, completion: @escaping () -> Void = { }) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setNavigationBar(withColor color: UIColor, title: String? = nil, withClear: Bool = true) {

        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.title = title
        
        self.navigationItem.setHidesBackButton(true, animated:false)

        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            addBackButton(color: color)
        } else if let parentHost = self.parent,
                  let index = navigationController?.viewControllers.firstIndex(of: parentHost),
                  index > 0 {
            addBackButton(color: color)
        }
        
        navigationController?.navigationBar.setup(withColor: color, withClear: withClear)
        
        //            let leftBarButtonItem = UIBarButtonItem(customView: view)
        //            leftBarButtonItem.setBackgroundVerticalPositionAdjustment(30, for: .default)
        //            self.navigationItem.leftBarButtonItem?.setBackButtonBackgroundVerticalPositionAdjustment(16, for: .default)

        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    private func addBackButton(color: UIColor) {
        let boldConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .bold))

        let leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward", withConfiguration: boldConfig)?.withTintColor(color, renderingMode: .alwaysOriginal), style: .plain, target: self, action:  #selector(backToMain))
//            leftBarButtonItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)

        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    @objc func backToMain() {
        self.navigationController?.popViewController(animated: true)
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

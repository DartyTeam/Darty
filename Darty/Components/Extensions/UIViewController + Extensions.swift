//
//  UIViewController + Extensions.swift
//  Darty
//
//  Created by Руслан Садыков on 28.06.2021.
//

import UIKit

extension UIViewController {
        
    func showAlert(title: String, message: String, completion: @escaping () -> Void = { }) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setNavigationBar(withColor color: UIColor, title: String, withClear: Bool = true) {

        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.title = title
        
        self.navigationItem.setHidesBackButton(true, animated:false)

        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            let boldConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .bold))

            let leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward", withConfiguration: boldConfig)?.withTintColor(color, renderingMode: .alwaysOriginal), style: .plain, target: self, action:  #selector(backToMain))
//            leftBarButtonItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)

            self.navigationItem.leftBarButtonItem = leftBarButtonItem
        }
        
        navigationController?.navigationBar.setup(withColor: color, withClear: withClear)
        
        //            let leftBarButtonItem = UIBarButtonItem(customView: view)
        //            leftBarButtonItem.setBackgroundVerticalPositionAdjustment(30, for: .default)
        //            self.navigationItem.leftBarButtonItem?.setBackButtonBackgroundVerticalPositionAdjustment(16, for: .default)
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
}

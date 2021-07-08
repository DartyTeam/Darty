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
    
    func setNavigationBar(withColor color: UIColor, title: String) {

        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.title = title
        
        self.navigationItem.setHidesBackButton(true, animated:false)

        //your custom view for back image with custom size
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 66))
        
        let button = UIButton(frame: CGRect(x: 0, y: 20, width: 0, height: 50))
        button.translatesAutoresizingMaskIntoConstraints = false

        let tap = UITapGestureRecognizer(target: self, action:  #selector(backToMain))
        view.addGestureRecognizer(tap)
        
        let boldConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 24, weight: .bold))
        button.setImage(UIImage(systemName: "chevron.backward", withConfiguration: boldConfig)?.withTintColor(color, renderingMode: .alwaysOriginal), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)
        view.addSubview(button)

        let leftBarButtonItem = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        navigationController?.navigationBar.setup(withColor: color)
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

import UIKit
import SwiftUI

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private enum Constants {
        static let tabBarHeight: CGFloat = 70
    }
    
//    private let bottomSafeInset: CGFloat = UIDevice.current.hasNotch ? 34 : 0
    
    override var selectedIndex: Int {
        didSet {
            floatingTabBar.selected = selectedIndex
        }
    }
    
    private let currentUser: UserModel
    
    private lazy var floatingTabBar: FloatingTabbar = {
        let floatingTabBar = FloatingTabbar(selected: selectedIndex, expand: true, delegate: self)
        return floatingTabBar
    }()
    
    fileprivate lazy var tabBarContainer: UIView = {
        let tabBarContainerView = UIView()
        
        var newFrame = tabBar.frame
        newFrame.size.height = Constants.tabBarHeight
        newFrame.size.width = self.view.frame.width - 24
        newFrame.origin.x = 12
        if UIDevice.current.hasNotch {
            newFrame.origin.y = self.view.frame.height - Constants.tabBarHeight - 34
        } else {
            newFrame.origin.y = self.view.frame.height - Constants.tabBarHeight - 10
        }
        tabBarContainerView.frame = newFrame
        tabBarContainerView.backgroundColor = .clear
        let childView = UIHostingController(rootView: floatingTabBar)
        childView.view.backgroundColor = .clear
        childView.view.frame = tabBarContainerView.bounds
        tabBarContainerView.addSubview(childView.view)
        
        return tabBarContainerView
    }()
        
    init(currentUser: UserModel) {
   
        self.currentUser = currentUser
        AuthService.shared.currentUser = currentUser
  
        super.init(nibName: nil, bundle: nil)
 
        object_setClass(self.tabBar, TabBar.self)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 21, right: 0)
    
        view.addSubview(tabBarContainer)
        
        tabBar.isHidden = true
        setTabBarMenuControllers()
        selectedIndex = 0
    }
    
    private func setTabBarMenuControllers() {
    
        let partiesVC = UINavigationController(rootViewController: TabItem.parties.viewController)
        partiesVC.setNavigationBarHidden(true, animated: false)
        partiesVC.tabBarItem.image = TabItem.parties.icon
        partiesVC.tabBarItem.selectedImage = TabItem.parties.selectedIcon?.withRenderingMode(.alwaysOriginal).withTintColor(TabItem.parties.color)
        partiesVC.tabBarItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)
        partiesVC.tabBarItem.tag = 0
        
        let createVC = UINavigationController(rootViewController: TabItem.create.viewController)
        createVC.setNavigationBarHidden(true, animated: false)
        createVC.tabBarItem.image = TabItem.create.icon
        createVC.tabBarItem.selectedImage = TabItem.create.selectedIcon?.withRenderingMode(.alwaysOriginal).withTintColor(TabItem.create.color)
        createVC.tabBarItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)
        createVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.clear], for: .selected)
        createVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.clear], for: .normal)
        createVC.tabBarItem.tag = 1
        
        let messagesVC = UINavigationController(rootViewController: TabItem.messages.viewController)
        messagesVC.setNavigationBarHidden(true, animated: false)
        messagesVC.tabBarItem.image = TabItem.messages.icon
        messagesVC.tabBarItem.selectedImage = TabItem.messages.selectedIcon?.withRenderingMode(.alwaysOriginal).withTintColor(TabItem.messages.color)
        messagesVC.tabBarItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)
        messagesVC.tabBarItem.tag = 2
        
        let accountVC = UINavigationController(rootViewController: TabItem.account.viewController)
        accountVC.setNavigationBarHidden(true, animated: false)
        accountVC.tabBarItem.image = TabItem.account.icon
        accountVC.tabBarItem.selectedImage = TabItem.account.selectedIcon?.withRenderingMode(.alwaysOriginal).withTintColor(TabItem.account.color)
        accountVC.tabBarItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)

        accountVC.tabBarItem.tag = 3
        
        let tabBarList = [partiesVC, createVC, messagesVC, accountVC]
        viewControllers = tabBarList
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    class TabBar: UITabBar {
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            var sizeThatFits = super.sizeThatFits(size)
            sizeThatFits.height = Constants.tabBarHeight
            return sizeThatFits
        }
        
        override var isHidden: Bool {
            get {
                return super.isHidden
            }
            set {
                super.isHidden = true
                
            }
        }
        
        func asdasd() {
            self.tabBarContainer.isHidden = true
        }
    }
    
    override var hidesBottomBarWhenPushed: Bool {
        didSet {
            print("asdijoasijodaoijsdjia")
           
        }
    }
}

extension TabBarController: FloatingTabbarDelegate {
    func selectedChanged(_ index: Int) {
        selectedIndex = index
    }
}

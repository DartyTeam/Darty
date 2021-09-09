
import UIKit
import SwiftUI

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private enum Constants {
        static let tabBarHeight: CGFloat = UIDevice.current.hasNotch ? 70 : 80
    }
    
    override var selectedIndex: Int {
        didSet {
            floatingTabBar.selected = selectedIndex
        }
    }
    
    var observableFloatingExpand:ObservableFloatingExpand = ObservableFloatingExpand()
    
    private lazy var floatingTabBar: FloatingTabbar = {
        let floatingTabBar = FloatingTabbar(selected: 0, observableFloatingExpand: observableFloatingExpand, delegate: self)
        return floatingTabBar
    }()
    
    lazy var tabBarContainer: UIView = {
        let tabBarContainerView = UIView()
        var newFrame = tabBar.frame
        newFrame.size.height = Constants.tabBarHeight + 90
        newFrame.size.width = self.view.frame.width - 24
        newFrame.origin.x = 12
        newFrame.origin.y = UIDevice.current.hasNotch ? (self.view.frame.height - Constants.tabBarHeight - 30) : (self.view.frame.height - Constants.tabBarHeight + 34)
        tabBarContainerView.frame = newFrame
        tabBarContainerView.backgroundColor = .clear
        let childView = UIHostingController(rootView: floatingTabBar)
        childView.view.backgroundColor = .clear
        childView.view.frame = tabBarContainerView.bounds
        tabBarContainerView.addSubview(childView.view)
        return tabBarContainerView
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        object_setClass(self.tabBar, TabBar.self)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: Constants.tabBarHeight - 5, right: 0)
        tabBarContainer.isHidden = true
        tabBar.isHidden = true
        setTabBarMenuControllers()
        selectedIndex = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !view.subviews.contains(tabBarContainer) {
            view.addSubview(tabBarContainer)
            DispatchQueue.main.async {
                self.tabBarContainer.isHidden = false
            }
            tabBarContainer.slideFromBottom()
        }
    }
    
    private func setTabBarMenuControllers() {
        let partiesVC = UINavigationController(rootViewController: TabItem.parties.viewController)
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
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
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
    }
    
    func setTabBarHidden(_ isHidden: Bool) {
        tabBarContainer.isHidden = isHidden
        if isHidden {
            additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: Constants.tabBarHeight - 5, right: 0)
        }
    }
    
    func expand(_ isExpand: Bool) {
        observableFloatingExpand.expand = isExpand
    }
    
    deinit {
        print("Deinit: ", TabBarController.self)
    }
}

extension UIViewController {
    func setIsTabBarHidden(_ hide: Bool) {
        guard let tabBar = tabBarController as? TabBarController else { return }
        tabBar.setTabBarHidden(hide)
    }
    
    func expandTabBar(_ isExpand: Bool) {
        guard let tabBar = tabBarController as? TabBarController else { return }
        tabBar.expand(isExpand)
    }
}

extension TabBarController: FloatingTabbarDelegate {
    func selectedChanged(_ index: Int) {
        selectedIndex = index
    }
}

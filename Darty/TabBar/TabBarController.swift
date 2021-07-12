import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private enum Constants {
        static let tabBarHeight: CGFloat = 70
    }
    
//    private let bottomSafeInset: CGFloat = UIDevice.current.hasNotch ? 34 : 0
    
    private let currentUser: UserModel
    
    private let floatingTabBar: UITabBar = {
        return UITabBar()
    }()
    
    init(currentUser: UserModel) {
        self.currentUser = currentUser
        AuthService.shared.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabBar()
        setTabBarMenuControllers()
        selectedIndex = 1
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: GlobalConstants.tabBarHeight, right: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("asduyiggaisudgiuasiuduashdas78t6a78std87tasd: ", view.safeAreaInsets.bottom)
        var newFrame = tabBar.frame
        newFrame.size.height = Constants.tabBarHeight
        newFrame.size.width = view.frame.width - 24
        newFrame.origin.x = 12
        
        print("asidjaiosdjasoid: ", UIDevice.current.hasNotch)
        if UIDevice.current.hasNotch {
//            newFrame.origin.y = view.frame.height - Constants.tabBarHeight - view.safeAreaInsets.bottom
            newFrame.origin.y = view.frame.height - Constants.tabBarHeight - 34
        } else {
            newFrame.origin.y = view.frame.height - Constants.tabBarHeight - 10
        }
        
        tabBar.frame = newFrame
        
        tabBar.itemWidth = 28.0
        tabBar.itemPositioning = .centered
        tabBar.itemSpacing = 60
        tabBar.layer.cornerRadius = 25
        tabBar.layer.masksToBounds = true
    }
    
    private func setTabBarMenuControllers() {
    
        let partiesVC = UINavigationController(rootViewController: TabItem.parties.viewController)
        partiesVC.setNavigationBarHidden(true, animated: false)
        partiesVC.tabBarItem.image = TabItem.parties.icon
        partiesVC.tabBarItem.selectedImage = TabItem.parties.selectedIcon?.withRenderingMode(.alwaysOriginal).withTintColor(TabItem.parties.color)
        partiesVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        partiesVC.tabBarItem.tag = 0
        
        let createVC = UINavigationController(rootViewController: TabItem.create.viewController)
        createVC.setNavigationBarHidden(true, animated: false)
        createVC.tabBarItem.image = TabItem.create.icon
        createVC.tabBarItem.selectedImage = TabItem.create.selectedIcon?.withRenderingMode(.alwaysOriginal).withTintColor(TabItem.create.color)
        createVC.tabBarItem.imageInsets = UIEdgeInsets(top: 12, left: 0, bottom: -12, right: 0)
        createVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.clear], for: .selected)
        createVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.clear], for: .normal)
        createVC.tabBarItem.tag = 1
        
        let messagesVC = UINavigationController(rootViewController: TabItem.messages.viewController)
        messagesVC.setNavigationBarHidden(true, animated: false)
        messagesVC.tabBarItem.image = TabItem.messages.icon
        messagesVC.tabBarItem.selectedImage = TabItem.messages.selectedIcon?.withRenderingMode(.alwaysOriginal).withTintColor(TabItem.messages.color)
        messagesVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        messagesVC.tabBarItem.tag = 2
        
        let accountVC = UINavigationController(rootViewController: TabItem.account.viewController)
        accountVC.setNavigationBarHidden(true, animated: false)
        accountVC.tabBarItem.image = TabItem.account.icon
        accountVC.tabBarItem.selectedImage = TabItem.account.selectedIcon?.withRenderingMode(.alwaysOriginal).withTintColor(TabItem.account.color)
        accountVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)

        accountVC.tabBarItem.tag = 3
        
        let tabBarList = [partiesVC, createVC, messagesVC, accountVC]
        viewControllers = tabBarList
    }
    
    private func addTabBar() {
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    func visibilityTabbar(visible: Bool) {
        tabBar.isHidden = !visible
    }
}

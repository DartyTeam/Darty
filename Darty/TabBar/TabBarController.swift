import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let currentUser: UserModel
    
    init(currentUser: UserModel) {
        
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        addTabBar()
        setTabBarMenuControllers()
        selectedIndex = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tabBar.frame.size.height = 70
        tabBar.frame.size.width = view.frame.width - 24
        tabBar.frame.origin.x = 12
        tabBar.frame.origin.y = view.frame.height - 70 - view.safeAreaInsets.bottom

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
        createVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
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
    
    private func addTabBar(){
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    func visibilityTabbar(visible: Bool) {
        tabBar.isHidden = !visible
    }
}


import UIKit
import SwiftUI

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    private var observableFloatingConfig: ObservableFloatingExpandAndSelectedIndex = ObservableFloatingExpandAndSelectedIndex()

    override var selectedIndex: Int {
        didSet {
            observableFloatingConfig.selectedIndex = selectedIndex
        }
    }

    private lazy var floatingTabBar: FloatingTabbar = {
        let floatingTabBar = FloatingTabbar(observableConfig: observableFloatingConfig, delegate: self)
        return floatingTabBar
    }()
    
    lazy var tabBarContainer: UIView = {
        let tabBarContainerView = UIView()
        tabBarContainerView.backgroundColor = .clear
        let childView = UIHostingController(rootView: floatingTabBar)
        childView.view.backgroundColor = .clear
        tabBarContainerView.addSubview(childView.view)
        let bottomOffset = (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
        tabBarContainerView.frame = CGRect(x: tabBar.frame.minX, y: tabBar.frame.minY, width: tabBar.frame.size.width, height: tabBar.frame.size.height)
        childView.view.frame = CGRect(x: 0, y: 0, width: tabBarContainerView.frame.size.width, height: tabBarContainerView.frame.size.height)
        return tabBarContainerView
    }()

    private var createCoordinator: Coordinator!
    private var accountCoordinator: Coordinator!

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
        tabBar.alpha = 0
        setTabBarMenuControllers()
        selectedIndex = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !view.subviews.contains(tabBarContainer) {
            view.addSubview(tabBarContainer)
            tabBarContainer.slideFromBottom()
        }
    }
    
    private func setTabBarMenuControllers() {
        var tabBarList = [UIViewController]()

        let partiesVC = UINavigationController(rootViewController: TabItem.parties.viewController)
        partiesVC.tabBarItem.image = TabItem.parties.icon
        partiesVC.tabBarItem.selectedImage = TabItem.parties.selectedIcon?.withRenderingMode(.alwaysOriginal).withTintColor(TabItem.parties.color)
        partiesVC.tabBarItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)
        partiesVC.tabBarItem.tag = TabItem.parties.index
        tabBarList.insert(partiesVC, at: TabItem.parties.index)

        createCoordinator = TabItem.create.coordinator
        createCoordinator.start()
        let createVC = createCoordinator.navigationController
        createVC.tabBarItem.image = TabItem.create.icon
        createVC.tabBarItem.selectedImage = TabItem.create.selectedIcon?.withRenderingMode(.alwaysOriginal).withTintColor(TabItem.create.color)
        createVC.tabBarItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)
        createVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .selected)
        createVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        createVC.tabBarItem.tag = TabItem.create.index
        tabBarList.insert(createVC, at: TabItem.create.index)
        
        let messagesVC = UINavigationController(rootViewController: TabItem.messages.viewController)
        messagesVC.tabBarItem.image = TabItem.messages.icon
        messagesVC.tabBarItem.selectedImage = TabItem.messages.selectedIcon?.withRenderingMode(.alwaysOriginal).withTintColor(TabItem.messages.color)
        messagesVC.tabBarItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)
        messagesVC.tabBarItem.tag = TabItem.messages.index
        tabBarList.insert(messagesVC, at: TabItem.messages.index)

        accountCoordinator = TabItem.account.coordinator
        accountCoordinator.start()
        let accountVC = accountCoordinator.navigationController
        accountVC.setNavigationBarHidden(true, animated: false)
        accountVC.tabBarItem.image = TabItem.account.icon
        accountVC.tabBarItem.selectedImage = TabItem.account.selectedIcon?.withRenderingMode(.alwaysOriginal).withTintColor(TabItem.account.color)
        accountVC.tabBarItem.imageInsets = UIEdgeInsets(top: 16, left: 0, bottom: -16, right: 0)
        accountVC.tabBarItem.tag = TabItem.account.index
        tabBarList.insert(accountVC, at: TabItem.account.index)

        viewControllers = tabBarList
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    func setTabBarHidden(_ isHidden: Bool) {
        tabBarContainer.isHidden = isHidden
        tabBar.isHidden = isHidden
    }
    
    func expand(_ isExpand: Bool) {
        observableFloatingConfig.expand = isExpand
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

fileprivate class TabBar: UITabBar {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
          super.sizeThatFits(size)
          var sizeThatFits = super.sizeThatFits(size)
          sizeThatFits.height = GlobalConstants.tabBarHeight
          return sizeThatFits
    }

    override var isHidden: Bool {
        didSet {
            alpha = 0 // Делаем альфа всегда 0
        }
    }
}

extension UITabBarController {
    func changeSelectedIndexFor(tabItem: TabItem) {
        self.selectedIndex = tabItem.index
    }

    func getControllerFor(tabItem: TabItem) -> UIViewController? {
        return (viewControllers?[tabItem.index] as? UINavigationController)?.viewControllers.first
    }
}

//
//  AppDelegate.swift
//  Darty
//
//  Created by Руслан Садыков on 19.06.2021.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import SnapKit
import SkeletonView

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - UI Elements
    var window: UIWindow?

    var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        // Initialize sign-in
        FirebaseApp.configure()
        //        GIDSignIn.sharedInstance.clientID = FirebaseApp.app()?.options.clientID
        
        StoreReviewHelper.incrementAppOpenedCount()

        // Firestore configure
        let settings = FirestoreSettings()
        // Set offline mode
        settings.isPersistenceEnabled = true
        // Set cache size
        settings.cacheSizeBytes = 1073741824
        let db = Firestore.firestore()
        db.settings = settings

        configureSkeleton()

        return true
    }

    private func configureSkeleton() {
        SkeletonAppearance.default.multilineLastLineFillPercent = Int.random(in: 20...70)
        SkeletonAppearance.default.multilineCornerRadius = 8
        SkeletonAppearance.default.skeletonCornerRadius = 8
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        if let shortcutItem = options.shortcutItem {
            DeeplinkManager.shared.handleShortcut(item: shortcutItem)
        }
        let configuration = UISceneConfiguration(
            name: connectingSceneSession.configuration.name,
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        // user is offline
        changeOnlineStatus(to: false)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        DeeplinkManager.shared.checkDeepLink(with: appCoordinator!)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        changeOnlineStatus(to: true)
    }

    // MARK: Shortcuts
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(DeeplinkManager.shared.handleShortcut(item: shortcutItem))
    }

    // MARK: Deeplinks
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        if DeeplinkManager.shared.handleDeeplink(url: url) {
            return true
        }
        
        // FacebookSDK
        ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation] )

        // GoogleSDK
        return GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: Universal Links
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                return DeeplinkManager.shared.handleDeeplink(url: url)
            }
        }
        return false
    }

    // MARK: - First launch after install for older iOS version
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool{
        return DeeplinkManager.shared.handleDeeplink(url: url)
    }

    // MARK: - Notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DeeplinkManager.shared.handleRemoteNotification(userInfo)
    }
}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.appCoordinator = AppCoordinator(window: window!)
            }
        }

        // either one will work
        guard let url = connectionOptions.urlContexts.first?.url ?? connectionOptions.userActivities.first?.webpageURL
        else { return }
        DeeplinkManager.shared.handleDeeplink(url: url)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        DeeplinkManager.shared.handleDeeplink(url: url)

        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                DeeplinkManager.shared.handleDeeplink(url: url)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        changeOnlineStatus(to: true)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let appCoordinator = appDelegate.appCoordinator
        else { return }
        DeeplinkManager.shared.checkDeepLink(with: appCoordinator)
    }

    func sceneWillResignActive(_ scene: UIScene) {

        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        changeOnlineStatus(to: false)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // MARK: Shortcuts
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(DeeplinkManager.shared.handleShortcut(item: shortcutItem))
    }
}

fileprivate func changeOnlineStatus(to online: Bool) {
    FirestoreService.shared.setOnline(status: true) { result in
        switch result {
        case .success():
            print("Successful set user status to online")
        case .failure(let error):
            print("ERROR_LOG Error set user status to online: ", error.localizedDescription)
        }
    }
}

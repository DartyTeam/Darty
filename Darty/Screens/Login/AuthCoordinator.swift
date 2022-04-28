//
//  AuthCoordinator.swift
//  Darty
//
//  Created by Руслан Садыков on 28.01.2022.
//

import UIKit
import FirebaseAuth
import Inject

protocol NameSetupProfileDelegate: AnyObject {
    func goNext(name: String)
}

protocol AboutSetupProfileDelegate: AnyObject {
    func goNext(description: String)
}

protocol SexSetupProfileDelegate: AnyObject {
    func goNext(with sex: Sex?)
}

protocol BirthdaySetupProfileDelegate: AnyObject {
    func goNext(with birthday: Date)
}

protocol InterestsSetupProfileDelegate: AnyObject {
    func goNext(with interestsList: [Int])
    func showSearch(with interestsList: [Int], selectionDelegate: SearchInterestsSetupProfileSelectionDelegate)
}

protocol SearchInterestsSetupProfileDelegate: AnyObject {
    func mainButtonTapepd(with interestsList: [Int])
}

protocol CityAndCountrySetupProfileDelegate: AnyObject {
    func goNext(with city: String, and country: String)
}

protocol ImageSetupProfileDelegate: AnyObject {
    func goNext(with image: UIImage)
}

protocol AuthCoordinatorDelegate: AnyObject {
    func didAuthorized(with user: UserModel)
}

final class AuthCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var user: User!
    private var userInfo = UserInfo()

    // MARK: - Delegate
    weak var delegate: AuthCoordinatorDelegate?

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let loginVC = LoginVC()
        loginVC.coordinator = self
        navigationController.setViewControllers([loginVC], animated: false)

        if !(UserDefaults.standard.isPrevLaunched ?? false) {
            let onboardVC = OnboardVC()
            onboardVC.modalPresentationStyle = .overFullScreen
            navigationController.present(onboardVC, animated: true, completion: nil)
        }

//        let welcomeVC = WelcomeVC()
//        welcomeVC.modalPresentationStyle = .popover
//        present(welcomeVC, animated: true, completion: nil)
    }

    func signIn() {
        let signInVC = SignInVC()
        navigationController.pushViewController(signInVC, animated: true)
    }

    func changeToMainFlow(with user: UserModel) {
        delegate?.didAuthorized(with: user)
    }

    func startSetupProfile(for user: User) {
        self.user = user
        let nameVC = NameSetupProfileVC()
        nameVC.delegate = self
        navigationController.pushViewController(nameVC, animated: true)
    }

    private func openAboutProfile() {
        let aboutSetupProfileVC = AboutSetupProfileVC()
        aboutSetupProfileVC.delegate = self
        navigationController.pushViewController(aboutSetupProfileVC, animated: true)
    }

    private func openSex() {
        let sexVC = SexSetupProfileVC()
        sexVC.delegate = self
        navigationController.pushViewController(sexVC, animated: true)
    }

    private func openBirthday() {
        let birthdayVC = BirthdaySetupProfileVC()
        birthdayVC.delegate = self
        navigationController.pushViewController(birthdayVC, animated: true)
    }

    private func openImage() {
        let imageVC = ImageSetupProfileVC()
        imageVC.delegate = self
        navigationController.pushViewController(imageVC, animated: true)
    }

    private func openCityAndCountry() {
        let cityAndCountryVC = Inject.ViewControllerHost(CityAndCountrySetupProfileVC())
        cityAndCountryVC.delegate = self
        navigationController.pushViewController(cityAndCountryVC, animated: true)
    }

    private func openInterests() {
        let interestsVC = InterestsSetupProfile()
        interestsVC.delegate = self
        navigationController.pushViewController(interestsVC, animated: true)
    }

    private func openSearchInterests(with interests: [Int], selectionDelegate: SearchInterestsSetupProfileSelectionDelegate) {
        let searchInterestsVC = SearchInterestsSetupProfileVC(
            selectedIntersests: interests,
            mainButtonTitleType: .done
        )
        searchInterestsVC.delegate = self
        searchInterestsVC.selectionDelegate = selectionDelegate
        navigationController.pushViewController(searchInterestsVC, animated: true)
    }

    private func saveUserInfo() {
        FirestoreService.shared.saveProfileWith(id: user.uid,
                                                phone: user.phoneNumber ?? "",
                                                username: userInfo.name,
                                                avatarImage: userInfo.image,
                                                description: userInfo.description,
                                                sex: userInfo.sex,
                                                birthday: userInfo.birthday,
                                                interestsList: userInfo.interests,
                                                city: userInfo.city,
                                                country: userInfo.country) { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.navigationController.showAlert(title: "Успешно", message: "Веселитесь!") {
                    self?.changeToMainFlow(with: user)
                }
            case .failure(let error):
                self?.navigationController.showAlert(title: "Ошибка", message: error.localizedDescription)
            }
        }
    }
}

// MARK: - NameSetupProfileDelegate
extension AuthCoordinator: NameSetupProfileDelegate {
    func goNext(name: String) {
        userInfo.name = name
        openAboutProfile()
    }
}

// MARK: - AboutSetupProfileDelegate
extension AuthCoordinator: AboutSetupProfileDelegate {
    func goNext(description: String) {
        userInfo.description = description
        openSex()
    }
}

// MARK: - SexSetupProfileDelegate
extension AuthCoordinator: SexSetupProfileDelegate {
    func goNext(with sex: Sex?) {
        userInfo.sex = sex
        openBirthday()
    }
}

// MARK: - BirthdaySetupProfileDelegate
extension AuthCoordinator: BirthdaySetupProfileDelegate {
    func goNext(with birthday: Date) {
        userInfo.birthday = birthday
        openImage()
    }
}

// MARK: - ImageSetupProfileDelegate
extension AuthCoordinator: ImageSetupProfileDelegate {
    func goNext(with image: UIImage) {
        userInfo.image = image
        openCityAndCountry()
    }
}

// MARK: - CityAndCountrySetupProfileDelegate
extension AuthCoordinator: CityAndCountrySetupProfileDelegate {
    func goNext(with city: String, and country: String) {
        userInfo.city = city
        userInfo.country = country
        openInterests()
    }
}

// MARK: - InterestsSetupProfileDelegate, SearchInterestsSetupProfileDelegate
extension AuthCoordinator: InterestsSetupProfileDelegate, SearchInterestsSetupProfileDelegate {
    func goNext(with interestsList: [Int]) {
        userInfo.interests = interestsList
        saveUserInfo()
    }

    func mainButtonTapepd(with interestsList: [Int]) {
        goNext(with: interestsList)
    }

    func showSearch(with interestsList: [Int], selectionDelegate: SearchInterestsSetupProfileSelectionDelegate) {
        openSearchInterests(with: interestsList, selectionDelegate: selectionDelegate)
    }
}

extension AuthCoordinator {
    struct UserInfo {
        var name: String = ""
        var description: String = ""
        var sex: Sex?
        var birthday: Date = Date()
        var city: String = ""
        var country: String = ""
        var image: UIImage = UIImage()
        var interests: [Int] = []
    }
}

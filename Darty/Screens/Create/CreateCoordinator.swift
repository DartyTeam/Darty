//
//  CreateCoordinator.swift
//  Darty
//
//  Created by Руслан Садыков on 28.01.2022.
//

import UIKit

protocol PartyNameAndDescriptionDelegate: AnyObject {
    func goNext(with name: String, and description: String)
}

protocol PartyTimeDelegate: AnyObject {
    func goNext(startTime: Date, endTime: Date?, date: Date)
}

protocol PartyTypeDelegate: AnyObject {
    func goNext(with type: PartyType)
}

protocol PartyPriceAndGuestsDelegate: AnyObject {
    func goNext(priceType: PriceType, moneyPrice: Int?, anotherPrice: String?, minAge: Int, maxGuests: Int)
}

protocol PartyImagesDelegate: AnyObject {
    func goNext(with images: [UIImage])
}

protocol SelectLocationDelegate: AnyObject {
    func goNext(address: String, latitude: Double, longitude: Double, city: String)
}

final class CreateCoordinator: Coordinator {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    private var partyInfo = PartyInfo(userId: AuthService.shared.currentUser.id)

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let partyNameAndDescriptionVC = PartyNameAndDescriptionVC()
        partyNameAndDescriptionVC.delegate = self
        navigationController.setViewControllers([partyNameAndDescriptionVC], animated: false)
    }

    private func openPartyTime() {
        let partyTimeVC = PartyTimeVC()
        partyTimeVC.delegate = self
        navigationController.pushViewController(partyTimeVC, animated: true)
    }

    private func openPartyType() {
        let partyTypeVC = PartyTypeVC()
        partyTypeVC.delegate = self
        navigationController.pushViewController(partyTypeVC, animated: true)
    }

    private func openPartyPriceAndGuests() {
        let partyPriceAndGuests = PartyPriceAndGuestsVC()
        partyPriceAndGuests.delegate = self
        navigationController.pushViewController(partyPriceAndGuests, animated: true)
    }

    private func openPartyImages() {
        let partyImagesVC = PartyImagesVC()
        partyImagesVC.delegate = self
        navigationController.pushViewController(partyImagesVC, animated: true)
    }

    private func openSelectLocation() {
        let selectLocationVC = SelectLocationVC()
        selectLocationVC.delegate = self
        navigationController.pushViewController(selectLocationVC, animated: true)
    }

    private func finalCreateParty() {
        let lastVC = navigationController.viewControllers.last
        lastVC?.startLoading()
        FirestoreService.shared.savePartyWith(party: partyInfo) { [weak self] (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    lastVC?.stopLoading()
                    let alertController = UIAlertController(title: "🎉 Ура! Вечеринка создана. Вы можете найти ее в Мои вечеринки", message: "", preferredStyle: .actionSheet)
                    let shareAction = UIAlertAction(title: "Поделиться ссылкой", style: .default) { _ in
                        let items: [Any] = ["This app is my favorite", URL(string: "https://www.apple.com")!]
                        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        ac.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
                        self?.navigationController.present(ac, animated: true)
                    }
                    let goAction = UIAlertAction(title: "Перейти к вечеринке", style: .default) { _ in
                        #warning("Нужно добавить открытие вечеринки и переход в Мои вечеринки")
                    }
                    let doneAction = UIAlertAction(title: "Закрыть", style: .cancel) { _ in
                        self?.navigationController.popToRootViewController(animated: true)
                    }
                    alertController.addAction(shareAction)
                    alertController.addAction(goAction)
                    alertController.addAction(doneAction)
                    self?.navigationController.present(alertController, animated: true, completion: nil)
                }
            case .failure(let error):
                lastVC?.stopLoading()
                self?.navigationController.showAlert(title: "Ошибка", message: error.localizedDescription)
            }
        }
    }
}

extension CreateCoordinator: PartyNameAndDescriptionDelegate {
    func goNext(with name: String, and description: String) {
        partyInfo.name = name
        partyInfo.description = description
        openPartyTime()
    }
}

extension CreateCoordinator: PartyTimeDelegate {
    func goNext(startTime: Date, endTime: Date?, date: Date) {
        partyInfo.startTime = startTime
        partyInfo.endTime = endTime
        partyInfo.date = date
        openPartyType()
    }
}

extension CreateCoordinator: PartyTypeDelegate {
    func goNext(with type: PartyType) {
        partyInfo.type = type
        openPartyPriceAndGuests()
    }
}

extension CreateCoordinator: PartyPriceAndGuestsDelegate {
    func goNext(priceType: PriceType, moneyPrice: Int?, anotherPrice: String?, minAge: Int, maxGuests: Int) {
        partyInfo.priceType = priceType
        partyInfo.moneyPrice = moneyPrice
        partyInfo.anotherPrice = anotherPrice
        partyInfo.minAge = minAge
        partyInfo.maxGuests = maxGuests
        openPartyImages()
    }
}

extension CreateCoordinator: PartyImagesDelegate {
    func goNext(with images: [UIImage]) {
        partyInfo.images = images
        openSelectLocation()
    }
}

extension CreateCoordinator: SelectLocationDelegate {
    func goNext(address: String, latitude: Double, longitude: Double, city: String) {
        partyInfo.address = address
        partyInfo.latitude = latitude
        partyInfo.longitude = longitude
        partyInfo.city = city
        finalCreateParty()
    }
}

extension CreateCoordinator {
    struct PartyInfo {
        var name: String = ""
        var description: String = ""
        var city: String = ""
        var address: String = ""
        var userId: String
        var maxGuests: Int = 1
        var curGuests: Int = 0
        var date: Date = Date()
        var startTime: Date = Date()
        var endTime: Date?
        var priceType: PriceType = .free
        var moneyPrice: Int? = 0
        var anotherPrice: String? = ""
        var images: [UIImage] = []
        var minAge: Int = 10
        var type: PartyType = .art
        var latitude: Double = 0.0
        var longitude: Double = 0.0
    }
}

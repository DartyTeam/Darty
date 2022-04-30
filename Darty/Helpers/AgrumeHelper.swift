//
//  AgrumeHelper.swift
//  Darty
//
//  Created by Руслан Садыков on 30.07.2021.
//

import Agrume
import SPAlert
import Photos

final class AgrumeHelper {
    static let shared = AgrumeHelper()
    private init () {}
    
    func makeHelper() -> AgrumePhotoLibraryHelper {
        let saveButtonTitle = NSLocalizedString("Сохранить фото", comment: "Save Photo")
        let cancelButtonTitle = NSLocalizedString("Отмена", comment: "Cancel")
        
        let helper = AgrumePhotoLibraryHelper(
            saveButtonTitle: saveButtonTitle,
            cancelButtonTitle: cancelButtonTitle
        ) { error in
            guard error == nil else {
                if PHPhotoLibrary.authorizationStatus() == .notDetermined || PHPhotoLibrary.authorizationStatus() == .denied {
                    SPAlert.present(
                        title: "Нет доступа к библиотеке Фото",
                        message: "Необходимо предоставить разрешение в настройках",
                        preset: .error,
                        completion: nil
                    )
                } else {
                    SPAlert.present(
                        title: "Не удалось сохранить фото в вашу библиотеку",
                        preset: .error
                    )
                }
        
                print("Could not save your photo: ", error?.localizedDescription)
                return
            }
            print("Photo has been saved to your library")
            SPAlert.present(
                title: "Фото было сохранено в вашу библиотеку",
                preset: .done
            )
        }
        return helper
    }
}

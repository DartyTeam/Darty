//
//  Agrume + Extension.swift
//  Darty
//
//  Created by Руслан Садыков on 30.04.2022.
//

import Agrume

extension Agrume {
    private enum Constants {
        static let background: Background = .blurred(.systemUltraThinMaterial)
        static let dismissal: Dismissal = .withPanAndButton(
            .standard,
            UIBarButtonItem(
                barButtonSystemItem: .close,
                target: nil,
                action: nil
            )
        )
    }
    convenience init(images: [UIImage]) {
        self.init(
            images: images,
            background: Constants.background,
            dismissal: Constants.dismissal
        )
        let helper = AgrumeHelper.shared.makeHelper()
        onLongPress = helper.makeSaveToLibraryLongPressGesture
    }

    convenience init(urls: [URL], startIndex: Int) {
        self.init(
            urls: urls,
            startIndex: startIndex,
            background: Constants.background,
            dismissal: Constants.dismissal
        )
        let helper = AgrumeHelper.shared.makeHelper()
        onLongPress = helper.makeSaveToLibraryLongPressGesture
    }
}

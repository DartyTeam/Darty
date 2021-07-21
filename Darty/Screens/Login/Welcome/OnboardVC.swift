//
//  OnboardVC.swift
//  Darty
//
//  Created by Руслан Садыков on 18.07.2021.
//

import UIKit
import SwiftUI
import ConcentricOnboarding

class OnboardVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var onboardingView = OnboardingView()
        onboardingView.delegate = self
        let childView = UIHostingController(rootView: onboardingView)
        childView.view.backgroundColor = .clear
        childView.view.frame = view.bounds
        view.addSubview(childView.view)
    }
}

extension OnboardVC: OnboardingViewDelegate {
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

protocol OnboardingViewDelegate {
    func dismiss()
}

struct OnboardingView: View {
    
    var delegate: OnboardingViewDelegate?
    
    var body: some View {
        let pages = (0...4).map { i in
            AnyView(PageView(title: MockData.title, imageName: MockData.imageNames[i], header: MockData.headers[i], content: MockData.contentStrings[i], textColor: MockData.textColors[i]))
        }
        
        var a = ConcentricOnboardingView(pages: pages, bgColors: MockData.colors)
        
        //        a.didPressNextButton = {
        //            a.goToPreviousPage(animated: true)
        //        }
        a.insteadOfCyclingToFirstPage = {
            delegate?.dismiss()
            print("do your thing")
        }
        a.animationDidEnd = {
            
        }
        a.didGoToLastPage = {
        }
        return a
    }
}

struct PageView: View {
    var title: String
    var imageName: String
    var header: String
    var content: String
    var textColor: Color
    
    let imageWidth: CGFloat = 150
    let textWidth: CGFloat = 350
    
    var body: some View {
        return
            VStack(alignment: .center, spacing: 50) {
                Text(title)
                    .font(Font.system(size: 40, weight: .bold, design: .default))
                    .foregroundColor(textColor)
                    .frame(width: textWidth)
                    .multilineTextAlignment(.center)
                Image(systemName: imageName)
                    .font(.system(size: 56.0))
                    .foregroundColor(textColor)
                VStack(alignment: .center, spacing: 5) {
                    Text(header)
                        .font(Font.system(size: 25, weight: .bold, design: .default))
                        .foregroundColor(textColor)
                        .frame(width: 300, alignment: .center)
                        .multilineTextAlignment(.center)
                    Text(content)
                        .font(Font.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(textColor)
                        .frame(width: 300, alignment: .center)
                        .multilineTextAlignment(.center)
                }
            }.padding(60)
    }
}

struct MockData {
    static let title = "Что можно делать в Darty?"
    static let headers = [
        "Создавать и искать вечеринки",
        "Общаться и заводить новых друзей",
        "Рассказать о себе всему миру",
        "Читать и оставлять отзывы",
        "Весело проводить время"
    ]
    static let contentStrings = [
        "Вписка или танцевальная вечеринка? А может, домашний хакатон? Все это уже в твоих руках",
        "Обменивайся сообщениями не выходя из приложения",
        "Заполни профиль и отправляй заявки на вечеринки. Организатор и другие гости обязательно оценят твою карточку",
        "Делись эмоциями и узнавай больше о наших тусовщиках",
        "Хватит это читать. Скорее жми кнопку ниже и начинай веселье!"
    ]
    static let imageNames = [
        "flame",
        "message",
        "person",
        "hand.thumbsup",
        "face.smiling"
    ]
    
    static let colors = [
        Color(.systemOrange),
        Color(.systemTeal),
        Color(.systemIndigo),
        Color(.systemYellow),
        Color(.systemGreen),
    ]
    
    static let textColors = [
        Color(.white),
        Color(.black),
        Color(.white),
        Color(.black),
        Color(.white),
    ]
}

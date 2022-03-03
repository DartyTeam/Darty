//
//  OnboardVC.swift
//  Darty
//
//  Created by Руслан Садыков on 18.07.2021.
//

import UIKit
import SwiftUI
import ConcentricOnboarding

final class OnboardVC: UIViewController {

    // MARK: - Lifecycle
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

// MARK: - OnboardingViewDelegate
extension OnboardVC: OnboardingViewDelegate {
    func dismiss() {
        UserDefaults.standard.isPrevLaunched = true
        dismiss(animated: true, completion: nil)
    }
}

protocol OnboardingViewDelegate: AnyObject {
    func dismiss()
}

struct OnboardingView: View {
    
    weak var delegate: OnboardingViewDelegate?
    
    var body: some View {
        ConcentricOnboardingView(pageContents: MockData.pages.map { (PageView(page: $0), $0.color) })
            .duration(1.0)
            .nextIcon("chevron.forward")
            .animationDidEnd {
                print("Animation Did End")
            }
            .insteadOfCyclingToFirstPage {
                delegate?.dismiss()
            }
    }
}

struct PageView: View {
    let page: PageData
    
    let imageWidth: CGFloat = 150
    let textWidth: CGFloat = 350
    
    var body: some View {
        return
            VStack(alignment: .center, spacing: 50) {
                Text(page.title)
                    .font(Font.system(size: 40, weight: .bold, design: .default))
                    .foregroundColor(page.textColor)
                    .frame(width: textWidth)
                    .multilineTextAlignment(.center)
                Image(systemName: page.imageName)
                    .font(.system(size: 56.0))
                    .foregroundColor(page.textColor)
                VStack(alignment: .center, spacing: 5) {
                    Text(page.header)
                        .font(Font.system(size: 25, weight: .bold, design: .default))
                        .foregroundColor(page.textColor)
                        .frame(width: 300, alignment: .center)
                        .multilineTextAlignment(.center)
                    Text(page.content)
                        .font(Font.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(page.textColor)
                        .frame(width: 300, alignment: .center)
                        .multilineTextAlignment(.center)
                }
            }.padding(60)
    }
}

struct PageData {
    let title: String
    let header: String
    let content: String
    let imageName: String
    let color: Color
    let textColor: Color
}

struct MockData {
    static let pages: [PageData] = [
            PageData(
                title: "Что можно делать в Darty?",
                header: "Создавать и искать вечеринки",
                content: "Вписка или танцевальная вечеринка? А может, домашний хакатон? Все это уже в твоих руках",
                imageName: "flame",
                color: Color(.systemOrange),
                textColor: Color(.white)),
            PageData(
                title: "Что можно делать в Darty?",
                header: "Общаться и заводить новых друзей",
                content: "Обменивайся сообщениями не выходя из приложения",
                imageName: "message",
                color: Color(.systemTeal),
                textColor: Color(.black)),
            PageData(
                title: "Что можно делать в Darty?",
                header: "Рассказать о себе всему миру",
                content: "Заполни профиль и отправляй заявки на вечеринки. Организатор и другие гости обязательно оценят твою карточку",
                imageName: "person",
                color: Color(.systemIndigo),
                textColor: Color(.white)),
            PageData(
                title: "Что можно делать в Darty?",
                header: "Читать и оставлять отзывы",
                content: "Делись эмоциями и узнавай больше о наших тусовщиках",
                imageName: "hand.thumbsup",
                color: Color(.systemYellow),
                textColor: Color(.black)),
            PageData(
                title: "Что можно делать в Darty?",
                header: "Весело проводить время",
                content: "Хватит это читать. Скорее жми кнопку ниже и начинай веселье!",
                imageName: "face.smiling",
                color: Color(.systemGreen),
                textColor: Color(.white)),
        ]
}

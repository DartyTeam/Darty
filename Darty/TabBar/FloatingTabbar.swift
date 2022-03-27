//
//  FloatingTabbar.swift
//  Darty
//
//  Created by Руслан Садыков on 13.07.2021.
//

import SwiftUI

protocol FloatingTabbarDelegate {
    func selectedChanged(_ index: Int)
}

class ObservableFloatingExpandAndSelectedIndex: ObservableObject {
    @Published public var expand: Bool = true
    @Published public var selectedIndex: Int = 0
}

struct FloatingTabbar : View {

    @ObservedObject var observableConfig: ObservableFloatingExpandAndSelectedIndex = ObservableFloatingExpandAndSelectedIndex()
    
    var delegate: FloatingTabbarDelegate?
    
    var body : some View{
        
        HStack{
            
            Spacer(minLength: 0)
            
            HStack{
                if !self.observableConfig.expand {
                    Button(action: {
                        self.observableConfig.expand.toggle()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.gray)
                            .padding()
                            .frame(width: 44, height: 44)
                    }
                } else {
                    
                    Button(action: {
                        self.observableConfig.selectedIndex = 0
                        delegate?.selectedChanged(0)
                        
                    }) {
                        Image(systemName: (self.observableConfig.selectedIndex == 0) ? "flame.fill" : "flame")
                            .foregroundColor(self.observableConfig.selectedIndex == 0 ? .orange : .gray)
                            .padding(.horizontal)
                            .frame(width: 44, height: 44)
                    }

                    Spacer(minLength: 15)
                    
                    Button(action: {
                        
                        self.observableConfig.selectedIndex = 1
                        delegate?.selectedChanged(1)

                    }) {
                        Image(systemName: (self.observableConfig.selectedIndex == 1) ? "plus" : "plus")
                            .foregroundColor(self.observableConfig.selectedIndex == 1 ? .purple : .gray)
                            .padding(.horizontal)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer(minLength: 15)
                    
                    Button(action: {
                        
                        self.observableConfig.selectedIndex = 2
                        delegate?.selectedChanged(2)
                        
                    }) {
                        Image(systemName: (self.observableConfig.selectedIndex == 2) ? "message.fill" : "message")
                            .foregroundColor(self.observableConfig.selectedIndex == 2 ? Color(UIColor.systemTeal) : .gray)
                            .padding(.horizontal)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer(minLength: 15)
                    
                    Button(action: {
                        
                        self.observableConfig.selectedIndex = 3
                        delegate?.selectedChanged(3)
                        
                    }) {
                        Image(systemName: (self.observableConfig.selectedIndex == 3) ? "person.fill" : "person")
                            .foregroundColor(self.observableConfig.selectedIndex == 3 ? Color(UIColor.systemIndigo) : .gray)
                            .padding(.horizontal)
                            .frame(width: 44, height: 44, alignment: .center)
                    }
                }
            }.padding(.vertical, 8)
            .padding(.horizontal, self.observableConfig.expand ? 35 : 8)
            .background(Blur(style: .systemUltraThinMaterial))
            .clipShape(Capsule())
            .padding(22)
            .onLongPressGesture {
                self.observableConfig.expand.toggle()
            }
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onEnded({ value in
                if value.translation.width < 0 {
                    // left
                    self.observableConfig.expand = true
                }
                if value.translation.width > 0 {
                    // right
                    self.observableConfig.expand = false
                }
                if value.translation.height < 0 {
                    // up
                }
                if value.translation.height > 0 {
                    // down
                }
            }))
            .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.6))
        }
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

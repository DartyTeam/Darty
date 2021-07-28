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

class ObservableFloatingExpand: ObservableObject {
    @Published public var expand: Bool = true
}

struct FloatingTabbar : View {
    
    @State var selected : Int

    @ObservedObject var observableFloatingExpand: ObservableFloatingExpand = ObservableFloatingExpand()
    
    var delegate: FloatingTabbarDelegate?
    
    var body : some View{
        
        HStack{
            
            Spacer(minLength: 0)
            
            HStack{
                
                if !self.observableFloatingExpand.expand {
                    
                    Button(action: {
                        
                        self.observableFloatingExpand.expand.toggle()
                        
                    }) {
                        
                        Image(systemName: "arrow.left").foregroundColor(.black).padding()
                    }
                }
                else{
                    
                    Button(action: {
                        
                        self.selected = 0
                        delegate?.selectedChanged(0)
                        
                    }) {
                        
                        Image(systemName: (self.selected == 0) ? "flame.fill" : "flame").foregroundColor(self.selected == 0 ? .orange : .gray).padding(.horizontal)
                    }
                    
                    Spacer(minLength: 15)
                    
                    Button(action: {
                        
                        self.selected = 1
                        delegate?.selectedChanged(1)
                        
                    }) {
                        
                        Image(systemName: (self.selected == 1) ? "plus" : "plus").foregroundColor(self.selected == 1 ? .purple : .gray).padding(.horizontal)
                    }
                    
                    Spacer(minLength: 15)
                    
                    Button(action: {
                        
                        self.selected = 2
                        delegate?.selectedChanged(2)
                        
                    }) {
                        Image(systemName: (self.selected == 2) ? "message.fill" : "message").foregroundColor(self.selected == 2 ? Color(UIColor.systemTeal) : .gray).padding(.horizontal)
                    }
                    
                    Spacer(minLength: 15)
                    
                    Button(action: {
                        
                        self.selected = 3
                        delegate?.selectedChanged(3)
                        
                    }) {
                        Image(systemName: (self.selected == 3) ? "person.fill" : "person").foregroundColor(self.selected == 3 ? Color(UIColor.systemIndigo) : .gray).padding(.horizontal)
                    }
                }
                
                
            }.padding(.vertical,self.observableFloatingExpand.expand ? 20 : 8)
            .padding(.horizontal,self.observableFloatingExpand.expand ? 35 : 8)
            .background(Blur(style: .systemUltraThinMaterial))
            .clipShape(Capsule())
            .padding(22)
            .onLongPressGesture {
                self.observableFloatingExpand.expand.toggle()
            }
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

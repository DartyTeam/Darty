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

struct FloatingTabbar : View {
    
    @State var selected : Int
    @State var expand = false
    var delegate: FloatingTabbarDelegate?
    
    var body : some View{
        
        HStack{
            
            Spacer(minLength: 0)
            
            HStack{
                
                if !self.expand{
                    
                    Button(action: {
                        
                        self.expand.toggle()
                        
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
                
                
            }.padding(.vertical,self.expand ? 20 : 8)
            .padding(.horizontal,self.expand ? 35 : 8)
            .background(Blur(style: .systemThinMaterial))
            .clipShape(Capsule())
            .padding(22)
            .onLongPressGesture {
                self.expand.toggle()
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

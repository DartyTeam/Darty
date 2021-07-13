//
//  TabBar.swift
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
                        
                        Image(systemName: "arrow.left").foregroundColor(self.selected == 0 ? .black : .gray).padding(.horizontal)
                    }
                    
                    Spacer(minLength: 15)
                    
                    Button(action: {
                        
                        self.selected = 1
                        delegate?.selectedChanged(1)
                        
                    }) {
                        
                        Image(systemName: "arrow.left").foregroundColor(self.selected == 1 ? .black : .gray).padding(.horizontal)
                    }
                    
                    Spacer(minLength: 15)
                    
                    Button(action: {
                        
                        self.selected = 2
                        delegate?.selectedChanged(2)
                        
                    }) {
                        Image(systemName: "arrow.left").foregroundColor(self.selected == 2 ? .black : .gray).padding(.horizontal)
                    }
                }
                
                
            }.padding(.vertical,self.expand ? 20 : 8)
            .padding(.horizontal,self.expand ? 35 : 8)
            .background(Color.white)
            .clipShape(Capsule())
            .padding(22)
            .onLongPressGesture {
                    
                    self.expand.toggle()
            }
            .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.6))
        }
        

    }
}

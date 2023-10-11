//
//  ContentView.swift
//  Furnitures
//
//  Created by David Lee on 10/10/23.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @StateObject private var viewModel = FurnitureViewModel()
    let furnitures: [Furniture] = [.chair, .desk]
    
    var body: some View {
        VStack {
            ARViewContainer(viewModel: viewModel).edgesIgnoringSafeArea(.all)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(furnitures, id: \.self) { name in
                        Image(name.rawValue)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .border(.black, width: viewModel.selectedFurniture == name ? 1.0 : 0.0)
                            .onTapGesture {
                                viewModel.selectedFurniture = name
                                print(viewModel.selectedFurniture)
                            }
                    }
                }
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    let viewModel: FurnitureViewModel
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped(_:))))
        context.coordinator.arView = arView
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
}

#Preview {
    ContentView()
}

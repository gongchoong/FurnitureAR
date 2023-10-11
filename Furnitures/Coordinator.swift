//
//  Coordinator.swift
//  Furnitures
//
//  Created by David Lee on 10/10/23.
//

import Foundation
import RealityKit
import SwiftUI
import Combine

class Coordinator {
    var arView: ARView?
    var viewModel: FurnitureViewModel
    var cancellable: AnyCancellable?
    var selected: [Furniture] = []
    var movableEntities: [Entity] = []
    
    init(viewModel: FurnitureViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func tapped(_ recognizer: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
            if !selected.contains(viewModel.selectedFurniture) {
                let anchor = AnchorEntity(raycastResult: result)
                
                cancellable = ModelEntity.loadAsync(named: viewModel.selectedFurniture.rawValue)
                    .sink(receiveCompletion: { [weak self] completion in
                        if case let .failure(failure) = completion {
                            print("Unable to load model \(failure)")
                        }
                        self?.cancellable?.cancel()
                    }, receiveValue: { [unowned self] entity in
//                        self.selected.append(self.viewModel.selectedFurniture)
//                        self.movableEntities.append(entity)
//                        entity.generateCollisionShapes(recursive: true)
//                        arView.installGestures(for: entity as! HasCollision)
//                        anchor.addChild(entity)
//                        arView.scene.addAnchor(anchor)
                        entity.setScale(SIMD3(repeating: 0.01), relativeTo: nil)
                        
                        let parentEntity = ModelEntity()
                        parentEntity.addChild(entity)
                        self.arView?.scene.addAnchor(anchor)
                        
                        anchor.addChild(parentEntity)
                        
                        let entityBounds = entity.visualBounds(relativeTo: parentEntity)
                        parentEntity.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: entityBounds.extents).offsetBy(translation: entityBounds.center)])
                        self.arView?.installGestures([.translation, .rotation], for: parentEntity)
                    })
            }
        }
    }
}

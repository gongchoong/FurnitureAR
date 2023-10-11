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
    var selectedEntities: [Furniture: AnchorEntity?] = [:]
    
    init(viewModel: FurnitureViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func tapped(_ recognizer: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        
        let location = recognizer.location(in: arView)
        let hitTestResults = arView.hitTest(location)
        
        if let firstHitEntity = hitTestResults.first?.entity {
            if let furniture = Furniture.getFurniture(from: firstHitEntity.name), let anchor = selectedEntities[furniture], let furnitureAnchor = anchor {
                removeAnchorEntity(anchor: furnitureAnchor)
                selectedEntities[furniture] = nil
            }
        } else {
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
            if let result = results.first {
                let selectedFurniture = viewModel.selectedFurniture
                guard selectedEntities[selectedFurniture] == nil else { return }
                
                let anchor = AnchorEntity(raycastResult: result)
                cancellable = ModelEntity.loadAsync(named: selectedFurniture.rawValue)
                    .sink(receiveCompletion: { [weak self] completion in
                        if case let .failure(failure) = completion {
                            print("Unable to load model \(failure)")
                        }
                        self?.cancellable?.cancel()
                    }, receiveValue: { [unowned self] entity in
                        
                        let modelEntity = getModelEntity(entity: entity)
                        
                        let entityBounds = entity.visualBounds(relativeTo: modelEntity)
                        modelEntity.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: entityBounds.extents).offsetBy(translation: entityBounds.center)])
                        self.arView?.installGestures([.translation, .rotation], for: modelEntity)
                        
                        anchor.addChild(modelEntity)
                        addAnchorEntity(anchor: anchor)
                        
                        selectedEntities[selectedFurniture] = anchor
                    })
            }
        }
    }

    private func getModelEntity(entity: Entity) -> ModelEntity {
        entity.setScale(SIMD3(repeating: 0.01), relativeTo: nil)
        
        let parentEntity = ModelEntity()
        parentEntity.name = viewModel.selectedFurniture.rawValue
        parentEntity.addChild(entity)
        
        return parentEntity
    }
    
    private func removeAnchorEntity(anchor: AnchorEntity) {
        self.arView?.scene.removeAnchor(anchor)
    }
    
    private func addAnchorEntity(anchor: AnchorEntity) {
        self.arView?.scene.addAnchor(anchor)
    }
}

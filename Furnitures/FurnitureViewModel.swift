//
//  FurnitureViewModel.swift
//  Furnitures
//
//  Created by David Lee on 10/10/23.
//

import Foundation

enum Furniture: String {
    case chair
    case desk
}

class FurnitureViewModel: ObservableObject {
    @Published var selectedFurniture: Furniture = .chair
}

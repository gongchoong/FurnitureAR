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
    case stool
    
    static func getFurniture(from: String) -> Self? {
        switch from {
        case "chair":
            return .chair
        case "desk":
            return .desk
        case "stool":
            return .stool
        default:
            return nil
        }
    }
}

class FurnitureViewModel: ObservableObject {
    @Published var selectedFurniture: Furniture = .chair
}

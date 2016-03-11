//
//  Product.swift
//  FirebasePOC
//
//  Created by Marcilio Junior on 3/7/16.
//  Copyright © 2016 HE:labs. All rights reserved.
//

import Gloss

struct Product: Glossy {
    
    var id: String!
    var name: String!
    var price: Float!
    var store: String!
    
    init() { }
    
    init?(json: JSON) {
        id    = "id" <~~ json
        name  = "name" <~~ json
        price = "price" <~~ json
        store = "store" <~~ json
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> name,
            "price" ~~> price,
            "store" ~~> store])
    }
    
}

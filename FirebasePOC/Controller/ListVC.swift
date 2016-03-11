//
//  ListVC.swift
//  FirebasePOC
//
//  Created by Marcilio Junior on 3/7/16.
//  Copyright © 2016 HE:labs. All rights reserved.
//

import UIKit
import Firebase
import Gloss
import FirebaseRxSwiftExtensions
import RxSwift
import RxCocoa
import StatefulViewController

class ListVC: UIViewController, StatefulViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Variables
    
    private var items: Observable<[Product]> = Observable.never()
    private var contentAvailable = false
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialValues()
        startObservingProducts()
        setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setupInitialViewState()
    }
    
    // MARK: - StatefulViewController
    
    func hasContent() -> Bool {
        return contentAvailable
    }
    
    // MARK: - IBAction
    
    @IBAction func addBarButtonDidTap(sender: UIBarButtonItem) {
        let product = generateRandomEntry()
        
        let ref = Firebase(url: "https://resplendent-fire-4052.firebaseio.com")
        let productsRef = ref.childByAppendingPath("products")

        productsRef.childByAutoId()
            .rx_setValue(product.toJSON())
            .subscribe()
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Helper
    
    func setupInitialValues() {
        loadingView = UIView()
        loadingView?.backgroundColor = UIColor.whiteColor()
        
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.startAnimating()
        
        loadingView?.addSubview(activity)
        
        NSLayoutConstraint(item: activity,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: activity.superview!,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0).active = true
        
        NSLayoutConstraint(item: activity,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: activity.superview!,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0).active = true
    }
    
    func generateRandomEntry() -> Product {
        let products = ["iMac", "iPhone", "iPad", "Macbook Pro", "Monitor", "TV LED 43", "Roteador", "Mouse", "Teclado"]
        let prices = [1999.90, 100.00, 20.90, 10.00, 9999.90, 569.00, 499.00, 999.90, 130.00, 99.90, 250.00]
        let stores = ["Americanas", "Magazine Luiza", "Submarino", "Shoptime", "Ponto Frio", "Casas Bahia", "Walmart"]
        
        let randomProduct = products[Int(arc4random()) % products.count]
        let randomPrice = prices[Int(arc4random()) % prices.count]
        let randomStore = stores[Int(arc4random()) % stores.count]
        
        var product = Product()
        product.name = randomProduct
        product.price = Float(randomPrice)
        product.store = randomStore
        
        return product
    }
    
    func setupTableView() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        items
            .doOnNext { self.contentAvailable = $0.count > 0 }
            .bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) { row, product, cell in
                cell.textLabel?.text = product.name
            }.addDisposableTo(disposeBag)
    }
    
    // MARK: - Firebase
    
    func startObservingProducts() {
        self.startLoading()
        let productsRef = Firebase(url: "https://resplendent-fire-4052.firebaseio.com/products")
        items = productsRef
            .rx_observe(.Value)
            .map { snapshot in
                self.endLoading()
                if let json = snapshot.value as? JSON {
                    let allItems: [Product] = json.map { tuple in
                        var json = tuple.1 as! JSON
                        json["id"] = tuple.0
                        
                        return Product(json: json)!
                    }
                    
                    return allItems.sort { return $0.name.compare($1.name, options: .CaseInsensitiveSearch) == .OrderedAscending }
                }
                
                return [Product]()
        }
    }
    
}

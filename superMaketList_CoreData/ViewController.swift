//
//  ViewController.swift
//  superMaketList_CoreData
//
//  Created by Pipe Carrasco on 01-06-21.
//

import UIKit

class ViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cellProduct")
        return table
    }()
    
    let addProductBtn: UIButton = {
       let button = UIButton()
        button.setTitle("Add product", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8.0
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private var products = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "List Supermarket"
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        addProductBtn.addTarget(self,
                              action: #selector(addProduct),
                              for: .touchUpInside)
        addSubviews()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        getAllProducts()
    }
    
    private func addSubviews(){
        view.addSubview(tableView)
        view.addSubview(addProductBtn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: view.height - 200
        )
        
        
        addProductBtn.frame = CGRect(
            x: view.right / 4.0,
            y: tableView.bottom + 30,
            width: view.width / 3.0,
            height: 50.0
        )
    }

    @objc private func addProduct()  {
        let alert = UIAlertController(title: "New Product", message: "Add new product", preferredStyle: .alert)
        
        alert.addTextField {(texField) in
            texField.placeholder = "name product"
        }
        alert.addTextField {(textField) in
            textField.placeholder = "price product"
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let fieldFirst = alert.textFields?.first, let nameProduct = fieldFirst.text, !nameProduct.isEmpty else {
                return
            }
            
            guard let fieldSecond = alert.textFields?[1], let price = fieldSecond.text, !price.isEmpty else {
                return
            }
            
            self?.createProduct(nameProduct: nameProduct, priceProduct: Int32(price) ?? 0)
        }))
        present(alert, animated: true)
    }

    // MARK: - Core Data CRUD
    
    func getAllProducts(){
        do {
            products = try context.fetch(Product.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }catch {
            // error
            print("Error to list products")
        }
    }
    
    func createProduct(nameProduct: String, priceProduct: Int32){
        let newProduct = Product(context: context)
        newProduct.idProduct = UUID()
        newProduct.nameProduct = nameProduct
        newProduct.priceProduct = priceProduct
        
        do {
            try context.save()
            getAllProducts()
        } catch  {
            // error
            print("Error to save product")
        }
    }
    
    func deleteProduct(product: Product){
        context.delete(product)
        do {
            try context.save()
            getAllProducts()
        } catch {
            // error
            print("Error to delete product")
        }
    }
    
    func updateProduct(product: Product, newName: String, newPrice: Int32){
        product.nameProduct = newName
        product.priceProduct = newPrice
        do {
            try context.save()
            getAllProducts()
        } catch {
            // error
            print("Error to update product")
        }

    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = products[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProduct", for: indexPath)
        cell.textLabel?.text = "\(String(describing: product.nameProduct)) - \(product.priceProduct)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = products[indexPath.row]
        let sheet = UIAlertController(title: "Edit Product",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            let alert = UIAlertController(title: "Edit Product",
                                          message: "edit your product",
                                          preferredStyle: .alert)
            
            alert.addTextField {(texField) in
                texField.placeholder = "name product"
            }
            alert.addTextField {(textField) in
                textField.placeholder = "price product"
            }
            alert.textFields?.first?.text = product.nameProduct
            alert.textFields?[1].text = String(describing: product.priceProduct)
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let fieldFirst = alert.textFields?.first, let newNameProduct = fieldFirst.text, !newNameProduct.isEmpty else {
                    return
                }
                
                guard let fieldSecond = alert.textFields?[1], let price = fieldSecond.text, !price.isEmpty else {
                    return
                }
                
                self?.updateProduct(product: product, newName: newNameProduct, newPrice: Int32(price) ?? 0)
            }))
            self.present(alert, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteProduct(product: product)
        }))
        
        present(sheet, animated: true)
    }
}

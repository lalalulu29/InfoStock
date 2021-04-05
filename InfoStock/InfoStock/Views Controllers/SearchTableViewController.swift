//
//  SearchTableViewController.swift
//  InfoStock
//
//  Created by Кирилл Любарских  on 28.03.2021.
//

import UIKit
import Ji
import CoreData


var infoAboutCompanyList = [SymbolLookup]()
let network = Network()


var allInfo = [Int: supportStact]()
class SearchTableViewController: UITableViewController {

    var company: Array<JiNode>.SubSequence = []
    var priceNow: Array<JiNode>.SubSequence = []
    var priceR: Array<JiNode>.SubSequence = []
    var imageData:[String: Data] = [:]
    
    private var timer: Timer?
    
    let search = UISearchController(searchResultsController: nil)
    
    
    private func GenerationSearchController() {
        navigationItem.searchController = search
        search.searchBar.delegate = self
        search.searchBar.searchTextField.placeholder = "Search stock"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GenerationSearchController()

        (self.company, self.priceNow, self.priceR) = network.parsInfoAboutStockCompany()
        for elementInCompany in company {
            let element = String(describing: elementInCompany).replacingOccurrences(of: "&amp;", with: "&")
            
            network.infoAboutCompany(companyName: element, tableView: tableView)
            
            
            
            
        }
    }
        
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return company.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        cell.activityIndicator.startAnimating()
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .lightGray
            
        } else {
            cell.backgroundColor = .gray
        }
        let element = String(describing: company[indexPath.row]).replacingOccurrences(of: "&amp;", with: "&")


        cell.companyNameLabel.text = "\(element)"
        
        if rezultation[element] != nil {
            cell.ticketNameLabel.text = "\(rezultation[element]!)"
        } else {
            cell.ticketNameLabel.text = "loading..."
        }

        cell.costLabel.text = "\(priceNow[indexPath.row]) $"
        cell.priceChangeLabel.text = "\(priceR[indexPath.row]) $"
        if String(describing: priceR[indexPath.row]).prefix(1) == "+" {
            cell.priceChangeLabel.textColor = .green
        } else {
            cell.priceChangeLabel.textColor = .red
        }

        DispatchQueue.global().async {
            
            guard let imageUrlString = rezultation[element] else {return}
            guard let url = imageList[imageUrlString] else {return}
            guard let normalUrl = URL(string: url) else {return}
            guard let dataImage = try? Data(contentsOf: normalUrl) else {return}
            self.imageData[element] = dataImage
            DispatchQueue.main.async {
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.isHidden = true
                
                cell.imageCompany.image = UIImage(data: self.imageData[element]!)
                
                
                
            }
        }
        
        
        allInfo[indexPath.row] = supportStact(ticketNameLabel: cell.ticketNameLabel.text!,
                                     companyNameLabel: element,
                                     costLabel: cell.costLabel.text!,
                                     priceChangeLabel: cell.priceChangeLabel.text!,
                                     imageData: self.imageData[element] ?? Data())
        
//        print(allInfo[indexPath.row])
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let saveInFavorite = UIContextualAction(style: .normal, title: "SAVE") { (a, b, c) in
            
            
            
            let index = indexPath.row
            let element = allInfo[index]
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            
            let featch: NSFetchRequest<Stock> = Stock.fetchRequest()
            
            
            if let result = try? context.fetch(featch) {
                for res in result {
                    if res.companyName != element?.companyNameLabel {
                        continue
                    }
                    self.present(self.makeAlertController(text: "Element was added before"), animated: true)
                    
                    return
                }
            }
            
            
            guard let entity = NSEntityDescription.entity(forEntityName: "Stock", in: context) else {return}

            let obj = Stock(entity: entity, insertInto: context)
            
            obj.companyName = element?.companyNameLabel
            obj.id = 0
            obj.ticketName = element?.ticketNameLabel
            obj.price = element?.priceChangeLabel
            obj.cost = element?.costLabel
            
            do {
                try context.save()
                self.present(self.makeAlertController(text: "Element was saved"), animated: true)
            } catch {
                print (error)
            }
        }
        saveInFavorite.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [saveInFavorite])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteInFavorite = UIContextualAction(style: .destructive, title: "DELETE") { (_, _, _) in
            
            var flag = false
            
            let index = indexPath.row
            let element = allInfo[index]
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let featch: NSFetchRequest<Stock> = Stock.fetchRequest()
            
            if let result = try? context.fetch(featch) {
                
                for object in result {
                    if object.ticketName == element?.ticketNameLabel {
                        do {
                            context.delete(object)
                            try context.save()
                            flag = true
                            self.present(self.makeAlertController(text: "Element was deleted"), animated: true)
                            return
                        } catch {
                            
                        }
                    }
                    
                }
            }
            
            if !flag {
                self.present(self.makeAlertController(text: "Element wasn't found"), animated: true)
            }
            
            
        }
        return UISwipeActionsConfiguration(actions: [deleteInFavorite])
    }
    
    
    func makeAlertController(text: String) -> UIAlertController {
        let alertController = UIAlertController(title: "Info", message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        return alertController
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

var needElements = [String]()
extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { [weak self] (_) in
            let search = searchText
            if search.count == 0 {
                needElements = []
            }
            
            for element in self!.company {
                print(search.count)
                let normalElement = String(describing: element).replacingOccurrences(of: "&amp;", with: "&")
                guard let normalSearch = searchElement(element: normalElement, text: search) else {return}
                needElements.append(normalSearch)
                
                
            }

            print(needElements)
            
            
            
        })
        }
}

func searchElement(element: String, text: String) -> String?{
    if element.prefix(text.count + 1) == text {
        return element
    } else {
        return nil
    }
    
}

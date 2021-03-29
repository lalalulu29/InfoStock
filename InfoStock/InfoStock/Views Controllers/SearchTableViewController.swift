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

var allInfo = [Int: supportStact]()
class SearchTableViewController: UITableViewController, UISearchBarDelegate {

    var company: [JiNode] = []
    var priceNow: [JiNode] = []
    var priceR: [JiNode] = []
    let network = Network()
    
    let search = UISearchController(searchResultsController: nil)
    
    
    private func GenerationSearchController() {
        navigationItem.searchController = search
        search.searchBar.delegate = self
        search.searchBar.searchTextField.placeholder = "Search stock"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GenerationSearchController()

        (self.company, self.priceNow, self.priceR) = self.network.parsInfoAboutStockCompany()
        

        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priceNow.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        cell.activityIndicator.startAnimating()
        let element = String(describing: company[indexPath.row]).replacingOccurrences(of: "&amp;", with: "&")
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .lightGray
            
        } else {
            cell.backgroundColor = .gray
        }
        
        
        cell.companyNameLabel.text = element
        network.infoAboutCompany(companyName: element, tableView: tableView) { (str) in
            DispatchQueue.main.sync {
                cell.ticketNameLabel.text = str[element]
            }
        }
        let tick = cell.ticketNameLabel.text ?? ""
        network.getInameURL(ticker: tick, tableView: tableView) { (str) in
            DispatchQueue.global().async {
                guard let url = URL(string: str[tick]!) else {return}
                guard let data = try? Data(contentsOf: url) else {return}
                DispatchQueue.main.async {
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                    cell.imageCompany.image = UIImage(data: data)
                }
                
            }
        }
        cell.costLabel.text = "\(priceNow[indexPath.row]) $"
        cell.priceChangeLabel.text = "\(priceR[indexPath.row]) $"
        if String(describing: priceR[indexPath.row]).prefix(1) == "+" {
            cell.priceChangeLabel.textColor = .green
        } else {
            cell.priceChangeLabel.textColor = .red
        }

        
        allInfo[indexPath.row] = supportStact(ticketNameLabel: tick,
                                     companyNameLabel: element,
                                     costLabel: cell.costLabel.text!,
                                     priceChangeLabel: cell.priceChangeLabel.text!)
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let saveInFavorite = UIContextualAction(style: .normal, title: "SAVE") { (_, _, _) in
            let index = indexPath.row
            let element = allInfo[index]
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            guard let entity = NSEntityDescription.entity(forEntityName: "Stock", in: context) else {return}

            let obj = Stock(entity: entity, insertInto: context)
            
            obj.companyName = element?.companyNameLabel
            obj.id = 0
            obj.ticketName = element?.ticketNameLabel
            
            do {
                try context.save()
                print("element was add")
            } catch {
                print (error)
            }
        }
        return UISwipeActionsConfiguration(actions: [saveInFavorite])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteInFavorite = UIContextualAction(style: .destructive, title: "DELETE") { (_, _, _) in
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
                            print("element was deleted")
                            return
                        } catch {}
                    }
                }
            }
            
        }
        return UISwipeActionsConfiguration(actions: [deleteInFavorite])
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


extension SearchTableViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
    }
}

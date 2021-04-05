//
//  SaveTableView.swift
//  InfoStock
//
//  Created by Кирилл Любарских  on 29.03.2021.
//

import UIKit
import CoreData
import Ji


class SaveTableView: UITableViewController, UISearchBarDelegate{
    
    let search = UISearchController(searchResultsController: nil)
    private func GenerationSearchController() {
        navigationItem.searchController = search
        search.searchBar.delegate = self
        search.searchBar.searchTextField.placeholder = "Search stock"
    }
    
    var saveCompany: Array<JiNode>.SubSequence = []
    var savePriceNow: Array<JiNode>.SubSequence = []
    var savePriceR: Array<JiNode>.SubSequence = []
    
    
    var saveInfo = [Stock]()
    func getInfoFromMemory() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        let featch: NSFetchRequest<Stock> = Stock.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        featch.sortDescriptors = [sort]
        do {
            saveInfo = try context.fetch(featch)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print (error)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        GenerationSearchController()
        
        getInfoFromMemory()
        
        (self.saveCompany, self.savePriceNow, self.savePriceR) = network.parsInfoAboutStockCompany()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getInfoFromMemory()
        
        
        
        
        
    }

    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return saveInfo.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "saveCell", for: indexPath) as! SaveCell

        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .lightGray
            
        } else {
            cell.backgroundColor = .gray
        }
        
        let element = saveInfo[indexPath.row]
        cell.companyNameLable.text = element.companyName
        cell.ticketNameLable.text = element.ticketName
        cell.costLable.text = element.cost
        cell.priceLable.text = element.price
        
        
        
        for (index, companyInSaveList) in saveCompany.enumerated() {
            let elementInCompanyList = String(describing: companyInSaveList).replacingOccurrences(of: "&amp;", with: "&")
            if elementInCompanyList == element.companyName {
                
                cell.costLable.text = "\(savePriceNow[index]) $"
                cell.priceLable.text = "\(savePriceR[index]) $"

                
            }
        }
        
        if cell.priceLable.text!.prefix(1) == "+" {
            cell.priceLable.textColor = .green
        } else {
            cell.priceLable.textColor = .red
        }
        

        return cell
    }


    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "DELETE") { (_, _, _) in
            let companyName = self.saveInfo[indexPath.row].companyName
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let featch: NSFetchRequest<Stock> = Stock.fetchRequest()
            
            if let result = try? context.fetch(featch) {
                
                for object in result {
                    if object.companyName == companyName {
                            context.delete(object)

                    }
                    
                }
                
            }
            do {
                try context.save()
                self.saveInfo.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                
            }
            
            
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
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

//
//  Network.swift
//  InfoStock
//
//  Created by Кирилл Любарских  on 28.03.2021.
//

import Foundation
import Ji

var rezultation = [String: String]()
var imageList = [String: String]()
class Network {
    let token = "c1gf6qf48v6p69n8uvr0"
    let apiURL = "https://finnhub.io/api/v1"
    
    
    //MARK: - Here I'm pars info about company
    func parsInfoAboutStockCompany() -> (Array<JiNode>.SubSequence,
                                         Array<JiNode>.SubSequence,
                                         Array<JiNode>.SubSequence) {
        
        let link = "https://ru.investing.com/equities/StocksFilter?noconstruct=1&smlID=800&sid=&tabletype=price&index_id=166"
        
        guard let url = URL(string: link) else {return ([],[],[])}
        guard let jiFile = Ji(htmlURL: url) else {return ([],[],[])}
        
        guard let jiInfo = jiFile.xPath("//td/a/text()") else {return ([],[],[])}
        print(jiInfo)
        guard let priceNow = jiFile.xPath("//td[3]/text()") else {return ([],[],[])}
        print(priceNow)
        guard let priceR = jiFile.xPath("//td[6]/text()") else {return ([],[],[])}
        print(priceR)
        
        
        return (jiInfo[0..<20], priceNow[0..<20], priceR[0..<20])
    }
    
    //MARK: - API request about company
    func infoAboutCompany(companyName: String, tableView: UITableView) {
        var json: SymbolLookup!
        let normalCompanyName = companyName.replacingOccurrences(of: " ", with: "")
        let searchURL = "\(apiURL)/search?q=\(normalCompanyName)&token=\(token)"
        
        guard let url = URL(string: searchURL) else {return}
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {return}
            
            do {
                json = try JSONDecoder().decode(SymbolLookup.self, from: data)
                
                guard let needValue = json.result.first else {return}
                rezultation[companyName] = needValue.symbol
//                print(rezultation[companyName])
                
                self.getInameURL(ticker: rezultation[companyName]!)
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
                           
            }  catch {}
            
        }.resume()


    }
    func getInameURL(ticker: String) {
        let searchURL = "\(apiURL)/stock/profile2?symbol=\(ticker)&token=\(token)"
        guard let url = URL(string: searchURL) else {return}
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {return}
            
            do {
                let json = try JSONDecoder().decode(CompanyProfile.self, from: data).logo
                imageList[ticker] = json
            }  catch {
                
            }
        }.resume()
    

    }
    

}

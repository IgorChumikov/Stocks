//
//  ViewController.swift
//  Stocks
//
//  Created by Игорь Чумиков on 30.01.2021.
//  Copyright © 2021 Tinkoff. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // UI
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    
    //Private
    private lazy var companies = [
        "Apple":"AAPL",
        "Microsoft":"MSFT",
        "Google":"GOOG",
        "Amazon":"AMZN",
        "Facebook":"FB"
    ]
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        companyNameLabel.text = "Tinkoff"
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        
        requestQuoteUpdate()
    }
    
    //MARK: - Methods
    
    private func requestQuote(for symbol: String) {
        
        let token = "pk_1f46ccc5237e431299529c6711dc2c09"
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?&token=\(token)") else {return}
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                (response as? HTTPURLResponse)?.statusCode == 200,
                error == nil {
                self.parseQuote(from: data)
            } else {
                print("Network error!")
            }
        }
        dataTask.resume()
    }
    
    private func requestQuoteLogo(for symbol: String) {
        
        let token = "pk_1f46ccc5237e431299529c6711dc2c09"
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/logo?&token=\(token)") else {return}
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                (response as? HTTPURLResponse)?.statusCode == 200,
                error == nil {
                self.parseQuoteLogo(from: data)
            } else {
                print("Network error!")
            }
        }
        dataTask.resume()
    }
    
    private func parseQuote(from data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            print(jsonObject)
            guard
                let json = jsonObject as? [String : Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double else { return print("Invalid JSON") }
            
            DispatchQueue.main.async { [weak self] in
                self?.displayStockInto(companyName: companyName,
                                       companySymbol: companySymbol,
                                       price: price,
                                       priceChange: priceChange)
            }
        } catch {
            print("JSON parsing error: " + error.localizedDescription)
        }
    }
    
    private func parseQuoteLogo(from data: Data) {
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [String : Any],
                let logoUrl = json["url"] as? String else { return print("Invalid JSON") }
            
            DispatchQueue.main.async { [weak self] in
                self?.displayLogo(url: logoUrl)
            }
        } catch {
            print("JSON parsing error: " + error.localizedDescription)
        }
    }
    
    private func displayLogo(url: String) {
        
        let url = URL(string: url)
        if let url = url, let data = try? Data(contentsOf: url) {
            logoImageView.image  = UIImage(data: data)
        }
        
    }
    
    private func displayStockInto(companyName: String,
                                  companySymbol: String,
                                  price: Double,
                                  priceChange: Double) {
        
        priceChangeLabel.textColor = priceChange == 0 ? .black : priceChange < 0 ? .red : .green
        
        activityIndicator.stopAnimating()
        companyNameLabel.text = companyName
        companySymbolLabel.text = companySymbol
        priceLabel.text = "\(price)"
        priceChangeLabel.text = "\(priceChange)"
        
    }
    
    private func requestQuoteUpdate() {
        
        activityIndicator.startAnimating()
        
        companyNameLabel.text = "-"
        companySymbolLabel.text = "-"
        priceLabel.text = "-"
        priceChangeLabel.textColor = .black
        priceChangeLabel.text = "-"
        
        let selectedRow = companyPickerView.selectedRow(inComponent: 0)
        let seletedSymbol = Array(companies.values)[selectedRow]
        requestQuote(for: seletedSymbol)
        requestQuoteLogo(for: seletedSymbol)
        
    }
}

//MARK: - Extension

extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.keys.count
    }
}

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return Array(companies.keys)[row]
    }
    
    func  pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        requestQuoteUpdate()
    }
}



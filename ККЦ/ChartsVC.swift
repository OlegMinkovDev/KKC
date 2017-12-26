//
//  ChartsVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 14/10/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit
import Charts

class Statistic {
    
    var problemId: Int?
    var problemName: String?
    var problemCount: Int?
    
    init() {
        self.problemId = 0
        self.problemName = ""
        self.problemCount = 0
    }
    
    init(id: Int, name: String, count: Int) {
        self.problemId = id
        self.problemName = name
        self.problemCount = count
    }
}

class ChartsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var barChartView: BarChartView!
    
    var tableData = [String]()
    var colors: [UIColor] = [.red, .orange, .blue, .gray, .purple, .brown, .black, .yellow, .green, .darkGray]
    
    var diagramType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pieChartView.noDataText = "Завантажуються дані ..."
        barChartView.noDataText = "Завантажуються дані ..."
        
        tableView.isScrollEnabled = false
        
        if diagramType == 0 {
            
            pieChartView.isHidden = false
            tableView.isHidden = false
            barChartView.isHidden = true
            
            getPieChart()
        
        } else if diagramType == 1 {
            
            pieChartView.isHidden = true
            tableView.isHidden = true
            barChartView.isHidden = true
            barChartView.isHidden = false
            
            getBarChart()
        
        }
    }
    
    // MARK: TableView Delegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "legendCell") as! LegendCell
        cell.legendView.backgroundColor = colors[indexPath.row]
        cell.legendTitle.text = tableData[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    // MARK: - Helpful functions
    func getPieChart() {
        
        let parameters: [String : Any] = [
            "culture" : "ua",
            "allcontacts" : true,
            "incity" : true,
            "city_id" : SettingManager.shered.getCityId()
        ]
        
        NetworkManager.shared.getStatistics(withParameters: parameters) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
           
            // parse response
            var statistics = [Statistic]()
            let chartData = response!["list"] as! [NSDictionary]
            for dict in chartData {
                
                let statistic = Statistic()
                
                let problemId = dict["problem_id"] as! Int
                let problemName = dict["problem"] as! String
                let count = dict["count"] as! Int
                
                var problemCount = statistic.problemId
                if problemCount == nil { problemCount = 0 }
                
                problemCount! += count
                
                statistic.problemId = problemId
                statistic.problemName = problemName
                statistic.problemCount = problemCount!
                
                statistics.append(statistic)
            }
            
            // sort chart data
            let sortedStatistics = statistics.sorted(by: { (stat1, stat2) -> Bool in
                return stat1.problemCount! > stat2.problemCount!
            })
            
            self.setPieChart(sortedStatistics: sortedStatistics)
        }
    }
    
    func getBarChart() {
        
        let calendar = Calendar.current
        let beginDate = calendar.date(byAdding: .month, value: -1, to: Date())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let beginDateSring = dateFormatter.string(from: beginDate!)
        let endDateString = dateFormatter.string(from: Date())
        
        let parameters: [String : Any] = [
            "datefrom" : beginDateSring,
            "dateto" : endDateString
        ]
        
        NetworkManager.shared.getStatisticsPC(withParameters: parameters) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            var citiesName = [String]()
            var counts = [Double]()
            
            let cities = response!["list"] as! [NSDictionary]
            for dict in cities {
                
                let city = dict["city"] as! String
                let count = dict["count"] as! Double
                
                citiesName.append(city)
                counts.append(count)
            }
            
            self.setBarChart(citiesName: citiesName, counts: counts)
        }
    }
    
    func setPieChart(sortedStatistics: [Statistic]) {
        
        var dataEntries: [ChartDataEntry] = []
        for i in 0 ..< 5 {
            
            tableData.append(sortedStatistics[i].problemName!)
            
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(sortedStatistics[i].problemCount!))
            dataEntries.append(dataEntry)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        pieChartDataSet.colors = colors
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        self.pieChartView.chartDescription?.text = ""
        self.pieChartView.drawHoleEnabled = false
        self.pieChartView.legend.enabled = false
        self.pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        self.pieChartView.data = pieChartData
    }
    
    func setBarChart(citiesName: [String], counts: [Double]) {
        
        var barChartDataSets: [BarChartDataSet] = []
        for i in 0 ..< citiesName.count {
            
            let dataEntry = BarChartDataEntry(x: Double(i), y: counts[i])
            let barChartDataSet = BarChartDataSet(values: [dataEntry], label: citiesName[i])
            barChartDataSet.colors = [colors[i]]
            
            barChartDataSets.append(barChartDataSet)
        }
        
        let barChartData = BarChartData(dataSets: barChartDataSets)
        
        self.barChartView.data = barChartData
        self.barChartView.chartDescription?.text = ""
        self.barChartView.barData?.setDrawValues(false)
        self.barChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

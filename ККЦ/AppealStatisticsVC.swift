//
//  AppealStatisticsVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 04/08/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class AppealStatisticsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let reusableIdentifier = "cell"
    let dataArray = ["Топ-5 проблем по количеству обращений", "Динамика поступления обращения по дням", "ТОП-10 населенных пунктов по количеству обращений"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Статистика обращений"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reusableIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - TableView Delegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier)
        cell?.textLabel?.text = dataArray[indexPath.row]
        cell?.textLabel?.lineBreakMode = .byWordWrapping
        cell?.textLabel?.numberOfLines = 2
        cell?.accessoryType = .disclosureIndicator
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDiagramVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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

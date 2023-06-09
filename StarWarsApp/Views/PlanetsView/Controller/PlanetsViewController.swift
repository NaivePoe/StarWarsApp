//
//  PlanetsViewController.swift
//  StarWarsApp
//
//  Created by Çağrı Dai on 29.03.2023.
//

import UIKit

final class PlanetsViewController: UIViewController {
    
    @IBOutlet private weak var planetsTableView: UITableView!
    
    private var planets: [PlanetResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Planets"
        
        planetsTableView.registerCell(cell: PlanetsTableViewCell.self)
        planetsTableView.delegate = self
        planetsTableView.dataSource = self
        
        Network.shared.request(endpointType: .planets, decodingTo: [PlanetResponse].self) { [weak self] result in
            switch result {
            case .success(let response):
                self?.planets.append(contentsOf: response)
                DispatchQueue.main.async {
                    self?.planetsTableView.reloadData()
                }
            case .failure(let error):
                print(CustomError(message: "Planets response error: \(error) "))
            }
        }
        
    }

}

extension PlanetsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = planetsTableView.dequeueReusableCell(withIdentifier: PlanetsTableViewCell.identifier, for: indexPath) as? PlanetsTableViewCell else { fatalError("PlanetsTableViewCell was not found") }
        cell.configure(with: planets[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = planets[indexPath.row].url else { return }
        self.navigationController?.pushViewController(PlanetsDetailViewController(url: url), animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastIndexPath = planets.count - 1
        guard lastIndexPath == indexPath.row else { return }
        guard !Network.shared.isPaginating else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.planetsTableView.tableFooterView = Network.shared.createSpinnerFooter(view: (self?.view)!)
        }
         
        Network.shared.request(endpointType: .planets, decodingTo: [PlanetResponse].self) { [weak self] result in
            DispatchQueue.main.async {
                self?.planetsTableView.tableFooterView = nil
            }
            
            switch result {
            case .success(let response):
                self?.planets.append(contentsOf: response)
                DispatchQueue.main.async {
                    self?.planetsTableView.reloadData()
                }
            case .failure(let error):
                print(CustomError(message: "Planets response error: \(error) "))
            }
        }
    }
}

//
//  AccountSettingViewController.swift
//  Wechat
//
//  Created by Max Wen on 12/31/20.
//

import UIKit

struct Section {
    let title:String
    let option:[SettingOptionType]
    
}
enum SettingOptionType {
    case staticCell(model:SettingOption)
    case staticSwitch(model:SettingSwitchOption)
}
struct SettingSwitchOption {
    let title:String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler:(()->Void)
    var isOn: Bool
}
struct SettingOption {
    let title:String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler:(()->Void)
}

class AccountSettingViewController: UIViewController {
    

    private let tableView :UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        return table
    }()

    var models = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        view.backgroundColor = .white
        title = "Settings"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        // Do any additional setup after loading the view.
    }
    

    private func configure(){
        self.models.append(Section(title:"", option: [.staticSwitch(model: SettingSwitchOption(title: "AirPlane Mode", icon: UIImage(systemName: "airplane"), iconBackgroundColor: .systemRed, handler: {
            print("print your switch")
        }, isOn: false)),

        ]))
        self.models.append(Section(title: "General", option: [.staticCell(model: SettingOption(title: "Wifi", icon: UIImage(systemName: "house"), iconBackgroundColor: .systemPink, handler: {
            print("print your cell")
        })),
        .staticCell(model: SettingOption(title: "Edit your moment", icon: UIImage(systemName: "pencil.and.outline"), iconBackgroundColor: .link, handler: {
            let vc = EditMomentViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        })),
        .staticCell(model: SettingOption(title: "icloud", icon: UIImage(systemName: "cloud"), iconBackgroundColor: .systemGreen, handler: {
            
        })),
        .staticCell(model: SettingOption(title: "icloud", icon: UIImage(systemName: "cloud"), iconBackgroundColor: .systemGreen, handler: {
            
        })),
  
        ]))
        self.models.append(Section(title: "Information", option: [.staticCell(model: SettingOption(title: "Wifi", icon: UIImage(systemName: "house"), iconBackgroundColor: .systemPink, handler: {
            print("print your cell")
        })),
        .staticCell(model: SettingOption(title: "BlueTooth", icon: UIImage(systemName: "bluetooth"), iconBackgroundColor: .link, handler: {
            
        })),
        .staticCell(model: SettingOption(title: "icloud", icon: UIImage(systemName: "cloud"), iconBackgroundColor: .systemGreen, handler: {
            
        })),
        .staticCell(model: SettingOption(title: "icloud", icon: UIImage(systemName: "cloud"), iconBackgroundColor: .systemGreen, handler: {
            
        })),
  
        ]))
    }


}

extension AccountSettingViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return models[section].title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].option.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = models[indexPath.section].option[indexPath.row]
        
        switch type.self {
        case .staticCell(let model):
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as! SettingTableViewCell
            cell.configure(with: model)
            cell.accessoryType = .disclosureIndicator
            return cell
        case .staticSwitch(let model):
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as! SettingTableViewCell
            cell.mySwitch.isHidden = false
            cell.generateCell(with: model)
            return cell
        }

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let type = models[indexPath.section].option[indexPath.row]
        switch type.self{
        case .staticCell(let model):
            model.handler()
            
        case .staticSwitch(let model):
            model.handler()
        }
        
    }
    
}

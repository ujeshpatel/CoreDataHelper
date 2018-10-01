//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Ujesh Patel on 30/06/17.
//  Copyright © 2017 Ujesh Patel. All rights reserved.


import UIKit
import CoreData


class TblCell : UITableViewCell {
    
    @IBOutlet weak var IBlbl: UILabel!
    
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!

}


class ViewController: UIViewController {

    @IBOutlet weak var IBtxtField: UITextField!
    
    @IBOutlet weak var IBtxtUserBankCode: UITextField!
    @IBOutlet weak var IBtxtBankCode: UITextField!
    @IBOutlet weak var IBtxtBankName: UITextField!

    @IBOutlet weak var IBtbl: UITableView!

    var people: [NameDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        people = NameDetails.fetchDataFromEntity(nil, sortDescs: nil)
        
    }

  
    
    @IBAction func btnAddBankAction(_ sender: Any) {
        
        let obj = BankDetails.createNewEntity(["bankname"], values: [self.IBtxtBankName.text!])
        
        obj.initWithData(name: self.IBtxtBankName.text!, id: Int(self.IBtxtBankCode.text!)!)
        
        _appDelegate.saveContext()
  
        print("bank details added")
        
// do not add if etry not adde on database
//        self.people.append(obj)
        
//        self.IBtbl.reloadData()

            self.IBtxtBankName.text = ""
            self.IBtxtBankCode.text = ""
            
    }
    
    
    
    @IBAction func btnAddAction(_ sender: Any) {
        
        let obj = NameDetails.createNewEntity(["name"], values: [self.IBtxtField.text!])
        
        obj.initWithData(name: self.IBtxtField.text!, id: Int(self.IBtxtUserBankCode.text!)!)
        
        _appDelegate.saveContext()

        // do not add if etry not adde on database
        if !self.people.contains(obj) {
            self.people.append(obj)
        }
        
        self.IBtbl.reloadData()
        
    }
    
    @objc func btnRemoveAction(_ sender : UIButton) {
        let person = people[sender.tag]

        let predicate = NSPredicate(format: "%K = %@", "name", person.value(forKey: "name") as! CVarArg)
        
         let resultData = NameDetails.fetchDataFromEntity(predicate, sortDescs: nil)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        for object in resultData {
            context.delete(object)
            people.remove(at: sender.tag)
        }
        
        do {
            try context.save()
            print("Deleted!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        self.IBtbl.reloadData()
    }
    
    @objc func btnUpdateAction(_ sender : UIButton) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.IBtbl.dequeueReusableCell(withIdentifier: "TblCell", for: indexPath) as! TblCell
        
        cell.btnRemove.tag = indexPath.row
        
        cell.btnRemove.addTarget(self, action: #selector(self.btnRemoveAction(_:)), for: .touchUpInside)

        cell.btnUpdate.tag = indexPath.row
        
        cell.btnUpdate.addTarget(self, action: #selector(self.btnUpdateAction(_:)), for: .touchUpInside)
        let person = people[indexPath.row]
        
        cell.IBlbl?.text =
            person.name + "\n" + person.bank.bankname
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
}


class NameDetails: NSManagedObject,ParentManagedObject {
    
    @NSManaged var  bankcode : Int
    @NSManaged var  name : String
    @NSManaged var bank : BankDetails
    @NSManaged var myname : [NameDetails]? // fateched property
    
    func initWithData(name : String , id : Int) {
        self.bankcode = id
        self.name = name
        bank = BankDetails.createNewEntity("id", value: "\(id)")
        if bank.bankname.characters.count == 0 {
            bank.initWithData(name: "unnamed bank", id: id)
        }
        
    }
}

class BankDetails: NSManagedObject,ParentManagedObject {
    
    @NSManaged var bankname : String
    @NSManaged var id : Int
    @NSManaged var user : BankDetails
    
    func initWithData(name : String , id : Int) {
        self.id = id
        self.bankname = name
    }

}

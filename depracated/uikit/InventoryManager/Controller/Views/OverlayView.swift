//
//  OverlayView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 25.03.2021..
//

import UIKit

class OverlayView: UIViewController {
    
    @IBOutlet weak var slideIdicator: UIView!
    @IBOutlet weak var modelText: UILabel!
    @IBOutlet weak var serial_text: UILabel!
    @IBOutlet weak var inventoryText: UILabel!
    @IBOutlet weak var dateOfPurchase: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var dateOfPurchaseLabel: UILabel!
    
    let navigationC  = UINavigationController()
    let sheetBrain = SheetBrain()
    let utils = Utils()
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    var results : String?
    var dataSent : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        print("Results are \(results)")
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        slideIdicator.roundCorners(.allCorners, radius: 10)
        uploadButton.roundCorners(.allCorners, radius: 12)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handleInfo()
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                print("Triggered")
                dataSent = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadPressed"), object: self)
                let database = DataBaseBrain()
                    var savedData = [ScannedData]()
                    let dataToSave = ScannedData(context: database.context)
                    dataToSave.scannedData = results
                    print("Failed data that is going to db: \(String(describing:dataToSave.scannedData))")
                    dataToSave.scanDate = self.utils.getCurrentDate()
                    savedData.append(dataToSave)
                    database.savePassedData()
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    @IBAction func uploadPressed(_ sender: UIButton) {
        dataSent = true
       NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadPressed"), object: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleInfo() {
        let noinfo = "Not defined"
        let splitResults = results?.components(separatedBy: ("\n"))
        
        modelText.text = splitResults![optional: 0] ?? noinfo
        serial_text.text = splitResults![optional: 1] ?? noinfo
        inventoryText.text = splitResults![optional: 2] ?? noinfo
        let dateResult = splitResults![optional: 3]?.replacingOccurrences(of: ";", with: "") ?? noinfo
        dateOfPurchase.text = dateResult
    }
}

extension OverlayView {
    func setupConstraints() {
        let marings = view.layoutMarginsGuide
        dateOfPurchase.leadingAnchor.constraint(equalTo: marings.leadingAnchor, constant: 20).isActive = (20 != 0)
        dateOfPurchase.trailingAnchor.constraint(equalTo: marings.trailingAnchor, constant: 20).isActive = (20 != 0)
        
//        uploadButton.leadingAnchor.constraint(equalTo: marings.leadingAnchor, constant: 30).isActive = (20 != 0)
//        uploadButton.trailingAnchor.constraint(equalTo: marings.trailingAnchor, constant: 30).isActive = (20 != 0)
       // uploadButton.frame.size = CGSize(width: 374, height: 50)
        //uploadButton.frame.width = 350
        

    }
}

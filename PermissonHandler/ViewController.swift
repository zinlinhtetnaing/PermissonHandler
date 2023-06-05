//
//  ViewController.swift
//  PermissonHandler
//
//  Created by Zin Lin Htet Naing on 04/06/2023.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var choosePhotoBtn: UIButton!
    @IBOutlet weak var getLocationBtn: UIButton!
    @IBOutlet weak var openCameraBtn: UIButton!
    @IBOutlet weak var getContactBtn: UIButton!
    
    //MARK: Initilizer
    let permissionHandler = PermissionHandler.shared
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSettingBarBtn()
    }
    
    //MARK: - IBAction
    @IBAction func choosePhotoBtnAction(_ sender: UIButton) {
        permissionHandler.requestPermission(for: .photoLibrary) { [weak self] image in
            guard let self = self else { return }
            debugPrint("Get it Image: \(image)")
        }
    }
    
    @IBAction func getLocationBtnAction(_ sender: UIButton) {
        permissionHandler.requestPermission(for: .location) { [weak self] location in
            guard let self = self else { return }
            debugPrint("Get it Location: \(location)")
        }
    }
    
    @IBAction func openCameraBtnAction(_ sender: UIButton) {
        permissionHandler.requestPermission(for: .camera) { [weak self] image in
            guard let self = self else { return }
            debugPrint("Get it Taken Image: \(image)")
        }
    }
    
    @IBAction func getContactBtnAction(_ sender: UIButton) {
        permissionHandler.requestPermission(for: .contact) { [weak self] contact in
            guard let self = self else { return }
            debugPrint("Get it Contact: \(contact)")
        }
    }
    
    //MARK: - Helper Method
    private func addSettingBarBtn() {
        // Add a settings button to the right bar button item
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    @objc func settingsButtonTapped() {
        openAppSettings()
    }
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func navigateToResultView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Instantiate the new view controller using its identifier
        let newViewController = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
        // Push the new view controller onto the navigation stack
        navigationController?.pushViewController(newViewController, animated: true)
    }
    
}


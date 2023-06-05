//
//  PermissionManager.swift
//  PermissonHandler
//
//  Created by Zin Lin Htet Naing on 04/06/2023.
//

import CoreLocation
import ContactsUI
import Contacts
import UIKit
import AVFoundation
import Photos

enum PermissionType {
    case location
    case contact
    case camera
    case photoLibrary
}

class PermissionHandler: NSObject {
    
    static let shared = PermissionHandler()
    
    private let locationManager = CLLocationManager()
    private let contactPicker = CNContactPickerViewController()
    private let imagePicker = UIImagePickerController()
    
    private var permissionCallback: ((Any?) -> ())?
    
    private override init() {
        super.init()
    }
    
    func requestPermission(for permission: PermissionType, callback: @escaping (Any?) -> ()) {
        permissionCallback = callback
        switch permission {
        case .location:
            requestLocationPermission()
        case .contact:
            requestContactPermission()
        case .camera:
            requestCameraPermission()
        case .photoLibrary:
            requestPhotoLibraryPermission()
        }
    }
    
    private func requestLocationPermission() {
        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else {
                self.showSettingsAlert(for: .location)
                return
            }
        }
        let authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showSettingsAlert(for: .location)
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationUpdates()
        @unknown default: break
        }
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    private func requestContactPermission() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined:
            let contactStore = CNContactStore()
            contactStore.requestAccess(for: .contacts) { [weak self] granted, _ in
                DispatchQueue.main.async {
                    if granted {
                        self?.showContactPicker()
                    } else {
                        self?.showSettingsAlert(for: .contact)
                    }
                }
            }
        case .restricted, .denied:
            showSettingsAlert(for: .contact)
        case .authorized:
            showContactPicker()
        @unknown default: break
        }
    }
    
    private func showContactPicker() {
        contactPicker.delegate = self
        if let topViewController = UIApplication.topViewController() {
            // Use the topmost view controller
            print("Topmost view controller: \(topViewController)")
            topViewController.present(contactPicker, animated: true)
        }
    }
    
    private func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.showCameraPicker()
                    } else {
                        self?.showSettingsAlert(for: .camera)
                    }
                }
            }
        case .restricted, .denied:
            showSettingsAlert(for: .camera)
        case .authorized:
            showCameraPicker()
        @unknown default: break
        }
    }
    
    private func showCameraPicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            if let topViewController = UIApplication.topViewController() {
                // Use the topmost view controller
                print("Topmost view controller: \(topViewController)")
                topViewController.showToast(message: "Cannot access camera on this device!", seconds: 1.5)
            }
            return
        }
        self.callImagePicker(type: .camera)
    }
    
    private func requestPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            showPhotoLibrary()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                guard status == .notDetermined else { return }
                self?.showPhotoLibrary()
            }
        case .restricted, .denied:
            self.showSettingsAlert(for: .photoLibrary)
        case .limited: break
        @unknown default: break
        }
    }
    
    private func showPhotoLibrary(){
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return  }
        self.callImagePicker(type: .photoLibrary)
    }
    
    private func callImagePicker(type: UIImagePickerController.SourceType) {
        imagePicker.delegate = self
        imagePicker.sourceType = type
        imagePicker.allowsEditing = false
        if let topViewController = UIApplication.topViewController() {
            // Use the topmost view controller
            print("Topmost view controller: \(topViewController)")
            topViewController.present(imagePicker, animated: true)
        }
    }
    
}

// MARK: - Setting Alert
extension PermissionHandler {
    
    private func showSettingsAlert(for permission: PermissionType) {
        var settingsTitle: String
        var settingsMessage: String
        
        switch permission {
        case .location:
            settingsTitle = "Location Permission Required"
            settingsMessage = "Please enable location permission in Settings to use this feature."
        case .contact:
            settingsTitle = "Contact Permission Required"
            settingsMessage = "Please enable contact permission in Settings to use this feature."
        case .camera:
            settingsTitle = "Camera Permission Required"
            settingsMessage = "Please enable camera permission in Settings to use this feature."
        case .photoLibrary:
            settingsTitle = "Photo library Permission Required"
            settingsMessage = "Please enable Photo library permission in Settings to use this feature."
        }
        
        let alertController = UIAlertController(title: settingsTitle, message: settingsMessage, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        if let topViewController = UIApplication.topViewController() {
            // Use the topmost view controller
            print("Topmost view controller: \(topViewController)")
            topViewController.present(alertController, animated: true)
        }
    }
    
}

extension PermissionHandler: UINavigationControllerDelegate {
    
}

// MARK: - CLLocationManagerDelegate
extension PermissionHandler: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            startLocationUpdates()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            permissionCallback?(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("Location Manager Did Fail With Error: ----->", error)
    }
    
}

// MARK: - CNContactPickerDelegate
extension PermissionHandler: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // Retrieve contact data
        let givenName = contact.givenName
        let familyName = contact.familyName
        
        // Retrieve contact photo
        if let imageData = contact.thumbnailImageData {
            let image = UIImage(data: imageData)
            // Use the contact photo image as needed
            // e.g., display the image in an image view
            // imageView.image = image
        } else {
            // No photo available for the contact
            // Handle the case accordingly
        }
        // Use other contact data as needed
        debugPrint("Selected contact: \(givenName) \(familyName)")
        
        permissionCallback?(contact)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        /*
        if contactProperty.key == "phoneNumbers" {
            let value = contactProperty.value as! CNPhoneNumber
            let str = value.stringValue
            let phonenumber = str
            permissionCallback?(phonenumber)
        }
        
        if contactProperty.key == "givenName" {
            let value = contactProperty.contact.givenName
            let str = value
        }
         */
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension PermissionHandler: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: {
            if let image = info[.originalImage] as? UIImage {
                self.permissionCallback?(image)
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: UIApplication
extension UIApplication {
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.mainKeyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return topViewController(navigationController.visibleViewController)
        }
        if let tabBarController = viewController as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return topViewController(selectedViewController)
            }
        }
        if let presentedViewController = viewController?.presentedViewController {
            return topViewController(presentedViewController)
        }
        return viewController
    }
    
    var mainKeyWindow: UIWindow? {
        get {
            if #available(iOS 13, *) {
                return connectedScenes
                    .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                    .first { $0.isKeyWindow }
            } else {
                return keyWindow
            }
        }
    }
    
}

extension UIViewController {
    
    func showToast(message: String, seconds: Double, _ bgColor: UIColor = .black){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        if let bgView = alert.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = bgColor.withAlphaComponent(0.8)
        }
        alert.view.alpha = 0.5
        alert.setValue(NSAttributedString(string: message, attributes:[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.white]), forKey: "attributedMessage")
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .transitionCrossDissolve, animations: {
                alert.view.alpha = 0
            }, completion: {(isCompleted) in
                alert.dismiss(animated: true)
            })
        }
    }
    
}

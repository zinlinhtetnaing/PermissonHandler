//
//  Usage.swift
//  PermissonHandler
//
//  Created by Zin Lin Htet Naing on 05/06/2023.
//

import Foundation
/*
To use the refactored `PermissionHandler` class in your view controller (VC), you need to follow these steps:

1. Make sure you have imported the necessary frameworks and classes at the top of your VC file:
   ```swift
   import CoreLocation
   import Contacts
   import Photos
   ```
2. Declare a property for the `PermissionHandler` instance in your VC:
   ```swift
   var permissionHandler: PermissionHandler?
   ```
3. Instantiate the `PermissionHandler` class and set the delegate (usually in the `viewDidLoad` method or when needed):
   ```swift
   permissionHandler = PermissionHandler(delegate: self)
   ```
4. Implement the `PermissionHandlerDelegate` protocol in your VC by conforming to it:
   ```swift
   extension YourViewController: PermissionHandlerDelegate {
       func permissionHandler(_ handler: PermissionHandler, didReceivePermissionResult result: Any?, forPermission permission: PermissionType) {
           // Handle the permission result here
       }
   }
   ```
   This delegate method will be called when the permission result is received.
5. To request a specific permission, call the respective method on the `permissionHandler` instance:
   ```swift
   permissionHandler?.requestCameraPermission()
   permissionHandler?.requestPhotoLibraryPermission()
   permissionHandler?.requestLocationPermission()
   permissionHandler?.requestContactPermission()
   ```
   You can call these methods based on your requirements or when needed in your VC.
6. In the delegate method `permissionHandler(_:didReceivePermissionResult:forPermission:)`, you can handle the permission result based on the permission type.
   ```swift
   func permissionHandler(_ handler: PermissionHandler, didReceivePermissionResult result: Any?, forPermission permission: PermissionType) {
       switch permission {
       case .camera:
           if let image = result as? UIImage {
               // Handle camera permission result
           }
       case .photoLibrary:
           if let image = result as? UIImage {
               // Handle photo library permission result
           }
       case .location:
           if let location = result as? CLLocation {
               // Handle location permission result
           }
       case .contact:
           if let contact = result as? CNContact {
               // Handle contact permission result
           }
       }
   }
   ```
   Based on the permission type, you can cast the result to the appropriate type and handle it accordingly.

Remember to replace `YourViewController` with the actual name of your view controller class.

With these steps, you can integrate the `PermissionHandler` class into your view controller and handle the permission results as needed.
*/

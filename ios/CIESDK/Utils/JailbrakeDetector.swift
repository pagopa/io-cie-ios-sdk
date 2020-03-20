//
//  JailbrakeDetecto.swift
//  cieID
//
//  Created by Eros Brienza on 03/03/2020.
//  Copyright © 2020 IPZS. All rights reserved.
//

import Foundation
import UIKit

public class JailbrakeDetector{
    
    static func isJailbroken() -> (Bool, String){
        
        var isJailbroken: Bool = false
        var errorCode: String = ""
        
        if (TARGET_IPHONE_SIMULATOR != 1) {
            
            if (FileManager.default.fileExists(atPath: "/Applications/Cydia.app")){
                
                isJailbroken = true
                errorCode.append("1")
                
            }else{
                
                errorCode.append("0")

            }
            
            if (FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")){
                
                isJailbroken = true
                errorCode.append("1")
                    
            }else{
                    
                errorCode.append("0")

            }
            
            if (FileManager.default.fileExists(atPath: "/bin/bash")){
                
                isJailbroken = true
                errorCode.append("1")
                    
                }else{
                    
                    errorCode.append("0")

                }
            
            if (FileManager.default.fileExists(atPath: "/usr/sbin/sshd")){
                
                isJailbroken = true
                errorCode.append("1")
                    
            }else{
                    
                errorCode.append("0")

            }
            
            if (FileManager.default.fileExists(atPath: "/etc/apt")){
                
                isJailbroken = true
                errorCode.append("1")
                    
            }else{
                    
                errorCode.append("0")

            }
            
            if (FileManager.default.fileExists(atPath: "//private/var/lib/apt/")){
                
                isJailbroken = true
                errorCode.append("1")
                    
            }else{
                    
                errorCode.append("0")

            }
            
            if (UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!)){
                
                isJailbroken = true
                errorCode.append("1")
                    
            }else{
                    
                errorCode.append("0")

            }
            
        }

        // Check 2 : Reading and writing in system directories (sandbox violation)
        let stringToWrite = "Jailbreak Test"
        do {
            try stringToWrite.write(toFile:"/private/JailbreakTest.txt", atomically:true, encoding:String.Encoding.utf8)//Device is jailbroken
            isJailbroken = true
            errorCode.append("1")
        } catch {
            //Device is not jailbroken
            errorCode.append("0")
        }
        
        return (isJailbroken, "\(errorCode)")
        
    }
                
}

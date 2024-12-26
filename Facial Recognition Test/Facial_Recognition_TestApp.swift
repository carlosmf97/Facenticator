//
//  Facial_Recognition_TestApp.swift
//  Facial Recognition Test
//
//  Created by Carlos Muñoz Fernández on 26/12/24.
//

import SwiftUI
import Metal

@main
struct Facial_Recognition_TestApp: App {
    init() {
        // Configurar el logger para ignorar los warnings de Metal
        if let metalBundle = Bundle(path: "/System/Library/PrivateFrameworks/MetalTools.framework") {
            metalBundle.load()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

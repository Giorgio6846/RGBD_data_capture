//
//  Communication.swift
//  TrueDepthStreamer
//
//  Created by Giorgio Mancusi on 10/6/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation



func sendDataToServer(depthData: UIImage, imageData: UIImage, ip: String) {
    
    var ipAddress: String = "10.0.1.10:5050"
    
    if ip != "" {
        ipAddress = ip
    }
    
    guard let url = URL(string: "http://\(ipAddress)/face-depth-data") else {
        print("URL invalida")
        return
    }
        
    let session = URLSession.shared
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let boundary = "Boundary-\(UUID().uuidString)"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    guard let dImage = depthData.jpegData(compressionQuality: 1) else {
        print("Error al convertir de UIImage a JPEG")
        return
    }

    guard let iImage = imageData.jpegData(compressionQuality: 1) else {
        print("Error al convertir de UIImage a JPEG")
        return
    }
    
    var body = Data()
    
    
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"depthImage\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    body.append(dImage)
    body.append("\r\n".data(using: .utf8)!)

    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"faceImage\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    body.append(iImage)
    body.append("\r\n".data(using: .utf8)!)

    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = body
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error al enviar los datos: \(error.localizedDescription)")
            return
        }

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            print("Datos enviados con exito")
        } else {
            print("Error al enviar los datos. Respuesta: \(String(describing: response))")
        }
        
    }
    
    task.resume()
    
}

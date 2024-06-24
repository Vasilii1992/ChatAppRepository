//
//  StorageManager.swift
//  ChatApp
//
//  Created by Василий Тихонов on 17.06.2024.
//

import FirebaseStorage

class StorageManager {
    
    static let shaed = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureComplition = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data,fileName: String,
                                     complition: @escaping UploadPictureComplition) {
        
        storage.child("images/\(fileName)").putData(data) { [weak self] metadata, error in
            guard let self = self else { return }
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                complition(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                  print("Failed to get download url")
                    complition(.failure(StorageErrors.failedToDownloadUrl))
                    
                return
                }
                let urlString = url.absoluteString
                
                print("download url returned: \(urlString)")
                complition(.success(urlString))
                
            }
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToDownloadUrl
    }
    // upload image that will be sent in a conversation message
    public func uploadMessagePhoto(with data: Data,fileName: String,
                                     complition: @escaping UploadPictureComplition) {
        
        storage.child("message_images/\(fileName)").putData(data) { [weak self] metadata, error in
            guard let self = self else { return }
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                complition(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("message_images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                  print("Failed to get download url")
                    complition(.failure(StorageErrors.failedToDownloadUrl))
                    
                return
                }
                let urlString = url.absoluteString
                
                print("download url returned: \(urlString)")
                complition(.success(urlString))
                
            }
        }
    }
    
    // upload video that will be sent in a conversation message
    public func uploadMessageVideo(with fileUrl: URL, fileName: String,
                                     complition: @escaping UploadPictureComplition) {
        
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl) { [weak self] metadata, error in
            guard let self = self else { return }
            guard error == nil else {
                print("failed to upload video file to firebase for picture")
                complition(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("message_videos/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                  print("Failed to get download url")
                    complition(.failure(StorageErrors.failedToDownloadUrl))
                    
                return
                }
                let urlString = url.absoluteString
                
                print("download url returned: \(urlString)")
                complition(.success(urlString))
                
            }
        }
    }
    
    
    
    public func downloadUrl(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        
        let reference = storage.child(path)
        
        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToDownloadUrl))
                return
            }
            completion(.success(url))
        }

    }
}

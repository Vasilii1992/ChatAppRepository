//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Василий Тихонов on 03.07.2024.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}

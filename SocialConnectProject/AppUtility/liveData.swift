//
//  liveData.swift
//  SocialConnectProject
//
//  Created by user259543 on 11/1/24.
//


import Foundation
import Combine

class DataModel: ObservableObject {
    @Published var text: String = "Initial Value"
}

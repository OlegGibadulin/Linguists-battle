//
//  Constants.swift
//  lb
//
//  Created by Mac-HOME on 16.12.2019.
//  Copyright © 2019 Mac-HOME. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Storyboard {
        
        static let homeTableViewController = "HomeController"
        static let gameViewController = "GameController"
    }
    
    struct GameSettings {
        
        static let gameCount = 1
        static let questionsCount = 5
        static let wrongAnswersCount = 3
    }
    
    struct YandexDictionary {
        
        static let method = "https://dictionary.yandex.net/api/v1/dicservice.json/lookup"
        
        static let key = "dict.1.1.20200105T200956Z.436ce02f26ecc411.39389ffe12afa6c0e1c03f5cb93f2e486873b33f"
        
        static let mode = "en-ru"
        
        static let request = method + "?key=" + key + "&lang=" + mode + "&text="
    }
}

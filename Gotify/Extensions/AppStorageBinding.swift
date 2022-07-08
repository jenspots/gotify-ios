//
// Created by Jens Pots on 08/07/2022.
//

import Foundation
import SwiftUI

extension Binding where Value == String {

    init(forKey: String) {
        self.init(get: {
            (UserDefaults.standard.string(forKey: forKey) ?? "")
        }, set: { x in
            UserDefaults.standard.set(x, forKey: forKey)
        })
    }
}

//
//  KeyValueText.swift
//  Gotify
//
//  Created by Jens Pots on 02/07/2022.
//

import SwiftUI

struct KeyValueText: View {
    @State var left: String
    @State var right: String
    
    var body: some View {
        HStack {
            Text(left)
                .lineLimit(1)
            Spacer()
            Text(right)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
}



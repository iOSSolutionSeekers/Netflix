//
//  Extensions.swift
//  Netflix
//
//  Created by Sudharshan on 04/12/22.
//

import Foundation

extension String {
    func capitalizefirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}

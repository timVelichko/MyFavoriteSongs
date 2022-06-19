//
//  View+Utils.swift
//  MyFavoriteSongs
//
//  Created by Tim Velichko on 19.06.2022.
//

import Foundation
import SwiftUI

// https://www.avanderlee.com/swiftui/error-alert-presenting/
extension View {
    func errorAlert(error: Binding<Error?>, buttonTitle: String = "OK") -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
    }
}

struct LocalizedAlertError: LocalizedError {
    let underlyingError: LocalizedError
    var errorDescription: String? {
        underlyingError.errorDescription
    }
    var recoverySuggestion: String? {
        underlyingError.recoverySuggestion
    }

    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else { return nil }
        underlyingError = localizedError
    }
}

extension URLError: LocalizedError {
    public var errorDescription: String? {
        if let localizedDescription = userInfo["NSLocalizedDescription"] as? String {
            return localizedDescription
        } else {
            return localizedDescription
        }
    }
}

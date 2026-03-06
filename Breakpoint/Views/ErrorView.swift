//
//  ErrorView.swift
//  Breakpoint
//
//  Created by Luís Cruz on 06/03/26.
//

import SwiftUI

struct ErrorView: View {
	let message: String
	
    var body: some View {
		VStack(spacing: 10) {
			Image(systemName: Constants.Image.exclamationTriangle)
			Text(message)
		}
    }
	
	private enum Constants {
		enum Image {
			static let exclamationTriangle = "exclamationmark.triangle.fill"
		}
	}
}

#Preview {
    ErrorView(message: "Error")
}

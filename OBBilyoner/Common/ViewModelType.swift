//
//  ViewModelType.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//

protocol ViewModelType {
	associatedtype Input
	associatedtype Output

	var input: Input { get }
	var output: Output { get }
}

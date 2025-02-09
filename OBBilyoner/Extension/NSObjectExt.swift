//
//  NSObjectExt.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

import UIKit

protocol ClassNameProtocol {
	static var className: String { get }
	var className: String { get }
}

extension ClassNameProtocol {
	public static var className: String {
		return String(describing: self)
	}

	public var className: String {
		return type(of: self).className
	}
}

extension NSObject: ClassNameProtocol {}

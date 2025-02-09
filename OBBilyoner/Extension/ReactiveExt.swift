//
//  ReactiveExt.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UIViewController {
	var viewWillAppear: ControlEvent<Void> {
		let source = self.methodInvoked(#selector(Base.viewWillAppear(_:))).map { _ in }
		return ControlEvent(events: source)
	}
}

extension Reactive where Base: OddTableViewCell {
	var tap: Observable<Int> {
		return base.oddSelected
	}
}

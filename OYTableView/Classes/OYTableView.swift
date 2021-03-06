//
//  OYTableView.swift
//  OYTableView
//
//  Created by Osman YILDIRIM on 5.06.2019.
//

import UIKit

@IBDesignable public class OYTableView: UIView {
    @IBInspectable var autoScroll: Bool = true
    @IBInspectable var bgColor: UIColor? = .clear
    @IBInspectable var collapseOtherCell: Bool = true

    public var delegate: OYTableViewDelegate? {
        didSet { tableView.delegate = self }
    }
    public var dataSource: OYTableViewDataSource? {
        didSet { tableView.dataSource = self }
    }

    fileprivate var sView: OYHeaderView?
    fileprivate var index: Int?
    fileprivate var tableView: UITableView!
    fileprivate var expandedCells: [Int] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        tableView = {
            let view = UITableView(frame: UIScreen.main.bounds, style: .grouped)
            view.separatorStyle = .none
            view.backgroundColor = bgColor
            return view
        }()

        self.addSubview(tableView)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        tableView = {
            let view = UITableView(frame: UIScreen.main.bounds, style: .grouped)
            view.separatorStyle = .none
            view.backgroundColor = bgColor
            return view
        }()

        self.addSubview(tableView)
        tableView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func register(_ nib: UINib?, reuseIdentifier: String) {
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }

    public func select(header: OYHeaderView, section: Int, expanded: Bool) {
        sView = header
        if collapseOtherCell {
            if index == section {
                index = -1
                sView?.setExpanded(false)
                expandedCells(expanded: false, section)
                delegate?.oyTableView(tableView, section: section, didCollapse: header)
            } else {
                sView?.setExpanded(false)
                expandedCells(expanded: false, section)

                sView = header
                delegate?.oyTableView(tableView, section: index, didCollapse: header)
                index = section
                sView?.setExpanded(true)
                expandedCells(expanded: true, section)
                delegate?.oyTableView(tableView, section: section, didExpand: header)
            }
        } else {
            if sView?.getExpanded() ?? false {
                sView?.setExpanded(false)
                expandedCells(expanded: false, section)
                delegate?.oyTableView(tableView, section: section, didCollapse: header)
            } else {
                sView?.setExpanded(true)
                expandedCells(expanded: true, section)
                delegate?.oyTableView(tableView, section: section, didExpand: header)
            }
        }

        tableView.beginUpdates()
        for i in 0 ..< tableView.numberOfRows(inSection: section) {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .fade)
        }
        tableView.endUpdates()

        if autoScroll && header.getExpanded() {
            tableView.scrollToRow(at: IndexPath(row: tableView.numberOfRows(inSection: section) - 1, section: section), at: .middle, animated: true)
        }
    }

    private func expandedCells(expanded: Bool, _ section: Int) {
        if !collapseOtherCell {
            if expanded {
                expandedCells.append(section)
            } else {
                expandedCells = expandedCells.filter() { $0 != section }
            }
        }
    }
}

extension OYTableView: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.numberOfSections(in: tableView)
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.oyTableView(tableView, numberOfRowsInSection: section)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.oyTableView(tableView, heightForHeaderInSection: section)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if collapseOtherCell {
            if index != indexPath.section || index == -1 {
                return 0
            } else {
                guard let dataSource = dataSource else { return UITableViewAutomaticDimension }
                return dataSource.oyTableView(tableView, heightForRowAt: indexPath)
            }
        } else {
            if !expandedCells.contains(indexPath.section) {
                return 0
            } else {
                guard let dataSource = dataSource else { return UITableViewAutomaticDimension }
                return dataSource.oyTableView(tableView, heightForRowAt: indexPath)
            }
        }
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let dataSource = dataSource else { return nil }
        return dataSource.oyTableView(tableView, viewForHeaderInSection: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataSource = dataSource else { return UITableViewCell() }
        return dataSource.oyTableView(tableView, cellForRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        delegate.oyTableView(tableView, didSelectRowAt: indexPath)
    }
}

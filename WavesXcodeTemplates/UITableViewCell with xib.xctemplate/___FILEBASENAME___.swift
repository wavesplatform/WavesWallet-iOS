//___FILEHEADER___

import UIKit
import UITools

final class ___FILEBASENAME___: UITableViewCell, ResetableView, TableViewRegisterable, NibLoadable {
  override func awakeFromNib() {
    super.awakeFromNib()
    resetToEmptyState()
    initialSetup()
  }

  func resetToEmptyState() {}

  private func initialSetup() {}
}

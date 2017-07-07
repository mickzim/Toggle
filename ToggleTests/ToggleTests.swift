import FBSnapshotTestCase
@testable import Toggle

class ToggleTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        recordMode = true
    }
    
    func testToggle() {
        let toggle = Toggle(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        toggle.setNeedsLayout()
        toggle.layoutIfNeeded()

        FBSnapshotVerifyView(toggle)
        FBSnapshotVerifyLayer(toggle.layer)

    }

    func testToggleIsEnabled() {
        let toggle = Toggle(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        toggle.selectionState = true
        toggle.setNeedsLayout()
        toggle.layoutIfNeeded()

        FBSnapshotVerifyView(toggle)
        FBSnapshotVerifyLayer(toggle.layer)
    }

    func testToggleIsDisabled() {
        let toggle = Toggle(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        toggle.selectionState = false
        toggle.setNeedsLayout()
        toggle.layoutIfNeeded()

        FBSnapshotVerifyView(toggle)
        FBSnapshotVerifyLayer(toggle.layer)
    }

}

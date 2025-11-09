import Testing
@testable import Durighe

@Test func example() async throws {
    let manager = NoticeManager()
    let start = Date()
    let end = Date().addingTimeInterval(3600)
    let notice = Notice(text: "Ciao",
                        startDate: start,
                        endDate: end,
                        appVersion: "1.0.1")
    let displayable = manager.noticeIsDisplayable(notice)
    
    #expect(displayable)
    
}

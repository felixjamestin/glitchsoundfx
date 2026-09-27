import Foundation
import Testing
import GlitchSoundFXExceptions

@Suite("Playback exceptions")
struct PlaybackExceptionTests {
    @Test("an Objective-C exception inside the block is returned instead of crashing")
    func returnsException() {
        let exception = GSFXCatchException {
            NSException(name: .internalInconsistencyException, reason: "player did not see an IO cycle.").raise()
        }

        #expect(exception?.reason == "player did not see an IO cycle.")
    }

    @Test("a block that does not throw runs and reports nothing")
    func noException() {
        var ran = false

        #expect(GSFXCatchException { ran = true } == nil)
        #expect(ran)
    }
}

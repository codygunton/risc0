// Test that fence instruction works in the emulator
use risc0_circuit_rv32im::execute::testutil::{self, Assembler};
use risc0_binfmt::MemoryImage;

fn main() {
    // Create a simple program with fence instruction
    let mut asm = Assembler::new();
    asm.fence();
    asm.host_terminate(0, 0);
    let program = asm.program();
    
    let image = MemoryImage::new_kernel(program);
    
    // Test execution without proving
    match testutil::execute(
        image,
        20, // DEFAULT_SEGMENT_LIMIT_PO2
        1048576, // MAX_INSN_CYCLES
        testutil::DEFAULT_SESSION_LIMIT,
        &testutil::NullSyscall,
        None,
    ) {
        Ok(session) => {
            println!("✓ Fence emulator test passed!");
            println!("  Executed {} segments", session.segments.len());
            if let Some(seg) = session.segments.first() {
                println!("  Cycles: {}", seg.suspend_cycle);
            }
        }
        Err(e) => {
            println!("✗ Fence emulator test failed: {}", e);
            std::process::exit(1);
        }
    }
}
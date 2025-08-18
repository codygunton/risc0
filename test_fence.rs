use risc0_binfmt::{MemoryImage, Program};
use risc0_circuit_rv32im::execute::{testutil, testutil::Assembler, CycleLimit};

fn main() {
    // Create a simple program with a fence instruction
    let mut asm = Assembler::new();
    asm.fence();
    asm.host_terminate(0, 0);
    let program = asm.program();
    
    let image = MemoryImage::new_kernel(program);
    let result = testutil::execute(
        image,
        20, // DEFAULT_SEGMENT_LIMIT_PO2
        1048576, // MAX_INSN_CYCLES
        CycleLimit::Hard(1 << 20), // Smaller limit
        &testutil::NullSyscall,
        None,
    );
    
    match result {
        Ok(_) => println!("Fence test passed!"),
        Err(e) => println!("Fence test failed: {}", e),
    }
}

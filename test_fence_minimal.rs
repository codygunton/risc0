use risc0_binfmt::{MemoryImage, Program};
use risc0_circuit_rv32im::execute::{testutil, CycleLimit};

fn main() {
    // Create a minimal program with just fence and terminate
    let image = vec![
        (0x2010000, 0x0000000f), // fence (simplest form)
        (0x2010004, 0x00500073), // ecall to terminate (a7=5)
    ];
    
    let program = Program::new_from_entry_and_image(0x2010000, image.into_iter().collect());
    let memory_image = MemoryImage::new_kernel(program);
    
    println!("Running minimal fence test...");
    match testutil::execute(
        memory_image,
        20,
        1048576,
        CycleLimit::Hard(1 << 20),
        &testutil::NullSyscall,
        None,
    ) {
        Ok(session) => {
            println!("Success! {} segments", session.segments.len());
        }
        Err(e) => {
            println!("Failed: {:?}", e);
        }
    }
}
RAYON_NUM_THREADS=8 ./hfuzz \
  --threads 4 \
  --timeout 30 \
  -i corpus \
  --workspace hfuzz_workdir \
  --crashdir hfuzz_crashes \
  -x \
  -- ./target/release/r0vm --test-elf ___FILE___

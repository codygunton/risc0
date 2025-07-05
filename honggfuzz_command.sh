RAYON_NUM_THREADS=1 ./hfuzz \
  --threads 1 \
  --timeout 30 \
  --mutate_cmd generate_and_move.sh \
  -i corpus \
  --workspace hfuzz_workdir \
  --crashdir hfuzz_crashes \
  -x \
  -- ./target/release/r0vm --test-elf ___FILE___

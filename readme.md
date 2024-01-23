# Z8 Softcore

The project is about implementing a Zilog Z8 microcontroller in Verilog.
Its aim is to be able to run the [Tiny computer](https://hc-ddr.hucki.net/wiki/doku.php/tiny) in a Tang Tano 9k (if possible).

## State

- [ ] implement all operations
  - [x] `nop`
  - [x] carry-flag manipulation operations
  - [x] `srp #IM`
  - [x] single-register ALU operations
    - [x] direct, e.g. `inc %22`
    - [x] indirect, e.g. `dec @%22`
    - [x] `inc r`
  - [ ] dual-register ALU operations
    - [x] `xxx r1, r2`
    - [x] `xxx r1, Ir2`
    - [ ] `xxx R1, R2`
    - [ ] `xxx IR1, R2`
    - [x] `xxx R, #IM`
    - [ ] `xxx IR, #IM`
  - load operations
    - [x] `ld r, #IM`
    - [x] `ld r1, R2`
    - [ ] `ld R1, r2`
    - [ ] `ld r1, Ir2`
    - [ ] `ld Ir1, r2`
    - [x] `ld R1, R2`
    - [ ] `ld R1, IR2`
    - [ ] `ld IR1, R2`
    - [x] `ld R, #IM`
    - [ ] `ld IR, #IM`
    - [ ] `ld r1, r2(x)`
    - [ ] `ld r1(x), r2`
  - [ ] control flow operations
    - [x] `djnz r, RA`
    - [x] `jr cc, RA`
    - [x] `jp cc, DA`
    - [ ] `jp IRR`
  - [ ] `di`, `ei` (disable/enable interrupt)
  - [ ] memory operations
    - [x] `ldc r1, Irr2`
    - [x] `ldc Irr1, r2`
    - [x] `ldci Ir1, Irr2`
    - [x] `ldci Irr1, Ir2`
    - [ ] let `lde`/`ldei` work the same as `ldc`/`ldci`
  - [ ] stack operations
    - [ ] internal stack
      - [x] `pop R`
      - [x] `pop IR`
      - [x] `push R`
      - [x] `push IR`
      - [ ] `call IRR`
      - [x] `call DA`
      - [x] `ret`
      - [x] `iret`
    - [x] external stack
- [ ] port 2
- [ ] port 3
- [ ] Counters
- [ ] UART
- [ ] interrupt handling

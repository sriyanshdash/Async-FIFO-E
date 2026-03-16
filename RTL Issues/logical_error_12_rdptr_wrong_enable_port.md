# [ASYNC_FIFO][RTL][ERR_012][rdptr_handler.sv][LINE_27][LOGICAL] Port declared as wr_en instead of rd_en in read pointer handler

**Error Type:** Logical Error

---

## --- SUMMARY ---

- Line 27 of `rdptr_handler.sv` declares the input enable signal as `wr_en` (write enable) instead of `rd_en` (read enable). The read pointer handler should be controlled by the read enable signal, not the write enable.

---

## --- PURPOSE/SETTINGS ---

- **Design module:** `rptr_handler` (read pointer handler)
- **File name:** `rtl/rdptr_handler.sv`
- **Line affected:** 27

---

## --- ANALYSIS ---

- The read pointer handler module's port list declares `wr_en` as an input, but this module is responsible for managing the read pointer. It should use `rd_en` to determine when to increment the read pointer.
- Using `wr_en` means the read pointer would be driven by write operations, which completely breaks FIFO read functionality.
- **Buggy:** `input rdclk, rrst_n, wr_en,`
- **Fix:** `input rdclk, rrst_n, rd_en,`

---

## --- OTHER TEST INFORMATION ---

- **File path:** `rtl/rdptr_handler.sv`
- **Line number:** 27

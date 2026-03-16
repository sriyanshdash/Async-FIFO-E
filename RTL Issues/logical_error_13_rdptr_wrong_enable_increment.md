# [ASYNC_FIFO][RTL][ERR_013][rdptr_handler.sv][LINE_36][LOGICAL] Read pointer incremented using wr_en instead of rd_en

**Error Type:** Logical Error

---

## --- SUMMARY ---

- Line 36 of `rdptr_handler.sv` uses `wr_en` to conditionally increment the binary read pointer. The read pointer should only increment when `rd_en` is asserted and the FIFO is not empty.

---

## --- PURPOSE/SETTINGS ---

- **Design module:** `rptr_handler` (read pointer handler)
- **File name:** `rtl/rdptr_handler.sv`
- **Line affected:** 36

---

## --- ANALYSIS ---

- The read pointer next-value calculation uses `wr_en` instead of `rd_en`. This is a direct consequence of Error 12 (wrong port declaration), causing the read pointer to advance on write operations instead of read operations.
- This completely breaks FIFO read functionality as data will be skipped or read at wrong times.
- **Buggy:** `assign b_rptr_next = b_rptr + (wr_en & !fifo_empty);`
- **Fix:** `assign b_rptr_next = b_rptr + (rd_en & !fifo_empty);`

---

## --- OTHER TEST INFORMATION ---

- **File path:** `rtl/rdptr_handler.sv`
- **Line number:** 36

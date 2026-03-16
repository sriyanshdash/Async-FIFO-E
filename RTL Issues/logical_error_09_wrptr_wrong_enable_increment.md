# [ASYNC_FIFO][RTL][ERR_009][wrptr_handler.sv][LINE_39][LOGICAL] Write pointer incremented using rd_en instead of wr_en

**Error Type:** Logical Error

---

## --- SUMMARY ---

- Line 39 of `wrptr_handler.sv` uses `rd_en` to conditionally increment the binary write pointer. The write pointer should only increment when `wr_en` is asserted and the FIFO is not full.

---

## --- PURPOSE/SETTINGS ---

- **Design module:** `wptr_handler` (write pointer handler)
- **File name:** `rtl/wrptr_handler.sv`
- **Line affected:** 39

---

## --- ANALYSIS ---

- The write pointer next-value calculation uses `rd_en` instead of `wr_en`. This is a direct consequence of Error 8 (wrong port declaration), but even if the port were fixed, this line explicitly references the wrong signal.
- This causes the write pointer to advance on read operations instead of write operations, completely breaking FIFO write functionality.
- **Buggy:** `assign b_wptr_next = b_wptr + (rd_en & !fifo_full);`
- **Fix:** `assign b_wptr_next = b_wptr + (wr_en & !fifo_full);`

---

## --- OTHER TEST INFORMATION ---

- **File path:** `rtl/wrptr_handler.sv`
- **Line number:** 39

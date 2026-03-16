# [ASYNC_FIFO][RTL][ERR_008][wrptr_handler.sv][LINE_27][LOGICAL] Port declared as rd_en instead of wr_en in write pointer handler

**Error Type:** Logical Error

---

## --- SUMMARY ---

- Line 27 of `wrptr_handler.sv` declares the input enable signal as `rd_en` (read enable) instead of `wr_en` (write enable). The write pointer handler should be controlled by the write enable signal, not the read enable.

---

## --- PURPOSE/SETTINGS ---

- **Design module:** `wptr_handler` (write pointer handler)
- **File name:** `rtl/wrptr_handler.sv`
- **Line affected:** 27

---

## --- ANALYSIS ---

- The write pointer handler module's port list declares `rd_en` as an input, but this module is responsible for managing the write pointer. It should use `wr_en` to determine when to increment the write pointer.
- Using `rd_en` means the write pointer would be driven by read operations, which completely breaks FIFO write functionality.
- **Buggy:** `input wrclk, wrst_n, rd_en,`
- **Fix:** `input wrclk, wrst_n, wr_en,`

---

## --- OTHER TEST INFORMATION ---

- **File path:** `rtl/wrptr_handler.sv`
- **Line number:** 27

# [ASYNC_FIFO][RTL][ERR_015][fifo_memory.sv][LINE_35][LOGICAL] Write guard condition uses fifo_empty instead of !fifo_full

**Error Type:** Logical Error

---

## --- SUMMARY ---

- Line 35 of `fifo_memory.sv` guards the write operation with `fifo_empty` instead of `!fifo_full`. Writes should be allowed when the FIFO is NOT FULL, not when it is empty. This inverted condition prevents writes when the FIFO has data and allows writes only when the FIFO is empty.

---

## --- PURPOSE/SETTINGS ---

- **Design module:** `fifo_mem` (FIFO memory)
- **File name:** `rtl/fifo_memory.sv`
- **Line affected:** 35

---

## --- ANALYSIS ---

- The write guard `wr_en & fifo_empty` only allows writes when the FIFO is empty. Once the first word is written and the FIFO is no longer empty, all subsequent writes are blocked — making the FIFO effectively a single-entry buffer.
- The correct condition is `wr_en & !fifo_full`, which allows writes as long as the FIFO has space.
- **Buggy:** `if (wr_en & fifo_empty)`
- **Fix:** `if (wr_en & !fifo_full)`

---

## --- OTHER TEST INFORMATION ---

- **File path:** `rtl/fifo_memory.sv`
- **Line number:** 35

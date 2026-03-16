# [ASYNC_FIFO][RTL][ERR_016][fifo_memory.sv][LINE_42][LOGICAL] Read guard condition uses fifo_full instead of !fifo_empty

**Error Type:** Logical Error

---

## --- SUMMARY ---

- Line 42 of `fifo_memory.sv` guards the read operation with `fifo_full` instead of `!fifo_empty`. Reads should be allowed when the FIFO is NOT EMPTY, not when it is full. This inverted condition only allows reads when the FIFO is completely full.

---

## --- PURPOSE/SETTINGS ---

- **Design module:** `fifo_mem` (FIFO memory)
- **File name:** `rtl/fifo_memory.sv`
- **Line affected:** 42

---

## --- ANALYSIS ---

- The read guard `rd_en & fifo_full` only allows reads when the FIFO is completely full. Data cannot be read until every entry is occupied, making the FIFO unusable for normal streaming operation.
- The correct condition is `rd_en & !fifo_empty`, which allows reads as long as the FIFO has data.
- **Buggy:** `if (rd_en & fifo_full)`
- **Fix:** `if (rd_en & !fifo_empty)`

---

## --- OTHER TEST INFORMATION ---

- **File path:** `rtl/fifo_memory.sv`
- **Line number:** 42

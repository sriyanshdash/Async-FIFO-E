# [ASYNC_FIFO][RTL][ERR_010][wrptr_handler.sv][LINE_44-45][LOGICAL] Write pointer reset values are non-zero

**Error Type:** Logical Error

---

## --- SUMMARY ---

- Lines 44-45 of `wrptr_handler.sv` initialize `b_wptr` to 4 and `g_wptr` to 2 on reset. Both the binary and gray-coded write pointers must reset to 0 for the FIFO to start in an empty state.

---

## --- PURPOSE/SETTINGS ---

- **Design module:** `wptr_handler` (write pointer handler)
- **File name:** `rtl/wrptr_handler.sv`
- **Lines affected:** 44-45

---

## --- ANALYSIS ---

- On reset, the write pointers should be 0 so that the write and read pointers are equal, indicating an empty FIFO. Non-zero reset values create a mismatch between write and read pointers at startup, causing the FIFO to behave as if it already contains data or is in a corrupted state.
- `b_wptr <= 4` means the FIFO starts with a write pointer offset of 4, and `g_wptr <= 2` is the incorrect gray-code representation.
- **Buggy:**
  ```systemverilog
  b_wptr <= 4;
  g_wptr <= 2;
  ```
- **Fix:**
  ```systemverilog
  b_wptr <= 0;
  g_wptr <= 0;
  ```

---

## --- OTHER TEST INFORMATION ---

- **File path:** `rtl/wrptr_handler.sv`
- **Line numbers:** 44-45

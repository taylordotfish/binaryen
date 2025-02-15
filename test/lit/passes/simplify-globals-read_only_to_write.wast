;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.
;; NOTE: This test was ported using port_test.py and could be cleaned up.

;; RUN: foreach %s %t wasm-opt --simplify-globals -S -o - | filecheck %s

;; A global that is only read in order to be written is not needed.
(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $global i32 (i32.const 0))
  (global $global (mut i32) (i32.const 0))
  ;; CHECK:      (func $simple
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:   (drop
  ;; CHECK-NEXT:    (i32.const 1)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $simple
    (if
      (global.get $global)
      (global.set $global (i32.const 1))
    )
  )
  ;; CHECK:      (func $more-with-no-side-effects
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (i32.eqz
  ;; CHECK-NEXT:    (i32.const 0)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (block $block
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $more-with-no-side-effects
    (if
      ;; Also test for other operations in the condition, with no effects.
      (i32.eqz
        (global.get $global)
      )
      ;; Also test for other operations in the body, with no effects.
      (block
        (nop)
        (global.set $global (i32.const 1))
      )
    )
  )
  ;; CHECK:      (func $additional-set
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 2)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $additional-set
    ;; An additional set does not prevent this optimization: the value written
    ;; will never be read in a way that matters.
    (global.set $global (i32.const 2))
  )
)
;; An additional read prevents the read-only-to-write optimization.
(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $global (mut i32) (i32.const 0))
  (global $global (mut i32) (i32.const 0))
  ;; CHECK:      (func $additional-read
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $global)
  ;; CHECK-NEXT:   (global.set $global
  ;; CHECK-NEXT:    (i32.const 1)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (global.get $global)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $additional-read
    (if
      (global.get $global)
      (global.set $global (i32.const 1))
    )
    (drop
      (global.get $global)
    )
  )
)
;; We do not optimize if-elses in the read-only-to-write optimization.
(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $global (mut i32) (i32.const 0))
  (global $global (mut i32) (i32.const 0))
  ;; CHECK:      (func $if-else
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $global)
  ;; CHECK-NEXT:   (global.set $global
  ;; CHECK-NEXT:    (i32.const 1)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (nop)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-else
    (if
      (global.get $global)
      (global.set $global (i32.const 1))
      (nop)
    )
  )
)
;; Side effects in the condition prevent the read-only-to-write optimization.
(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $global (mut i32) (i32.const 0))
  (global $global (mut i32) (i32.const 0))
  ;; CHECK:      (global $other (mut i32) (i32.const 0))
  (global $other (mut i32) (i32.const 0))
  ;; CHECK:      (func $side-effects-in-condition
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (block $block (result i32)
  ;; CHECK-NEXT:    (global.set $other
  ;; CHECK-NEXT:     (i32.const 2)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (i32.const 2)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (global.get $global)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (global.set $global
  ;; CHECK-NEXT:    (i32.const 1)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $side-effects-in-condition
    (if
      (block (result i32)
        (global.set $other (i32.const 2))
        (drop (global.get $other))
        (global.get $global)
      )
      (global.set $global (i32.const 1))
    )
  )
)
;; Side effects in the body prevent the read-only-to-write optimization.
(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $global (mut i32) (i32.const 0))
  (global $global (mut i32) (i32.const 0))
  ;; CHECK:      (global $other (mut i32) (i32.const 0))
  (global $other (mut i32) (i32.const 0))
  ;; CHECK:      (func $side-effects-in-body
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $global)
  ;; CHECK-NEXT:   (block $block
  ;; CHECK-NEXT:    (global.set $global
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (global.set $other
  ;; CHECK-NEXT:     (i32.const 2)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (i32.const 2)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $side-effects-in-body
    (if
      (global.get $global)
      (block
        (global.set $global (i32.const 1))
        (global.set $other (i32.const 2))
        (drop (global.get $other))
      )
    )
  )
)
;; Nested patterns work as well, in a single run of the pass.
(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $a i32 (i32.const 0))
  (global $a (mut i32) (i32.const 0))
  ;; CHECK:      (global $b i32 (i32.const 0))
  (global $b (mut i32) (i32.const 0))
  ;; CHECK:      (global $c i32 (i32.const 0))
  (global $c (mut i32) (i32.const 0))

  ;; CHECK:      (func $nested
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:   (block $block
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (if
  ;; CHECK-NEXT:     (i32.const 0)
  ;; CHECK-NEXT:     (block $block1
  ;; CHECK-NEXT:      (if
  ;; CHECK-NEXT:       (i32.const 0)
  ;; CHECK-NEXT:       (block $block3
  ;; CHECK-NEXT:        (drop
  ;; CHECK-NEXT:         (i32.const 2)
  ;; CHECK-NEXT:        )
  ;; CHECK-NEXT:       )
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:      (drop
  ;; CHECK-NEXT:       (i32.const 3)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $nested
    (if
      (global.get $a)
      (block
        (global.set $a (i32.const 1))
        (if
          (global.get $b)
          (block
            (if
              (global.get $c)
              (block
                (global.set $c (i32.const 2))
              )
            )
            (global.set $b (i32.const 3))
          )
        )
      )
    )
  )
)

(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $once i32 (i32.const 0))
  (global $once (mut i32) (i32.const 0))

  ;; CHECK:      (func $clinit
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $clinit
    ;; A read-only-to-write that takes an entire function body, and is in the
    ;; form if "if already set, return; set it". In particular, the set is not
    ;; in the if body in this case.
    (if
      (global.get $once)
      (return)
    )
    (global.set $once
      (i32.const 1)
    )
  )
)

(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $once (mut i32) (i32.const 0))
  (global $once (mut i32) (i32.const 0))

  ;; CHECK:      (func $clinit
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $once)
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $once
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $clinit
    ;; As above, but the optimization fails because the function body has too
    ;; many elements - a nop is added at the end.
    (if
      (global.get $once)
      (return)
    )
    (global.set $once
      (i32.const 1)
    )
    (nop)
  )
)

(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $once (mut i32) (i32.const 0))
  (global $once (mut i32) (i32.const 0))

  ;; CHECK:      (func $clinit
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $once)
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:   (nop)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $once
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $clinit
    ;; As above, but the optimization fails because the if has an else.
    (if
      (global.get $once)
      (return)
      (nop)
    )
    (global.set $once
      (i32.const 1)
    )
  )
)

(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $once (mut i32) (i32.const 0))
  (global $once (mut i32) (i32.const 0))

  ;; CHECK:      (func $clinit
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $once)
  ;; CHECK-NEXT:   (nop)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $once
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $clinit
    ;; As above, but the optimization fails because the if body is not a
    ;; return.
    (if
      (global.get $once)
      (nop)
    )
    (global.set $once
      (i32.const 1)
    )
  )
)

(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $once (mut i32) (i32.const 0))
  (global $once (mut i32) (i32.const 0))

  ;; CHECK:      (func $clinit
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (block $block (result i32)
  ;; CHECK-NEXT:    (unreachable)
  ;; CHECK-NEXT:    (global.get $once)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $once
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $clinit
    ;; As above, but the optimization fails because the if body has effects.
    (if
      (block (result i32)
        (unreachable)
        (global.get $once)
      )
      (return)
    )
    (global.set $once
      (i32.const 1)
    )
  )
)

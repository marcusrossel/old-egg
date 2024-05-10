import EggTactic
import Lean

variable (h : ∀ x : Prop, True = x)

example : True = True := by
  apply Eq.trans
  · egg [h]
  · rfl -- This assigns the mvar resulting from `Eq.trans`.

example : True = True := by
  apply Eq.trans
  · egg [h]
  · egg [h]
  fail_if_success done

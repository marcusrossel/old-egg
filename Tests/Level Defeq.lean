import EggTactic

-- The only difference between these two and the next two examples is the order of universe levels
-- in `[]`. That is, the second examples require commutativity of `Level.max`.

example (f : α → γ) (g : β → δ) : List.map (Prod.map f g) [] = [] := by
  egg [List.map]

example (f : α → γ) (g : β → δ) : List.map (Prod.map f g) [] = [] := by
  egg [List.map]

variable {α : Type _} {β : Type _} {γ : Type _} {δ : Type _}

example (f : α → γ) (g : β → δ) : List.map (Prod.map f g) [] = [] := by
  egg [List.map]

-- This example requires `Level.succ (Level.max _ _) = Level.max (Level.succ _) (Level.succ _)`.
example (h : ∀ γ : Type (max u v), γ = id γ) (α : Type u) (β : Type v) : (α × β) = id (α × β) := by
  egg [h]

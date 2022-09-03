-- http://leanprover.github.io/ijcar16/examples/

/-
This is a file from the Lean standard library.
We use it to demonstrate/test the congruence closure procedure
described in the paper:
  "Congruence Closure for Intensional Type Theory"
   Daniel Selsam and Leonardo de Moura

The lemmas proved using `by inst_simp` are using the congruence closure
procedure described in the paper above.

The lemmas proved using `by rec_inst_simp` are also using the congruence closure
procedure described in the paper above. They first apply induction, and then use
`inst_simp`.

The tactic inst_simp uses E-matching to heuristically instantiate
lemmas tagged as simplification rules (i.e., `[simp]` tag in Lean).

There are 15 instances `by inst_simp` and `by rec_inst_simp` in this file.
-/
import data.nat
open nat

inductive list (T : Type) : Type :=
| nil {} : list T
| cons   : T → list T → list T

namespace list
notation h :: t  := cons h t
notation `[` l:(foldr `, ` (h t, cons h t) nil `]`) := l

variable {T : Type}

lemma cons_ne_nil [simp] (a : T) (l : list T) : a::l ≠ [] :=
by contradiction

lemma head_eq_of_cons_eq {A : Type} {h₁ h₂ : A} {t₁ t₂ : list A} :
      (h₁::t₁) = (h₂::t₂) → h₁ = h₂ :=
by inst_simp

lemma tail_eq_of_cons_eq {A : Type} {h₁ h₂ : A} {t₁ t₂ : list A} :
      (h₁::t₁) = (h₂::t₂) → t₁ = t₂ :=
by inst_simp

/- append -/

definition append : list T → list T → list T
| []       l := l
| (h :: s) t := h :: (append s t)

notation l₁ ++ l₂ := append l₁ l₂

theorem append_nil_left [simp] (t : list T) : [] ++ t = t :=
rfl

theorem append_cons [simp] (x : T) (s t : list T) : (x::s) ++ t = x::(s ++ t) :=
rfl

theorem append_nil_right [simp] : ∀ (t : list T), t ++ [] = t :=
by rec_inst_simp

theorem append.assoc [simp] : ∀ (s t u : list T), s ++ t ++ u = s ++ (t ++ u) :=
by rec_inst_simp

/- length -/
definition length : list T → nat
| []       := 0
| (a :: l) := length l + 1

theorem length_nil [simp] : length (@nil T) = 0 :=
rfl

theorem length_cons [simp] (x : T) (t : list T) : length (x::t) = length t + 1 :=
rfl

theorem length_append [simp] : ∀ (s t : list T), length (s ++ t) = length s + length t :=
by rec_inst_simp

theorem eq_nil_of_length_eq_zero : ∀ {l : list T}, length l = 0 → l = []
| []     H := rfl
| (a::s) H := by contradiction

theorem ne_nil_of_length_eq_succ : ∀ {l : list T} {n : nat}, length l = succ n → l ≠ []
| []     n h := by contradiction
| (a::l) n h := by contradiction

/- concat -/

definition concat : Π (x : T), list T → list T
| a []       := [a]
| a (b :: l) := b :: concat a l

theorem concat_nil [simp] (x : T) : concat x [] = [x] :=
rfl

theorem concat_cons [simp] (x y : T) (l : list T) : concat x (y::l)  = y::(concat x l) :=
rfl

theorem concat_eq_append [simp] (a : T) : ∀ (l : list T), concat a l = l ++ [a] :=
by rec_inst_simp

theorem concat_ne_nil [simp] (a : T) : ∀ (l : list T), concat a l ≠ [] :=
by intro l; induction l; repeat contradiction

theorem length_concat [simp] (a : T) : ∀ (l : list T), length (concat a l) = length l + 1 :=
by rec_inst_simp

theorem concat_append [simp] (a : T) : ∀ (l₁ l₂ : list T), concat a l₁ ++ l₂ = l₁ ++ a :: l₂ :=
by rec_inst_simp

theorem append_concat (a : T)  : ∀(l₁ l₂ : list T), l₁ ++ concat a l₂ = concat a (l₁ ++ l₂) :=
by rec_inst_simp

/- last -/

definition last : Π l : list T, l ≠ [] → T
| []          h := absurd rfl h
| [a]         h := a
| (a₁::a₂::l) h := last (a₂::l) !cons_ne_nil

lemma last_singleton [simp] (a : T) (h : [a] ≠ []) : last [a] h = a :=
rfl

lemma last_cons_cons [simp] (a₁ a₂ : T) (l : list T) (h : a₁::a₂::l ≠ []) : last (a₁::a₂::l) h = last (a₂::l) !cons_ne_nil :=
rfl

theorem last_congr {l₁ l₂ : list T} (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) (h₃ : l₁ = l₂) : last l₁ h₁ = last l₂ h₂ :=
by subst l₁

theorem last_concat [simp] {x : T} : ∀ {l : list T} (h : concat x l ≠ []), last (concat x l) h = x :=
by rec_simp

-- add_rewrite append_nil append_cons

/- reverse -/

definition reverse : list T → list T
| []       := []
| (a :: l) := concat a (reverse l)

theorem reverse_nil [simp] : reverse (@nil T) = [] :=
rfl

theorem reverse_cons [simp] (x : T) (l : list T) : reverse (x::l) = concat x (reverse l) :=
rfl

theorem reverse_singleton [simp] (x : T) : reverse [x] = [x] :=
rfl

theorem reverse_append [simp] : ∀ (s t : list T), reverse (s ++ t) = (reverse t) ++ (reverse s) :=
by rec_inst_simp

theorem reverse_reverse [simp] : ∀ (l : list T), reverse (reverse l) = l :=
by rec_inst_simp

theorem concat_eq_reverse_cons (x : T) (l : list T) : concat x l = reverse (x :: reverse l) :=
by inst_simp

theorem length_reverse : ∀ (l : list T), length (reverse l) = length l :=
by rec_inst_simp

/- head and tail -/

definition head [h : inhabited T] : list T → T
| []       := arbitrary T
| (a :: l) := a

theorem head_cons [simp] [h : inhabited T] (a : T) (l : list T) : head (a::l) = a :=
rfl

theorem head_append [simp] [h : inhabited T] (t : list T) : ∀ {s : list T}, s ≠ [] → head (s ++ t) = head s :=
by rec_inst_simp

definition tail : list T → list T
| []       := []
| (a :: l) := l

theorem tail_nil [simp] : tail (@nil T) = [] :=
rfl

theorem tail_cons [simp] (a : T) (l : list T) : tail (a::l) = l :=
rfl

theorem cons_head_tail [h : inhabited T] {l : list T} : l ≠ [] → (head l)::(tail l) = l :=
by rec_inst_simp

end list


/-
This is a file from the Lean standard library.
We use it to demonstrate/test the congruence closure procedure
described in the paper:
  "Congruence Closure for Intensional Type Theory"
   Daniel Selsam and Leonardo de Moura

The lemmas proved using `by inst_simp` are using the congruence closure
procedure described in the paper above.

The tactic inst_simp uses E-matching to heuristically instantiate
lemmas tagged as simplification rules (i.e., `[simp]` tag in Lean).

There are more than 100 instances of `by inst_simp` in this file.
-/
import algebra.binary algebra.priority

variable {A : Type}

/- semigroup -/

attribute inv [light 3]
attribute neg [light 3]

structure semigroup [class] (A : Type) extends has_mul A :=
(mul_assoc : ∀a b c, mul (mul a b) c = mul a (mul b c))

-- We add pattern hints to the following lemma because we want it to be used in both directions
-- at inst_simp strategy.
theorem mul.assoc [simp] [semigroup A] (a b c : A) : (: a * b * c :) = (: a * (b * c) :) :=
!semigroup.mul_assoc

structure comm_semigroup [class] (A : Type) extends semigroup A :=
(mul_comm : ∀a b, mul a b = mul b a)

theorem mul.comm [simp] [comm_semigroup A] (a b : A) : a * b = b * a :=
!comm_semigroup.mul_comm

theorem mul.left_comm [simp] [comm_semigroup A] (a b c : A) : a * (b * c) = b * (a * c) :=
binary.left_comm (@mul.comm A _) (@mul.assoc A _) a b c

theorem mul.right_comm [comm_semigroup A] (a b c : A) : (a * b) * c = (a * c) * b :=
by inst_simp

structure left_cancel_semigroup [class] (A : Type) extends semigroup A :=
(mul_left_cancel : ∀a b c, mul a b = mul a c → b = c)

theorem mul.left_cancel [left_cancel_semigroup A] {a b c : A} : a * b = a * c → b = c :=
!left_cancel_semigroup.mul_left_cancel

abbreviation eq_of_mul_eq_mul_left' := @mul.left_cancel

structure right_cancel_semigroup [class] (A : Type) extends semigroup A :=
(mul_right_cancel : ∀a b c, mul a b = mul c b → a = c)

theorem mul.right_cancel [right_cancel_semigroup A] {a b c : A} : a * b = c * b → a = c :=
!right_cancel_semigroup.mul_right_cancel

abbreviation eq_of_mul_eq_mul_right' := @mul.right_cancel

/- additive semigroup -/

structure add_semigroup [class] (A : Type) extends has_add A :=
(add_assoc : ∀a b c, add (add a b) c = add a (add b c))

theorem add.assoc [simp] [add_semigroup A] (a b c : A) : (: a + b + c :) = (: a + (b + c) :) :=
!add_semigroup.add_assoc

structure add_comm_semigroup [class] (A : Type) extends add_semigroup A :=
(add_comm : ∀a b, add a b = add b a)

theorem add.comm [simp] [add_comm_semigroup A] (a b : A) : a + b = b + a :=
!add_comm_semigroup.add_comm

theorem add.left_comm [simp] [add_comm_semigroup A] (a b c : A) : a + (b + c) = b + (a + c) :=
binary.left_comm (@add.comm A _) (@add.assoc A _) a b c

theorem add.right_comm [add_comm_semigroup A] (a b c : A) : (a + b) + c = (a + c) + b :=
by inst_simp

structure add_left_cancel_semigroup [class] (A : Type) extends add_semigroup A :=
(add_left_cancel : ∀a b c, add a b = add a c → b = c)

theorem add.left_cancel [add_left_cancel_semigroup A] {a b c : A} : a + b = a + c → b = c :=
!add_left_cancel_semigroup.add_left_cancel

abbreviation eq_of_add_eq_add_left := @add.left_cancel

structure add_right_cancel_semigroup [class] (A : Type) extends add_semigroup A :=
(add_right_cancel : ∀a b c, add a b = add c b → a = c)

theorem add.right_cancel [add_right_cancel_semigroup A] {a b c : A} : a + b = c + b → a = c :=
!add_right_cancel_semigroup.add_right_cancel

abbreviation eq_of_add_eq_add_right := @add.right_cancel

/- monoid -/

structure monoid [class] (A : Type) extends semigroup A, has_one A :=
(one_mul : ∀a, mul one a = a) (mul_one : ∀a, mul a one = a)

theorem one_mul [simp] [monoid A] (a : A) : 1 * a = a := !monoid.one_mul

theorem mul_one [simp] [monoid A] (a : A) : a * 1 = a := !monoid.mul_one

structure comm_monoid [class] (A : Type) extends monoid A, comm_semigroup A

/- additive monoid -/

structure add_monoid [class] (A : Type) extends add_semigroup A, has_zero A :=
(zero_add : ∀a, add zero a = a) (add_zero : ∀a, add a zero = a)

theorem zero_add [simp] [add_monoid A] (a : A) : 0 + a = a := !add_monoid.zero_add

theorem add_zero [simp] [add_monoid A] (a : A) : a + 0 = a := !add_monoid.add_zero

structure add_comm_monoid [class] (A : Type) extends add_monoid A, add_comm_semigroup A

definition add_monoid.to_monoid {A : Type} [add_monoid A] : monoid A :=
⦃ monoid,
  mul         := add_monoid.add,
  mul_assoc   := add_monoid.add_assoc,
  one         := add_monoid.zero A,
  mul_one     := add_monoid.add_zero,
  one_mul     := add_monoid.zero_add
⦄

definition add_comm_monoid.to_comm_monoid {A : Type} [add_comm_monoid A] : comm_monoid A :=
⦃ comm_monoid,
  add_monoid.to_monoid,
  mul_comm    := add_comm_monoid.add_comm
⦄

section add_comm_monoid
  variables [add_comm_monoid A]

  theorem add_comm_three  (a b c : A) : a + b + c = c + b + a :=
  by inst_simp

  theorem add.comm4 : ∀ (n m k l : A), n + m + (k + l) = n + k + (m + l) :=
  by inst_simp
end add_comm_monoid

/- group -/

structure group [class] (A : Type) extends monoid A, has_inv A :=
(mul_left_inv : ∀a, mul (inv a) a = one)

-- Note: with more work, we could derive the axiom one_mul

section group
  variable [group A]

  theorem mul.left_inv [simp] (a : A) : a⁻¹ * a = 1 := !group.mul_left_inv

  theorem inv_mul_cancel_left [simp] (a b : A) : a⁻¹ * (a * b) = b :=
  by inst_simp

  theorem inv_mul_cancel_right [simp] (a b : A) : a * b⁻¹ * b = a :=
  by inst_simp

  theorem inv_eq_of_mul_eq_one {a b : A} (H : a * b = 1) : a⁻¹ = b :=
  assert a⁻¹ * 1 = b, by inst_simp,
  by inst_simp

  theorem one_inv [simp] : 1⁻¹ = (1 : A) :=
  inv_eq_of_mul_eq_one (one_mul 1)

  theorem inv_inv [simp] (a : A) : (a⁻¹)⁻¹ = a :=
  inv_eq_of_mul_eq_one (mul.left_inv a)

  theorem inv.inj {a b : A} (H : a⁻¹ = b⁻¹) : a = b :=
  assert a = a⁻¹⁻¹, by simp_nohyps,
  by inst_simp

  theorem inv_eq_inv_iff_eq (a b : A) : a⁻¹ = b⁻¹ ↔ a = b :=
  iff.intro (assume H, inv.inj H) (by simp)

  theorem inv_eq_one_iff_eq_one (a : A) : a⁻¹ = 1 ↔ a = 1 :=
  assert a⁻¹ = 1⁻¹ ↔ a = 1, from inv_eq_inv_iff_eq a 1,
  by inst_simp

  theorem eq_one_of_inv_eq_one (a : A) : a⁻¹ = 1 → a = 1 :=
  iff.mp !inv_eq_one_iff_eq_one

  theorem eq_inv_of_eq_inv {a b : A} (H : a = b⁻¹) : b = a⁻¹ :=
  by inst_simp

  theorem eq_inv_iff_eq_inv (a b : A) : a = b⁻¹ ↔ b = a⁻¹ :=
  iff.intro !eq_inv_of_eq_inv !eq_inv_of_eq_inv

  theorem eq_inv_of_mul_eq_one {a b : A} (H : a * b = 1) : a = b⁻¹ :=
  assert a⁻¹ = b, from inv_eq_of_mul_eq_one H,
  by inst_simp

  theorem mul.right_inv [simp] (a : A) : a * a⁻¹ = 1 :=
  assert a = a⁻¹⁻¹, by simp,
  by inst_simp

  theorem mul_inv_cancel_left [simp] (a b : A) : a * (a⁻¹ * b) = b :=
  by inst_simp

  theorem mul_inv_cancel_right [simp] (a b : A) : a * b * b⁻¹ = a :=
  by inst_simp

  theorem mul_inv [simp] (a b : A) : (a * b)⁻¹ = b⁻¹ * a⁻¹ :=
  inv_eq_of_mul_eq_one (by inst_simp)

  theorem eq_of_mul_inv_eq_one {a b : A} (H : a * b⁻¹ = 1) : a = b :=
  assert a⁻¹ * 1 = a⁻¹, by inst_simp,
  by inst_simp

  theorem eq_mul_inv_of_mul_eq {a b c : A} (H : a * c = b) : a = b * c⁻¹ :=
  by inst_simp

  theorem eq_inv_mul_of_mul_eq {a b c : A} (H : b * a = c) : a = b⁻¹ * c :=
  by inst_simp

  theorem inv_mul_eq_of_eq_mul {a b c : A} (H : b = a * c) : a⁻¹ * b = c :=
  by inst_simp

  theorem mul_inv_eq_of_eq_mul {a b c : A} (H : a = c * b) : a * b⁻¹ = c :=
  by inst_simp

  theorem eq_mul_of_mul_inv_eq {a b c : A} (H : a * c⁻¹ = b) : a = b * c :=
  by inst_simp

  theorem eq_mul_of_inv_mul_eq {a b c : A} (H : b⁻¹ * a = c) : a = b * c :=
  by inst_simp

  theorem mul_eq_of_eq_inv_mul {a b c : A} (H : b = a⁻¹ * c) : a * b = c :=
  by inst_simp

  theorem mul_eq_of_eq_mul_inv {a b c : A} (H : a = c * b⁻¹) : a * b = c :=
  by inst_simp

  theorem mul_eq_iff_eq_inv_mul (a b c : A) : a * b = c ↔ b = a⁻¹ * c :=
  iff.intro eq_inv_mul_of_mul_eq mul_eq_of_eq_inv_mul

  theorem mul_eq_iff_eq_mul_inv (a b c : A) : a * b = c ↔ a = c * b⁻¹ :=
  iff.intro eq_mul_inv_of_mul_eq mul_eq_of_eq_mul_inv

  theorem mul_left_cancel {a b c : A} (H : a * b = a * c) : b = c :=
  assert a⁻¹ * (a * b) = b, by inst_simp,
  by inst_simp

  theorem mul_right_cancel {a b c : A} (H : a * b = c * b) : a = c :=
  assert a * b * b⁻¹ = a, by inst_simp,
  by inst_simp

  theorem mul_eq_one_of_mul_eq_one {a b : A} (H : b * a = 1) : a * b = 1 :=
  by rewrite [-inv_eq_of_mul_eq_one H, mul.left_inv]

  theorem mul_eq_one_iff_mul_eq_one (a b : A) : a * b = 1 ↔ b * a = 1 :=
  iff.intro !mul_eq_one_of_mul_eq_one !mul_eq_one_of_mul_eq_one

  definition conj_by (g a : A) := g * a * g⁻¹
  definition is_conjugate (a b : A) := ∃ x, conj_by x b = a

  local infixl ` ~ ` := is_conjugate
  local infixr ` ∘c `:55 := conj_by

  local attribute conj_by [reducible]

  lemma conj_compose [simp] (f g a : A) : f ∘c g ∘c a = f*g ∘c a :=
  by inst_simp

  lemma conj_id [simp] (a : A) : 1 ∘c a = a :=
  by inst_simp

  lemma conj_one [simp] (g : A) : g ∘c 1 = 1 :=
  by inst_simp

  lemma conj_inv_cancel [simp] (g : A) : ∀ a, g⁻¹ ∘c g ∘c a = a :=
  by inst_simp

  lemma conj_inv [simp] (g : A) : ∀ a, (g ∘c a)⁻¹ = g ∘c a⁻¹ :=
  by inst_simp

  lemma is_conj.refl (a : A) : a ~ a := exists.intro 1 (conj_id a)

  lemma is_conj.symm (a b : A) : a ~ b → b ~ a :=
  assume Pab, obtain x (Pconj : x ∘c b = a), from Pab,
  assert Pxinv : x⁻¹ ∘c x ∘c b = x⁻¹ ∘c a,   by simp,
  exists.intro x⁻¹ (by inst_simp)

  lemma is_conj.trans (a b c : A) : a ~ b → b ~ c → a ~ c :=
  assume Pab, assume Pbc,
  obtain x (Px : x ∘c b = a), from Pab,
  obtain y (Py : y ∘c c = b), from Pbc,
  exists.intro (x*y) (by inst_simp)

end group

definition group.to_left_cancel_semigroup [trans_instance] [reducible] [s : group A] :
    left_cancel_semigroup A :=
⦃ left_cancel_semigroup, s,
  mul_left_cancel := @mul_left_cancel A s ⦄

definition group.to_right_cancel_semigroup [trans_instance] [reducible] [s : group A] :
    right_cancel_semigroup A :=
⦃ right_cancel_semigroup, s,
  mul_right_cancel := @mul_right_cancel A s ⦄

structure comm_group [class] (A : Type) extends group A, comm_monoid A

/- additive group -/

structure add_group [class] (A : Type) extends add_monoid A, has_neg A :=
(add_left_inv : ∀a, add (neg a) a = zero)

definition add_group.to_group {A : Type} [add_group A] : group A :=
⦃ group, add_monoid.to_monoid,
  mul_left_inv := add_group.add_left_inv ⦄


section add_group
  variables [s : add_group A]
  include s

  theorem add.left_inv [simp] (a : A) : -a + a = 0 := !add_group.add_left_inv

  theorem neg_add_cancel_left [simp] (a b : A) : -a + (a + b) = b :=
  calc -a + (a + b) = (-a + a) + b : by rewrite add.assoc
               ...  = b            : by simp

  theorem neg_add_cancel_right [simp] (a b : A) : a + -b + b = a :=
  by inst_simp

  theorem neg_eq_of_add_eq_zero {a b : A} (H : a + b = 0) : -a = b :=
  assert -a + 0 = b, by inst_simp,
  by inst_simp

  theorem neg_zero [simp] : -0 = (0 : A) := neg_eq_of_add_eq_zero (zero_add 0)

  theorem neg_neg [simp] (a : A) : -(-a) = a := neg_eq_of_add_eq_zero (add.left_inv a)

  theorem eq_neg_of_add_eq_zero {a b : A} (H : a + b = 0) : a = -b :=
  assert -a = b, from neg_eq_of_add_eq_zero H,
  by inst_simp

  theorem neg.inj {a b : A} (H : -a = -b) : a = b :=
  assert a = -(-a), by simp_nohyps,
  by inst_simp

  theorem neg_eq_neg_iff_eq (a b : A) : -a = -b ↔ a = b :=
  iff.intro (assume H, neg.inj H) (by simp)

  theorem eq_of_neg_eq_neg {a b : A} : -a = -b → a = b :=
  iff.mp !neg_eq_neg_iff_eq

  theorem neg_eq_zero_iff_eq_zero (a : A) : -a = 0 ↔ a = 0 :=
  assert -a = -0 ↔ a = 0, from neg_eq_neg_iff_eq a 0,
  by inst_simp

  theorem eq_zero_of_neg_eq_zero {a : A} : -a = 0 → a = 0 :=
  iff.mp !neg_eq_zero_iff_eq_zero

  theorem eq_neg_of_eq_neg {a b : A} (H : a = -b) : b = -a :=
  by inst_simp

  theorem eq_neg_iff_eq_neg (a b : A) : a = -b ↔ b = -a :=
  iff.intro !eq_neg_of_eq_neg !eq_neg_of_eq_neg

  theorem add.right_inv [simp] (a : A) : a + -a = 0 :=
  assert a = -(-a), by simp,
  by inst_simp

  theorem add_neg_cancel_left [simp] (a b : A) : a + (-a + b) = b :=
  by inst_simp

  theorem add_neg_cancel_right [simp] (a b : A) : a + b + -b = a :=
  by inst_simp

  theorem neg_add_rev [simp] (a b : A) : -(a + b) = -b + -a :=
  neg_eq_of_add_eq_zero (by inst_simp)

  -- TODO: delete these in favor of sub rules?
  theorem eq_add_neg_of_add_eq {a b c : A} (H : a + c = b) : a = b + -c :=
  by inst_simp

  theorem eq_neg_add_of_add_eq {a b c : A} (H : b + a = c) : a = -b + c :=
  by inst_simp

  theorem neg_add_eq_of_eq_add {a b c : A} (H : b = a + c) : -a + b = c :=
  by inst_simp

  theorem add_neg_eq_of_eq_add {a b c : A} (H : a = c + b) : a + -b = c :=
  by inst_simp

  theorem eq_add_of_add_neg_eq {a b c : A} (H : a + -c = b) : a = b + c :=
  by inst_simp

  theorem eq_add_of_neg_add_eq {a b c : A} (H : -b + a = c) : a = b + c :=
  by inst_simp

  theorem add_eq_of_eq_neg_add {a b c : A} (H : b = -a + c) : a + b = c :=
  by inst_simp

  theorem add_eq_of_eq_add_neg {a b c : A} (H : a = c + -b) : a + b = c :=
  by inst_simp

  theorem add_eq_iff_eq_neg_add (a b c : A) : a + b = c ↔ b = -a + c :=
  iff.intro eq_neg_add_of_add_eq add_eq_of_eq_neg_add

  theorem add_eq_iff_eq_add_neg (a b c : A) : a + b = c ↔ a = c + -b :=
  iff.intro eq_add_neg_of_add_eq add_eq_of_eq_add_neg

  theorem add_left_cancel {a b c : A} (H : a + b = a + c) : b = c :=
  assert -a + (a + b) = b, by inst_simp,
  by inst_simp

  theorem add_right_cancel {a b c : A} (H : a + b = c + b) : a = c :=
  assert a + b + -b = a, by inst_simp,
  by inst_simp

  definition add_group.to_left_cancel_semigroup [trans_instance] [reducible] :
    add_left_cancel_semigroup A :=
  ⦃ add_left_cancel_semigroup, s,
    add_left_cancel := @add_left_cancel A s ⦄

  definition add_group.to_add_right_cancel_semigroup [trans_instance] [reducible] :
    add_right_cancel_semigroup A :=
  ⦃ add_right_cancel_semigroup, s,
    add_right_cancel := @add_right_cancel A s ⦄

  theorem add_neg_eq_neg_add_rev {a b : A} : a + -b = -(b + -a) :=
  by inst_simp

  theorem ne_add_of_ne_zero_right (a : A) {b : A} (H : b ≠ 0) : a ≠ b + a :=
    begin
      intro Heq,
      apply H,
      rewrite [-zero_add a at Heq{1}],
      let Heq' := eq_of_add_eq_add_right Heq,
      apply eq.symm Heq'
    end

  theorem ne_add_of_ne_zero_left (a : A) {b : A} (H : b ≠ 0) : a ≠ a + b :=
    begin
      intro Heq,
      apply H,
      rewrite [-add_zero a at Heq{1}],
      let Heq' := eq_of_add_eq_add_left Heq,
      apply eq.symm Heq'
    end

  /- sub -/

  -- TODO: derive corresponding facts for div in a field
  protected definition algebra.sub [reducible] (a b : A) : A := a + -b

  definition add_group_has_sub [reducible] [instance] : has_sub A :=
  has_sub.mk algebra.sub

  theorem sub_eq_add_neg [simp] (a b : A) : a - b = a + -b := rfl

  theorem sub_self (a : A) : a - a = 0 := !add.right_inv

  theorem sub_add_cancel (a b : A) : a - b + b = a := !neg_add_cancel_right

  theorem add_sub_cancel (a b : A) : a + b - b = a := !add_neg_cancel_right

  theorem add_sub_assoc (a b c : A) : a + b - c = a + (b - c) :=
    by rewrite [sub_eq_add_neg, add.assoc, -sub_eq_add_neg]

  theorem eq_of_sub_eq_zero {a b : A} (H : a - b = 0) : a = b :=
  assert -a + 0 = -a, by inst_simp,
  by inst_simp

  theorem eq_iff_sub_eq_zero (a b : A) : a = b ↔ a - b = 0 :=
  iff.intro (assume H, eq.subst H !sub_self) (assume H, eq_of_sub_eq_zero H)

  theorem zero_sub (a : A) : 0 - a = -a := !zero_add

  theorem sub_zero (a : A) : a - 0 = a :=
  by inst_simp

  theorem sub_ne_zero_of_ne {a b : A} (H : a ≠ b) : a - b ≠ 0 :=
    begin
      intro Hab,
      apply H,
      apply eq_of_sub_eq_zero Hab
    end

  theorem sub_neg_eq_add (a b : A) : a - (-b) = a + b :=
  by inst_simp

  theorem neg_sub (a b : A) : -(a - b) = b - a :=
  neg_eq_of_add_eq_zero (by inst_simp)

  theorem add_sub (a b c : A) : a + (b - c) = a + b - c :=
  by inst_simp

  theorem sub_add_eq_sub_sub_swap (a b c : A) : a - (b + c) = a - c - b :=
  by inst_simp

  theorem sub_eq_iff_eq_add (a b c : A) : a - b = c ↔ a = c + b :=
  iff.intro (assume H, eq_add_of_add_neg_eq H) (assume H, add_neg_eq_of_eq_add H)

  theorem eq_sub_iff_add_eq (a b c : A) : a = b - c ↔ a + c = b :=
  iff.intro (assume H, add_eq_of_eq_add_neg H) (assume H, eq_add_neg_of_add_eq H)

  theorem eq_iff_eq_of_sub_eq_sub {a b c d : A} (H : a - b = c - d) : a = b ↔ c = d :=
  calc
    a = b ↔ a - b = 0   : eq_iff_sub_eq_zero
      ... = (c - d = 0) : H
      ... ↔ c = d       : iff.symm (eq_iff_sub_eq_zero c d)

  theorem eq_sub_of_add_eq {a b c : A} (H : a + c = b) : a = b - c :=
  by inst_simp

  theorem sub_eq_of_eq_add {a b c : A} (H : a = c + b) : a - b = c :=
  by inst_simp

  theorem eq_add_of_sub_eq {a b c : A} (H : a - c = b) : a = b + c :=
  by inst_simp

  theorem add_eq_of_eq_sub {a b c : A} (H : a = c - b) : a + b = c :=
  by inst_simp

end add_group

structure add_comm_group [class] (A : Type) extends add_group A, add_comm_monoid A

section add_comm_group
  variable [s : add_comm_group A]
  include s

  theorem sub_add_eq_sub_sub (a b c : A) : a - (b + c) = a - b - c :=
  by inst_simp

  theorem neg_add_eq_sub (a b : A) : -a + b = b - a :=
  by inst_simp

  theorem neg_add (a b : A) : -(a + b) = -a + -b :=
  by inst_simp

  theorem sub_add_eq_add_sub (a b c : A) : a - b + c = a + c - b :=
  by inst_simp

  theorem sub_sub (a b c : A) : a - b - c = a - (b + c) :=
  by inst_simp

  theorem add_sub_add_left_eq_sub (a b c : A) : (c + a) - (c + b) = a - b :=
  by inst_simp

  theorem eq_sub_of_add_eq' {a b c : A} (H : c + a = b) : a = b - c :=
  by inst_simp

  theorem sub_eq_of_eq_add' {a b c : A} (H : a = b + c) : a - b = c :=
  by inst_simp

  theorem eq_add_of_sub_eq' {a b c : A} (H : a - b = c) : a = b + c :=
  by inst_simp

  theorem add_eq_of_eq_sub' {a b c : A} (H : b = c - a) : a + b = c :=
  by inst_simp

  theorem sub_sub_self (a b : A) : a - (a - b) = b :=
  by inst_simp

  theorem add_sub_comm (a b c d : A) : a + b - (c + d) = (a - c) + (b - d) :=
  by inst_simp

  theorem sub_eq_sub_add_sub (a b c : A) : a - b = c - b + (a - c) :=
  by inst_simp

  theorem neg_neg_sub_neg (a b : A) : - (-a - -b) = a - b :=
  by inst_simp

end add_comm_group

definition group_of_add_group (A : Type) [G : add_group A] : group A :=
⦃group,
  mul             := has_add.add,
  mul_assoc       := add.assoc,
  one             := !has_zero.zero,
  one_mul         := zero_add,
  mul_one         := add_zero,
  inv             := has_neg.neg,
  mul_left_inv    := add.left_inv⦄

namespace norm_num
reveal add.assoc

definition add1 [has_add A] [has_one A] (a : A) : A := add a one

local attribute add1 bit0 bit1 [reducible]

theorem add_comm_four [add_comm_semigroup A] (a b : A) : a + a + (b + b) = (a + b) + (a + b) :=
by inst_simp

theorem add_comm_middle [add_comm_semigroup A] (a b c : A) : a + b + c = a + c + b :=
by inst_simp

theorem bit0_add_bit0 [add_comm_semigroup A] (a b : A) : bit0 a + bit0 b = bit0 (a + b) :=
by inst_simp

theorem bit0_add_bit0_helper [add_comm_semigroup A] (a b t : A) (H : a + b = t) :
        bit0 a + bit0 b = bit0 t :=
by rewrite -H; simp

theorem bit1_add_bit0 [add_comm_semigroup A] [has_one A] (a b : A) :
        bit1 a + bit0 b = bit1 (a + b) :=
by inst_simp

theorem bit1_add_bit0_helper [add_comm_semigroup A] [has_one A] (a b t : A)
        (H : a + b = t) : bit1 a + bit0 b = bit1 t :=
by rewrite -H; simp

theorem bit0_add_bit1 [add_comm_semigroup A] [has_one A] (a b : A) :
        bit0 a + bit1 b = bit1 (a + b) :=
by inst_simp

theorem bit0_add_bit1_helper [add_comm_semigroup A] [has_one A] (a b t : A)
        (H : a + b = t) : bit0 a + bit1 b = bit1 t :=
by rewrite -H; simp

theorem bit1_add_bit1 [add_comm_semigroup A] [has_one A] (a b : A) :
        bit1 a + bit1 b = bit0 (add1 (a + b)) :=
by inst_simp

theorem bit1_add_bit1_helper [add_comm_semigroup A] [has_one A] (a b t s: A)
        (H : (a + b) = t) (H2 : add1 t = s) : bit1 a + bit1 b = bit0 s :=
by inst_simp

theorem bin_add_zero [add_monoid A] (a : A) : a + zero = a :=
by inst_simp

theorem bin_zero_add [add_monoid A] (a : A) : zero + a = a :=
by inst_simp

theorem one_add_bit0 [add_comm_semigroup A] [has_one A] (a : A) : one + bit0 a = bit1 a :=
by inst_simp

theorem bit0_add_one [has_add A] [has_one A] (a : A) : bit0 a + one = bit1 a :=
rfl

theorem bit1_add_one [has_add A] [has_one A] (a : A) : bit1 a + one = add1 (bit1 a) :=
rfl

theorem bit1_add_one_helper [has_add A] [has_one A] (a t : A) (H : add1 (bit1 a) = t) :
        bit1 a + one = t :=
by inst_simp

theorem one_add_bit1 [add_comm_semigroup A] [has_one A] (a : A) : one + bit1 a = add1 (bit1 a) :=
by inst_simp

theorem one_add_bit1_helper [add_comm_semigroup A] [has_one A] (a t : A)
        (H : add1 (bit1 a) = t) : one + bit1 a = t :=
by inst_simp

theorem add1_bit0 [has_add A] [has_one A] (a : A) : add1 (bit0 a) = bit1 a :=
rfl

theorem add1_bit1 [add_comm_semigroup A] [has_one A] (a : A) :
        add1 (bit1 a) = bit0 (add1 a) :=
by inst_simp

theorem add1_bit1_helper [add_comm_semigroup A] [has_one A] (a t : A) (H : add1 a = t) :
        add1 (bit1 a) = bit0 t :=
by inst_simp

theorem add1_one [has_add A] [has_one A] : add1 (one : A) = bit0 one :=
rfl

theorem add1_zero [add_monoid A] [has_one A] : add1 (zero : A) = one :=
by inst_simp

theorem one_add_one [has_add A] [has_one A] : (one : A) + one = bit0 one :=
rfl

theorem subst_into_sum [has_add A] (l r tl tr t : A) (prl : l = tl) (prr : r = tr)
        (prt : tl + tr = t) : l + r = t :=
by inst_simp

theorem neg_zero_helper [add_group A] (a : A) (H : a = 0) : - a = 0 :=
by inst_simp

end norm_num

attribute [simp]
  zero_add add_zero one_mul mul_one
  at simplifier.unit

attribute [simp]
  neg_neg sub_eq_add_neg
  at simplifier.neg

attribute [simp]
  add.assoc add.comm add.left_comm
  mul.left_comm mul.comm mul.assoc
  at simplifier.ac
  
import data.real
open real

namespace example2

/- Assume we have an exp (exponential) function, and state basic properties using axioms. -/
constant exp : ℝ → ℝ
/- The annotation (: t :) is used to indicate that `t` is a pattern for the E-matching procedure. -/
axiom exp_add : ∀ x y : ℝ, (: exp (x + y) :) = exp x * exp y
/- The [forward] attribute instructs lean to use the following axioms for E-matching. -/
attribute [forward] exp_add

/- Define t² as notation for t*t -/
definition sq (x : ℝ) := x * x
notation a `²` := sq a
/- (sq x) and (x * x) are equal by definition, and we can prove it using reflexivity. -/
lemma sq_def [forward] : ∀ x : ℝ, sq x = x * x :=
  take x, rfl
lemma sq_add [forward] : ∀ x y : ℝ, sq (x + y) = (: sq x + 2 * x * y + sq y :) :=
  take x y, by unfold sq; rewrite add_mul_self_eq

/- Define predicate pos and state basic properties using axioms. -/
definition pos (x : ℝ) := x > 0
axiom pos_1    : pos (1:ℝ)
axiom pos_bit1 : ∀ x : ℝ,   pos x → pos (bit1 x)
axiom pos_bit0 : ∀ x : ℝ,   pos x → pos (bit0 x)
axiom pos_sq   : ∀ x : ℝ,   pos x → pos (sq x)
axiom pos_add  : ∀ x y : ℝ, pos x → pos y → (: pos (x + y) :)
axiom pos_mul  : ∀ x y : ℝ, pos x → pos y → (: pos (x * y) :)
axiom pos_exp  : ∀ x : ℝ,   pos (exp x)

/- The [intro!] attribute instructs lean to use the following axioms for backward chaining. -/
attribute [intro!]  pos_bit1 pos_bit0 pos_1 pos_add pos_mul pos_sq pos_exp
attribute [forward] pos_add pos_mul

/- Define predicate nzero and state basic properties using axioms. -/
definition nzero (x : ℝ) := x ≠ 0
axiom nzero_of_pos : ∀ x : ℝ, pos x → nzero x
axiom nzero_of_neg : ∀ x : ℝ, pos x → nzero (- x)

attribute [intro!] nzero_of_pos nzero_of_neg

/- Assume we have safe_log and safe_inv functions. -/
constant safe_log : Π (x : ℝ), pos x → ℝ
constant safe_inv : Π (x : ℝ), nzero x → ℝ

/-
Define notation (log x), (x ⁻¹) and (x / y) for safe_log and safe_inv.
We discharge the preconditions pos and nzero using tactics.
The grind tactic is based on backward chaining, and uses all axioms/lemmas
marked with the `[intro!]` attribute.
-/
notation `log`:max x:max := (@safe_log x (by grind))
/-
  We use priority greater than the default to avoid a conflict with existing
  notation defined in Lean.
-/
notation [priority std.priority.default+1] x ⁻¹ := (@safe_inv x (by grind))
notation [priority std.priority.default+1] x `/` y := (@safe_inv y (by grind) * x)

/- Assume basic properties about safe_inf and safe_log as axioms -/

axiom inv_pos         : ∀ x : ℝ,   pos x → pos (x⁻¹)
axiom inv_mul         : ∀ x y : ℝ, pos x → pos y →  (x * y)⁻¹ = (x⁻¹) * (y⁻¹)
axiom inv_cancel_left : ∀ x y : ℝ, pos x →  x⁻¹ * (x * y) = y
axiom inv_neg         : ∀ x : ℝ,   pos x →  (- x)⁻¹ = - (x⁻¹)

attribute [intro!] inv_pos
attribute [forward] inv_pos inv_mul inv_cancel_left inv_neg

axiom log_mul : ∀ x y : ℝ, pos x → pos y → log (x * y) = log x + log y
axiom log_sq  : ∀ x : ℝ,   pos x → log (sq x) = 2 * log x
axiom log_inv : ∀ x : ℝ,   pos x → log (x⁻¹)  = - log x

attribute [forward] log_mul log_sq log_inv

/- To prove the main lemma, we also need the following basic properties from the standard library. -/
lemma rdistrib [forward]    : ∀ x y z : ℝ, (x + y) * z = x * z + y * z   :=
  right_distrib
lemma addcomm [forward]     : ∀ x y : ℝ, x + y = y + x                   :=
  add.comm
lemma sub_def [forward]     : ∀ x y : ℝ, x - y = x + -y                  :=
  take x y, rfl
lemma mul_two_sum [forward] : ∀ x : ℝ, (: 2 * x :) = x + x               :=
  take x, show (1 + 1) * x = x + x,
  by rewrite [rdistrib, one_mul]
lemma neg_mul [forward]     : ∀ x y : ℝ, (: (- x) * y :) = - (x * y)     :=
  take x y, by rewrite neg_mul_eq_neg_mul

set_option blast.strategy "ematch"

example : ∀ x y z w : ℝ, pos x → pos y → pos z → pos w → x * y = exp z + w →
          log (2 * w * exp z + w² + exp (2*z)) / -2 = log (y⁻¹) - log x :=
begin
  have pos 2, by grind, /- Discharge auxiliary fact using backward chaining. -/
  blast                 /- Use congruence closure and ematching to prove main goal. -/
end

end example2

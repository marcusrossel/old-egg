import EggTactic
-- Rewrites that force a counter to count upward.


inductive N where  -- unary encoding of natural numbers
| Z : N
| S : N -> N

inductive B where -- bit
| O : B
| I : B

open N
open B

axiom BinNum : Type
axiom BinNum.get: BinNum -> N -> B -- get Nth bit
axiom counter: N -> BinNum  -- counter value at nth step

axiom counter_begin (ix: N): (counter Z).get ix = O

-- 0 0 0 -> 0 0 1
axiom axiom_000_SSn (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = O) (Xn: (counter n).get i = O):
    (counter (S n)).get (S (S i)) = O
axiom axiom_000_Sn (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = O) (Xn: (counter n).get i = O):
    (counter (S n)).get (S i) = O
axiom axiom_000_n (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = O) (Xn: (counter n).get i = O):
    (counter (S n)).get i = I

-- 0 0 1 -> 0  1  0
--         Ssn Sn n
axiom axiom_001_SSn (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = O) (Xn: (counter n).get i = I):
    (counter (S n)).get (S (S i)) = O
axiom axiom_001_Sn (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = O) (Xn: (counter n).get i = I):
    (counter (S n)).get (S i) = I
axiom axiom_001_n (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = O) (Xn: (counter n).get i = I):
    (counter (S n)).get i = O

-- 0 1 0 ->0   1  1
--         Ssn Sn n
axiom axiom_010_SSn (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = I) (Xn: (counter n).get i = O):
    (counter (S n)).get (S (S i)) = O
axiom axiom_010_Sn (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = I) (Xn: (counter n).get i = O):
    (counter (S n)).get (S i) = I
axiom axiom_010_n (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = I) (Xn: (counter n).get i = O):

-- 0 1 1 -> 1 0 0
axiom axiom_011_SSn (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = I) (Xn: (counter n).get i = O):
    (counter (S n)).get (S (S i)) = I
axiom axiom_011_Sn (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = I) (Xn: (counter n).get i = O):
    (counter (S n)).get (S i) = O
axiom axiom_011_n (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = I) (Xn: (counter n).get i = O):
    (counter (S n)).get i = O
  
abbrev one : N := S Z
abbrev two : N := S one
abbrev three : N := S two
abbrev four : N := S three
abbrev five : N := S four
abbrev six: N := S five
abbrev seven : N := S six

/-
#print seven
theorem count_upward_7_at_0: (counter seven).get Z = I := by {
  rawEgg [axiom_000_SSn, axiom_000_Sn, axiom_000_n
  , axiom_001_SSn, axiom_001_Sn, axiom_001_n
  , axiom_010_SSn, axiom_010_Sn, axiom_010_n
  , axiom_011_SSn, axiom_011_Sn, axiom_011_n]
  sorry
-/

def foo
  (x: Int)
  (y: Nat): True := sorry

def count_upward_7_at_0'
  -- 0 0 0 -> 0 0 1
  (axiom_000_SSn: forall (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = O) (Xn: (counter n).get i = O), (counter (S n)).get (S (S i)) = O)
  (axiom_000_Sn: forall (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = O) (Xn: (counter n).get i = O), (counter (S n)).get (S i) = O)
  (axiom_000_n: forall (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = O) (Xn: (counter n).get i = O), (counter (S n)).get i = I)
  -- 0 0 1 -> 0  1  0
  --         Ssn Sn n
  (axiom_001_SSn: forall (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = O) (Xn: (counter n).get i = I), (counter (S n)).get (S (S i)) = O)
  (axiom_001_Sn: forall (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = O) (Xn: (counter n).get i = I), (counter (S n)).get (S i) = I)
  (axiom_001_n: forall (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = O) (Xn: (counter n).get i = I), (counter (S n)).get i = O)
  -- 0 1 0 ->0   1  1
  --         Ssn Sn n
  (axiom_010_SSn: forall (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = I) (Xn: (counter n).get i = O), (counter (S n)).get (S (S i)) = O)
  (axiom_010_Sn: forall (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = I) (Xn: (counter n).get i = O), (counter (S n)).get (S i) = I)
  (axiom_010_n: forall (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = I) (Xn: (counter n).get i = O), (counter (S n)).get i = I)
  -- 0 1 1 -> 1 0 0
  (axiom_011_SSn: forall (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = I) (Xn: (counter n).get i = O), (counter (S n)).get (S (S i)) = I)
  (axiom_011_Sn: forall (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = I) (Xn: (counter n).get i = O), (counter (S n)).get (S i) = O)
  (axiom_011_n: forall (n: N) (i: N) (Xssn: (counter n).get (S (S i)) = O)  (Xsn: (counter n).get (S i) = I) (Xn: (counter n).get i = O), (counter (S n)).get i = O): 
   (counter seven).get Z = I := by {
    rawEgg [axiom_000_SSn, axiom_000_Sn, axiom_000_n
      , axiom_001_SSn, axiom_001_Sn, axiom_001_n
      , axiom_010_SSn, axiom_010_Sn, axiom_010_n
    , axiom_011_SSn, axiom_011_Sn, axiom_011_n];
    
  }

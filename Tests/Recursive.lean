import EggTactic

-- This case shows up in the proof of `List.zip_map'` in Batteries.

theorem t : a = b := by
  egg [t]

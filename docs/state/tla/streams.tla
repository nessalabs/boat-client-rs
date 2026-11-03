---- MODULE StreamDrain ----
EXTENDS Naturals, FiniteSets
VARIABLES pending, pages, more, terminal, done
vars == <<pending, pages, more, terminal, done>>
Init == /\ pending = 0 /\ pages = 0 /\ more = TRUE /\ terminal = FALSE /\ done = FALSE
Fetch == /\ ~done /\ pending = 0 /\ more /\ pages < 2 /\ pages' = pages+1 /\ pending' = 2 /\ more' = (pages+1 < 2) /\ UNCHANGED <<terminal,done>>
Yield == /\ ~done /\ pending > 0 /\ pending' = pending-1 /\ UNCHANGED <<pages,more,terminal,done>>
Terminal == /\ ~done /\ terminal' = TRUE /\ UNCHANGED <<pending,pages,more,done>>
Finish == /\ ~done /\ terminal /\ pending = 0 /\ ~more /\ done' = TRUE /\ UNCHANGED <<pending,pages,more,terminal>>
Next == Fetch \/ Yield \/ Terminal \/ Finish
Spec == Init /\ [][Next]_vars
BufferDrained == done => pending = 0
KnownPagesDrained == done => ~more
====

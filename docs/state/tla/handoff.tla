---- MODULE HandoffAdmission ----
EXTENDS Naturals, FiniteSets
VARIABLES revision, begun, acted
vars == <<revision, begun, acted>>
Init == /\ revision = 0 /\ begun = {} /\ acted = {}
Begin == \E p \in {1,2}: /\ p \notin begun /\ revision = 0 /\ begun' = begun \cup {p} /\ revision' = revision+1 /\ UNCHANGED acted
Act == \E p \in {1,2}: /\ p \notin acted /\ p \in begun /\ acted' = acted \cup {p} /\ UNCHANGED <<revision,begun>>
Next == Begin \/ Act
Spec == Init /\ [][Next]_vars
SingleWinner == Cardinality(begun) <= 1
ActionAfterIntent == acted \subseteq begun
====

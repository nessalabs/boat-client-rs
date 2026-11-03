---- MODULE DeletionWait ----
EXTENDS Naturals, FiniteSets
VARIABLES status, hidden, done, accepted
vars == <<status, hidden, done, accepted>>
Init == /\ status = "pending" /\ hidden = FALSE /\ done = FALSE /\ accepted = "none"
Observe == /\ ~done /\ status' \in {"pending","blocked","completed"} /\ hidden' \in BOOLEAN /\ UNCHANGED <<done,accepted>>
Complete == /\ ~done /\ status = "completed" /\ done' = TRUE /\ accepted' = status /\ UNCHANGED <<status,hidden>>
Next == Observe \/ Complete
Spec == Init /\ [][Next]_vars
OnlyCompleted == done => accepted = "completed"
====

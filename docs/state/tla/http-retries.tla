---- MODULE HttpRetries ----
EXTENDS Naturals, FiniteSets
VARIABLES method, attempts, transient, phase
vars == <<method, attempts, transient, phase>>
Init == /\ method \in {"GET","POST"} /\ attempts = 1 /\ transient \in BOOLEAN /\ phase = "FailedAttempt"
Retry == /\ phase = "FailedAttempt" /\ method = "GET" /\ transient /\ attempts < 3 /\ attempts' = attempts+1 /\ UNCHANGED <<method, transient, phase>>
End == /\ phase = "FailedAttempt" /\ phase' = "Settled" /\ UNCHANGED <<method, attempts, transient>>
Next == Retry \/ End
Spec == Init /\ [][Next]_vars
MutationOnce == method = "POST" => attempts = 1
AttemptBound == attempts <= 3
====

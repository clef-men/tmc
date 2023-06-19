From simuliris Require Import
  prelude.
From simuliris.language Require Export
  refinement.
From simuliris.language Require Import
  notations.
From simuliris.tmc Require Import
  soundness.

Definition list_mapₛ : program := {[
  "list_map" := (
    match: ![𝟚] $0 with
      NIL =>
        NIL
    | CONS =>
        let: ![𝟙] $2 in
        let: $0 $1 in
        CONS $0 ("list_map" ($1, $3))
    end
  )%E
]}.

Definition list_mapₜ : program := {[
  "list_map" := (
    match: ![𝟚] $0 with
      NIL =>
        NIL
    | CONS =>
        let: ![𝟙] $2 in
        let: $0 $1 in
        let: CONS $0 #() in
        ( let: ($2, $4) in
          "list_map_dps" (($1, 𝟚), $0)
        ) ;;
        $0
    end
  )%E ;
  "list_map_dps" := (
    let: ![𝟙] $0 in
    let: ![𝟚] $0 in
    let: ![𝟙] $1 in
    let: ![𝟚] $3 in
    match: ![𝟚] $0 with
      NIL =>
        $1 <-[$2]- NIL
    | CONS =>
        let: ![𝟙] $2 in
        let: $0 $1 in
        let: CONS $0 #() in
        $8 <-[$9]- $0 ;;
        let: ($2, $4) in
        "list_map_dps" (($1, 𝟚), $0)
    end
  )%E
]}.

Lemma list_map_well_formed :
  program_well_formed list_mapₛ.
Proof.
  apply map_Forall_singleton. naive_solver lia.
Qed.

Lemma list_map_tmc :
  tmc list_mapₛ list_mapₜ.
Proof.
  exists {["list_map" := "list_map_dps"]}.
  - apply map_Forall_singleton. done.
  - intros * (<- & <-)%lookup_singleton_Some (<- & _)%lookup_singleton_Some. done.
  - rewrite /list_mapₛ /list_mapₜ.
    intros * (<- & <-)%lookup_singleton_Some.
    eexists. split; first done. repeat econstructor.
  - rewrite /list_mapₛ /list_mapₜ.
    intros * (<- & <-)%lookup_singleton_Some (_ & <-)%lookup_singleton_Some.
    eexists. split; first done.
    do 6 constructor; [repeat constructor.. |].
    eapply tmc_dps_constr_1; first repeat constructor.
    + asimpl. eapply tmc_dps_call; repeat constructor.
    + done.
Qed.

Lemma list_map_sound :
  program_refinement list_mapₛ list_mapₜ.
Proof.
  apply tmc_sound, list_map_tmc. apply list_map_well_formed.
Qed.

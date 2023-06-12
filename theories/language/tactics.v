From simuliris Require Import
  prelude.
From simuliris.common Require Import
  tactics.
From simuliris.language Require Export
  language.
From simuliris.language Require Import
  ectx_decompositions.

Create HintDb language.

#[global] Hint Extern 0 (
  head_reducible _ _ _
) => (
  eexists _, _; simpl
) : language.
#[global] Hint Extern 1 (
  head_step _ _ _ _ _
) => (
  econstructor
) : language.
#[global] Hint Extern 1 (
  ectx_language.head_step _ _ _ _ _
) => (
  econstructor
) : language.
#[global] Hint Extern 0 (
  head_step _ (ConstrDet _ _ _) _ _ _
) => (
  eapply head_step_constr_det'
) : language.
#[global] Hint Extern 0 (
  ectx_language.head_step _ (ConstrDet _ _ _) _ _ _
) => (
  eapply head_step_constr_det'
) : language.

#[global] Hint Extern 1 (
  sub_redexes_are_values _
) => (
  let Hdecomps := fresh "Hdecomps" in
  intros ?* Hdecomps%ectx_decompositions_spec; invert Hdecomps; first done;
    decompose_elem_of_list; simplify
) : language.

Tactic Notation "invert_well_formed" "as" simple_intropattern(pat) :=
  repeat_on_hyps ltac:(fun H =>
    match type of H with
    | expr_well_formed _ _ _ =>
        invert H as pat; simplify
    | val_well_formed _ ?v =>
        solve [by destruct v]
    end
  );
  try done.
Tactic Notation "invert_well_formed" :=
  invert_well_formed as [].
#[global] Hint Extern 0 => (
  solve [invert_well_formed]
) : language.
#[global] Hint Extern 1 (
  expr_well_formed _ _ _
) => (
  progress invert_well_formed
) : language.

Tactic Notation "invert_head_step" "as" simple_intropattern(pat) :=
  repeat_on_hyps ltac:(fun H =>
    let ty := type of H in
    let ty := eval simpl in ty in
    match ty with head_step _ ?e _ _ _ =>
      try (is_var e; fail 1);
      invert H as pat
    end
  ).
Tactic Notation "invert_head_step" :=
  invert_head_step as [].

#[local] Ltac solve_strongly_head_stuck :=
  intros ?; split;
  [ intros ?** ?** ?; invert_head_step; done
  | auto with language
  ].
#[global] Instance strongly_head_stuck_call prog v1 v2 :
  (if v1 is Func _ then False else True) →
  IsStronglyHeadStuck prog (Call (Val v1) (Val v2)).
Proof.
  solve_strongly_head_stuck.
Qed.
#[global] Instance strongly_head_stuck_load prog v :
  (if v is Loc _ then False else True) →
  IsStronglyHeadStuck prog (Load (Val v)).
Proof.
  solve_strongly_head_stuck.
Qed.
#[global] Instance strongly_head_stuck_store prog v1 v2 :
  (if v1 is Loc _ then False else True) →
  IsStronglyHeadStuck prog (Store (Val v1) (Val v2)).
Proof.
  solve_strongly_head_stuck.
Qed.

#[local] Ltac solve_pure_exec :=
  apply pure_head_exec_pure_exec;
  intros ?; apply nsteps_once; constructor;
  [ auto with language
  | intros; invert_head_step; auto
  ].
#[global] Instance pure_exec_let prog v e :
  PureExec prog True 1 (Let (Val v) e) e.[Val v/].
Proof.
  solve_pure_exec.
Qed.
#[global] Instance pure_exec_call prog func v e :
  PureExec prog (prog !! func = Some e) 1 (Call (Val (Func func)) (Val v)) e.[Val v/].
Proof.
  solve_pure_exec.
Qed.
#[global] Instance pure_exec_unop prog op v w :
  PureExec prog (unop_eval op v = Some w) 1 (Unop op (Val v)) (Val w).
Proof.
  solve_pure_exec.
Qed.
#[global] Instance pure_exec_binop prog op v1 v2 w :
  PureExec prog (binop_eval op v1 v2 = Some w) 1 (Binop op (Val v1) (Val v2)) (Val w).
Proof.
  solve_pure_exec.
Qed.
#[global] Instance pure_exec_if_true prog e1 e2 :
  PureExec prog True 1 (If (Val (Bool true)) e1 e2) e1.
Proof.
  solve_pure_exec.
Qed.
#[global] Instance pure_exec_if_false prog e1 e2 :
  PureExec prog True 1 (If (Val (Bool false)) e1 e2) e2.
Proof.
  solve_pure_exec.
Qed.

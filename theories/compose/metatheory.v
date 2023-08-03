From simuliris Require Import
  prelude.
From simuliris.data_lang Require Export
  metatheory.
From simuliris.compose Require Export
  definition.

Section compose_expr.
  Context (func1 func2 func : data_function).

  Lemma compose_expr_dir_refl e :
    compose_expr_dir func1 func2 func e e.
  Proof.
    induction e; auto with compose.
  Qed.

  Lemma compose_expr_dir_subst ς eₛ eₛ' eₜ eₜ' :
    compose_expr_dir func1 func2 func eₛ eₜ →
    eₛ' = eₛ.[ς] →
    eₜ' = eₜ.[ς] →
    compose_expr_dir func1 func2 func eₛ' eₜ'.
  Proof.
    intros Hdir. revert ς eₛ' eₜ'. induction Hdir; intros ς eₛ' eₜ' -> ->;
      eauto using compose_expr_dir_refl with compose.
  Qed.
  Lemma compose_expr_comp_subst ς eₛ eₛ' eₜ eₜ' :
    compose_expr_comp func1 func2 func eₛ eₜ →
    eₛ' = eₛ.[ς] →
    eₜ' = eₜ.[ς] →
    compose_expr_comp func1 func2 func eₛ' eₜ'.
  Proof.
    intros Hcomp. revert ς eₛ' eₜ'. induction Hcomp; intros ς eₛ' eₜ' -> ->;
      eauto using compose_expr_dir_subst with compose.
  Qed.

  Lemma data_expr_scoped_compose_expr_dir scope eₛ eₜ :
    compose_expr_dir func1 func2 func eₛ eₜ →
    data_expr_scoped scope eₛ →
    data_expr_scoped scope eₜ.
  Proof.
    intros Hdir. revert scope. induction Hdir; intros scope;
      naive_solver.
  Qed.
  Lemma data_expr_scoped_compose_expr_comp scope eₛ eₜ :
    compose_expr_comp func1 func2 func eₛ eₜ →
    data_expr_scoped scope eₛ →
    data_expr_scoped scope eₜ.
  Proof.
    intros Hcomp. revert scope. induction Hcomp; intros scope;
      naive_solver eauto using data_expr_scoped_compose_expr_dir.
  Qed.
End compose_expr.

#[global] Hint Resolve compose_expr_dir_refl : compose.

Lemma data_program_scoped_compose progₛ progₜ func1 func2 :
  compose progₛ progₜ func1 func2 →
  data_program_scoped progₛ →
  data_program_scoped progₜ.
Proof.
  intros compose. rewrite /data_program_scoped !map_Forall_lookup => Hscoped func defₜ Hfuncₜ.
  apply elem_of_dom_2 in Hfuncₜ as Hfuncₜ'. rewrite compose.(compose_dom) elem_of_union in Hfuncₜ'.
  destruct Hfuncₜ' as [Hfuncₛ%lookup_lookup_total_dom | ->%elem_of_singleton].
  - edestruct compose.(compose_dir) as (eₜ & Hdir & Heq); first done.
    eapply data_expr_scoped_compose_expr_dir; last naive_solver.
    rewrite Heq in Hfuncₜ. naive_solver.
  - edestruct compose.(compose_comp) as (defₛ & eₜ & Hfunc1ₛ & Hcomp & Heq).
    rewrite Hfuncₜ in Heq. simplify.
    eapply data_expr_scoped_compose_expr_comp; naive_solver.
Qed.

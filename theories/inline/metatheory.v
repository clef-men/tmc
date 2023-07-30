From simuliris Require Import
  prelude.
From simuliris.common Require Import
  tactics.
From simuliris.data_lang Require Export
  metatheory.
From simuliris.inline Require Export
  definition.

Section inline.
  Context (prog : data_program).

  Lemma inline_expr_refl e :
    inline_expr prog e e.
  Proof.
    induction e; eauto with inline.
  Qed.

  Lemma inline_expr_subst eₛ eₛ' eₜ eₜ' ς :
    data_program_valid prog →
    inline_expr prog eₛ eₜ →
    eₛ' = eₛ.[ς] →
    eₜ' = eₜ.[ς] →
    inline_expr prog eₛ' eₜ'.
  Proof.
    intros (Hprog_wf & Hprog_scope) Hinline.
    revert eₛ' eₜ' ς. induction Hinline; intros eₛ' eₜ' ς -> ->;
      eauto using inline_expr_refl with inline.
    apply inline_expr_call_inline with (e_funcₛ := e_funcₛ.[up ς]); try naive_solver.
    erewrite (subst_data_program_scope _ ids); asimpl; done.
  Qed.

  Lemma data_expr_scope_inline eₛ eₜ scope :
    data_program_scope prog →
    inline_expr prog eₛ eₜ →
    data_expr_scope scope eₛ →
    data_expr_scope scope eₜ.
  Proof.
    intros Hprog_scope Hinline.
    revert scope. induction Hinline; intros scope Hscope;
      try naive_solver.
    split; first naive_solver.
    apply (data_expr_scope_le 1); [lia | naive_solver].
  Qed.
End inline.

#[global] Hint Resolve inline_expr_refl : inline.

Lemma data_program_scope_inline progₛ progₜ :
  inline progₛ progₜ →
  data_program_scope progₛ →
  data_program_scope progₜ.
Proof.
  intros inline. rewrite /data_program_scope !map_Forall_lookup => Hscope func eₜ Hfuncₜ.
  apply elem_of_dom_2 in Hfuncₜ as Hfuncₜ'.
  rewrite inline.(inline_dom) in Hfuncₜ'. apply lookup_lookup_total_dom in Hfuncₜ'.
  edestruct inline.(inline_transform) as (_eₜ & Hinline & Heq); first done.
  rewrite Heq in Hfuncₜ. eapply data_expr_scope_inline; naive_solver.
Qed.

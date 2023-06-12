From iris.bi Require Import
  fixpoint.

From simuliris Require Import
  prelude.
From simuliris.base_logic Require Export
  lib.cupd.proofmode.
From simuliris.program_logic Require Export
  sim.protocol.

Class SimState PROP Λₛ Λₜ := {
  sim_state_interp : state Λₛ → state Λₜ → PROP ;
}.
#[global] Arguments Build_SimState {_ _ _} _ : assert.

Section sim_state.
  Context `{!BiBUpd PROP, !BiAffine PROP}.
  Context `{sim_state : !SimState PROP Λₛ Λₜ}.

  Notation expr_relation :=
    (expr Λₛ → expr Λₜ → PROP).
  Notation expr_relation_O :=
    (expr_O Λₛ -d> expr_O Λₜ -d> PROP).

  Section sim_cupd.
    #[local] Definition sim_cupd : CUpd PROP := (
      λ P,
        ∀ σₛ σₜ,
        sim_state_interp σₛ σₜ ==∗
        sim_state_interp σₛ σₜ ∗ P
    )%I.
    #[global] Program Instance sim_bi_cupd : BiCUpd PROP :=
      Build_BiCUpd sim_cupd _.
    Next Obligation.
      split; rewrite /cupd /sim_cupd.
      - solve_proper.
      - auto with iFrame.
      - iIntros "%P %Q %HPQ HP * Hsi".
        iMod ("HP" with "Hsi") as "(Hsi & HP)".
        iFrame. iApply (HPQ with "HP").
      - iIntros "%P HP * Hsi".
        do 2 iMod ("HP" with "Hsi") as "(Hsi & HP)".
        iFrame. done.
      - iIntros "%P %R (HP & HR) * Hsi".
        iMod ("HP" with "Hsi") as "(Hsi & HP)".
        iFrame. done.
      - iIntros "%P HP * Hsi". iFrame.
    Qed.

    Lemma sim_cupd_eq P :
      (|++> P) ⊣⊢
      ∀ σₛ σₜ,
      sim_state_interp σₛ σₜ ==∗
      sim_state_interp σₛ σₜ ∗
      P.
    Proof.
      done.
    Qed.

    (* FIXME: we should not need this *)
    #[global] Instance sim_cupd_ne :
      NonExpansive (sim_cupd).
    Proof.
      apply (@cupd_ne _ _ sim_bi_cupd).
    Qed.
  End sim_cupd.

  #[global] Opaque sim_cupd.

  Context (progₛ : program Λₛ) (progₜ : program Λₜ).
  Context (X : sim_protocol PROP Λₛ Λₜ).
  Implicit Types N M I : sim_protocol_O PROP Λₛ Λₜ.
  Implicit Types R : expr_relation_O → expr_relation_O → PROP.

  Definition sim_body N M : sim_protocol_O PROP Λₛ Λₜ := (
    λ Φ eₛ eₜ,
      ∀ σₛ σₜ,
      sim_state_interp σₛ σₜ ==∗ (
        sim_state_interp σₛ σₜ ∗
        Φ eₛ eₜ
      ) ∨ (
        ∃ eₛ' σₛ',
        ⌜tc (step progₛ) (eₛ, σₛ) (eₛ', σₛ')⌝ ∗
        sim_state_interp σₛ' σₜ ∗
        M Φ eₛ' eₜ
      ) ∨ (
        ⌜reducible progₜ eₜ σₜ⌝ ∗
          ∀ eₜ' σₜ',
          ⌜prim_step progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗ (
            sim_state_interp σₛ σₜ' ∗
            M Φ eₛ eₜ'
          ) ∨ (
            ∃ eₛ' σₛ',
            ⌜tc (step progₛ) (eₛ, σₛ) (eₛ', σₛ')⌝ ∗
            sim_state_interp σₛ' σₜ' ∗
            N Φ eₛ' eₜ'
          )
      ) ∨ (
        ∃ Kₛ eₛ' Kₜ eₜ' Φ',
        ⌜eₛ = Kₛ @@ eₛ' ∧ eₜ = Kₜ @@ eₜ'⌝ ∗
        X Φ' eₛ' eₜ' ∗
        sim_state_interp σₛ σₜ ∗
          ∀ eₛ eₜ,
          Φ' eₛ eₜ ++∗
          N Φ (Kₛ @@ eₛ) (Kₜ @@ eₜ)
      )
  )%I.
  #[global] Arguments sim_body _ _ _%I _ _ : assert.

  Definition sim_body' N (M : prodO (prodO expr_relation_O (expr_O Λₛ)) (expr_O Λₜ) → PROP)
  : prodO (prodO expr_relation_O (expr_O Λₛ)) (expr_O Λₜ) → PROP
  :=
    uncurry3 $ sim_body N $ curry3 M.
  Definition sim_inner N : sim_protocol_O PROP Λₛ Λₜ :=
    curry3 $ bi_least_fixpoint (sim_body' N).
  #[global] Arguments sim_inner _ _%I _ _ : assert.

  Definition sim_inner' (N : prodO (prodO expr_relation_O (expr_O Λₛ)) (expr_O Λₜ) → PROP)
  : prodO (prodO expr_relation_O (expr_O Λₛ)) (expr_O Λₜ) → PROP
  :=
    uncurry3 $ sim_inner $ curry3 N.
  #[local] Definition sim_def : sim_protocol_O PROP Λₛ Λₜ :=
    curry3 $ bi_greatest_fixpoint sim_inner'.
  #[local] Definition sim_aux :
    seal (@sim_def). Proof. by eexists. Qed.
  Definition sim :=
    sim_aux.(unseal).
  #[local] Definition sim_unseal : @sim = @sim_def :=
    sim_aux.(seal_eq).
  #[global] Arguments sim _%I _ _ : assert.

  Definition sim_post_val Φ eₛ eₜ : PROP :=
      ⌜strongly_stuck progₛ eₛ ∧ strongly_stuck progₜ eₜ⌝
    ∨ ∃ vₛ vₜ,
      ⌜eₛ = of_val vₛ ∧ eₜ = of_val vₜ⌝ ∗
      Φ vₛ vₜ.
  #[local] Definition simv_def Φ :=
    sim (sim_post_val Φ).
  #[local] Definition simv_aux :
    seal (@simv_def). Proof. by eexists. Qed.
  Definition simv :=
    simv_aux.(unseal).
  #[local] Definition simv_unseal : @simv = @simv_def :=
    simv_aux.(seal_eq).
  #[global] Arguments simv _%I _ _ : assert.
End sim_state.

From iris.bi Require Import
  fixpoint.

From simuliris Require Import
  prelude.
From simuliris.common Require Import
  tactics.
From simuliris.base_logic Require Import
  lib.cupd.proofmode.
From simuliris.program_logic Require Export
  sim.definition.
From simuliris.program_logic Require Import
  sim.notations.

#[local] Notation "Φ1 --∗ Φ2" := (∀ x1 x2, Φ1 x1 x2 -∗ Φ2 x1 x2)%I
( at level 99,
  Φ2 at level 200,
  right associativity,
  format "'[' Φ1  --∗  '/' '[' Φ2 ']' ']'"
) : bi_scope.
#[local] Notation "Φ1 --∗ Φ2" := (⊢ Φ1 --∗ Φ2)%I
( only parsing
) : stdpp_scope.
#[local] Notation "Φ1 ===∗ Φ2" := (∀ x1 x2, Φ1 x1 x2 -∗ |==> Φ2 x1 x2)%I
( at level 99,
  Φ2 at level 200,
  format "'[' Φ1  ===∗  '/' '[' Φ2 ']' ']'"
) : bi_scope.
#[local] Notation "Φ1 ===∗ Φ2" := (⊢ Φ1 ===∗ Φ2)%I
( only parsing
) : stdpp_scope.
#[local] Notation "Φ1 +++∗ Φ2" := (∀ x1 x2, Φ1 x1 x2 -∗ |++> Φ2 x1 x2)%I
( at level 99,
  Φ2 at level 200,
  format "'[' Φ1  +++∗  '/' '[' Φ2 ']' ']'"
) : bi_scope.
#[local] Notation "Φ1 +++∗ Φ2" := (⊢ Φ1 +++∗ Φ2)%I
( only parsing
) : stdpp_scope.

#[local] Notation "Φ1 ---∗ Φ2" := (∀ x1 x2 x3, Φ1 x1 x2 x3 -∗ Φ2 x1 x2 x3)%I
( at level 99,
  Φ2 at level 200,
  right associativity,
  format "'[' Φ1  ---∗  '/' '[' Φ2 ']' ']'"
) : bi_scope.
#[local] Notation "Φ1 ---∗ Φ2" := (⊢ Φ1 ---∗ Φ2)%I
( only parsing
) : stdpp_scope.
#[local] Notation "Φ1 ====∗ Φ2" := (∀ x1 x2 x3, Φ1 x1 x2 x3 -∗ |==> Φ2 x1 x2 x3)%I
( at level 99,
  Φ2 at level 200,
  format "'[' Φ1  ====∗  '/' '[' Φ2 ']' ']'"
) : bi_scope.
#[local] Notation "Φ1 ====∗ Φ2" := (⊢ Φ1 ====∗ Φ2)%I
( only parsing
) : stdpp_scope.
#[local] Notation "Φ1 ++++∗ Φ2" := (∀ x1 x2 x3, Φ1 x1 x2 x3 -∗ |++> Φ2 x1 x2 x3)%I
( at level 99,
  Φ2 at level 200,
  format "'[' Φ1  ++++∗  '/' '[' Φ2 ']' ']'"
) : bi_scope.
#[local] Notation "Φ1 ++++∗ Φ2" := (⊢ Φ1 ++++∗ Φ2)%I
( only parsing
) : stdpp_scope.

Section sim_state.
  Context `{sim_programs : !SimPrograms Λₛ Λₜ}.
  Context `{!BiBUpd PROP, !BiAffine PROP}.
  Context `{sim_state : !SimState PROP Λₛ Λₜ}.

  Notation sim_protocol := (sim_protocol PROP Λₛ Λₜ).
  Notation sim_protocol_O := (sim_protocol_O PROP Λₛ Λₜ).
  Implicit Types X : sim_protocol.
  Implicit Types N M I : sim_protocol_O.

  Section protocol.
    Context X.

    Notation sim_body := (sim_body X).
    Notation sim_body' := (definition.sim_body' X).
    Notation sim_inner := (sim_inner X).
    Notation sim_inner' := (definition.sim_inner' X).
    Notation sim := (sim X).
    Notation simv := (simv X).

    Section sim_body.
      #[global] Instance sim_body_ne n :
        Proper (
          ((≡{n}≡) ==> (≡{n}≡)) ==>
          ((≡{n}≡) ==> (≡{n}≡)) ==>
          (≡{n}≡) ==>
          (≡{n}≡) ==>
          (≡{n}≡) ==>
          (≡{n}≡)
        ) sim_body.
      Proof.
        intros N1 N2 HN M1 M2 HM Φ1 Φ2 HΦ eₛ1 eₛ2 ->%leibniz_equiv eₜ1 eₜ2 ->%leibniz_equiv.
        solve_proper_core ltac:(fun _ => f_equiv || apply HN || apply HM || apply HΦ).
      Qed.
      #[global] Instance sim_body_proper :
        Proper (
          ((≡) ==> (≡)) ==>
          ((≡) ==> (≡)) ==>
          (≡) ==>
          (≡) ==>
          (≡) ==>
          (≡)
        ) sim_body.
      Proof.
        intros N1 N2 HN M1 M2 HM Φ1 Φ2 HΦ eₛ1 eₛ2 ->%leibniz_equiv eₜ1 eₜ2 ->%leibniz_equiv.
        rewrite /sim_body. repeat (f_equiv || apply HN || apply HM || apply HΦ).
      Qed.

      Lemma sim_body_strongly_stuck N M eₛ eₜ Φ :
        strongly_stuck sim_progₛ eₛ →
        strongly_stuck sim_progₜ eₜ →
        ⊢ sim_body N M Φ eₛ eₜ.
      Proof.
        iIntros "%Hstuckₛ %Hstuckₜ %σₛ %σₜ Hsi !>".
        auto with iFrame.
      Qed.
      Lemma sim_body_strongly_head_stuck N M eₛ eₜ Φ :
        strongly_head_stuck sim_progₛ eₛ →
        strongly_head_stuck sim_progₜ eₜ →
        ⊢ sim_body N M Φ eₛ eₜ.
      Proof.
        intros.
        apply sim_body_strongly_stuck; apply strongly_head_stuck_strongly_stuck; done.
      Qed.

      Lemma sim_body_post N M Φ :
        Φ --∗ sim_body N M Φ.
      Proof.
        iIntros "%eₛ %eₜ H %σₛ %σₜ Hsi".
        auto with iFrame.
      Qed.

      Lemma cupd_sim_body N M Φ eₛ eₜ :
        (|++> sim_body N M Φ eₛ eₜ) -∗
        sim_body N M Φ eₛ eₜ.
      Proof.
        iIntros "Hsim %σₛ %σₜ Hsi".
        rewrite sim_cupd_eq. iMod ("Hsim" with "Hsi") as "(Hsi & Hsim)".
        iApply ("Hsim" with "Hsi").
      Qed.
      Lemma bupd_sim_body N M Φ eₛ eₜ :
        (|==> sim_body N M Φ eₛ eₜ) -∗
        sim_body N M Φ eₛ eₜ.
      Proof.
        iIntros "Hsim".
        iApply cupd_sim_body.
        iMod "Hsim" as "$". done.
      Qed.

      Lemma sim_body_monotone R N1 N2 M1 M2 Φ1 Φ2 :
        (R Φ1 Φ2 -∗ N1 Φ1 +++∗ N2 Φ2) -∗
        (R Φ1 Φ2 -∗ M1 Φ1 +++∗ M2 Φ2) -∗
        (R Φ1 Φ2 -∗ Φ1 +++∗ Φ2) -∗
        R Φ1 Φ2 -∗ sim_body N1 M1 Φ1 --∗ sim_body N2 M2 Φ2.
      Proof.
        setoid_rewrite sim_cupd_eq.
        iIntros "HN HM HΦ HR %eₛ %eₜ Hsim %σₛ %σₜ Hsi".
        iMod ("Hsim" with "Hsi") as "[Hsim | [Hsim | [Hsim | Hsim]]]".
        - iDestruct "Hsim" as "(Hsi & [(%Hstuckₛ & %Hstuckₜ) | HΦ1])"; iLeft.
          + auto with iFrame.
          + iMod ("HΦ" with "HR HΦ1 Hsi") as "(Hsi & HΦ2)". auto with iFrame.
        - iDestruct "Hsim" as "(%eₛ' & %σₛ' & %Hstepsₛ & Hsi & HM1)".
          iRight. iLeft. iExists eₛ', σₛ'. iSplitR; first done.
          iApply ("HM" with "HR HM1 Hsi").
        - iDestruct "Hsim" as "(%Hreducible & Hsim)".
          do 2 iRight. iLeft. iSplitR; first done. iIntros "!> %eₜ' %σₜ' %Hstepₜ".
          iDestruct ("Hsim" with "[//]") as "> [Hsim | Hsim]".
          + iDestruct "Hsim" as "(Hsi & HM1)".
            iLeft.
            iApply ("HM" with "HR HM1 Hsi").
          + iDestruct "Hsim" as "(%eₛ' & %σₛ' & %Hstepsₛ & Hsi & HN1)".
            iRight. iExists eₛ', σₛ'. iSplitR; first done.
            iApply ("HN" with "HR HN1 Hsi").
        - iDestruct "Hsim" as "(%Kₛ & %eₛ' & %Kₜ & %eₜ' & %Ψ & (-> & ->) & HX & Hsi & HN1)".
          do 3 iRight. iExists Kₛ, eₛ', Kₜ, eₜ', Ψ. iFrame. iSplitR; first done. clear eₛ' σₛ eₜ' σₜ. iIntros "!> %eₛ %eₜ HΨ".
          iMod ("HN1" with "HΨ") as "HN1".
          iApply ("HN" with "HR HN1").
      Qed.

      Lemma sim_body_cupd_mono N1 N2 M1 M2 :
        (N1 ++++∗ N2) -∗
        (M1 ++++∗ M2) -∗
        sim_body N1 M1 ---∗ sim_body N2 M2.
      Proof.
        iIntros "HN HM %Φ".
        iApply (sim_body_monotone (λ _ _, True)%I with "[HN] [HM] [] [//]"); iIntros "_"; auto.
      Qed.
      Lemma sim_body_bupd_mono N1 N2 M1 M2 :
        (N1 ====∗ N2) -∗
        (M1 ====∗ M2) -∗
        sim_body N1 M1 ---∗ sim_body N2 M2.
      Proof.
        iIntros "HN HM".
        iApply (sim_body_cupd_mono with "[HN] [HM]").
        - iIntros "%Φ %eₛ %eₜ HN1".
          iMod ("HN" with "HN1") as "$". done.
        - iIntros "%Φ %eₛ %eₜ HM1".
          iMod ("HM" with "HM1") as "$". done.
      Qed.
      Lemma sim_body_mono N1 N2 M1 M2 :
        (N1 ---∗ N2) -∗
        (M1 ---∗ M2) -∗
        sim_body N1 M1 ---∗ sim_body N2 M2.
      Proof.
        iIntros "HN HM".
        iApply (sim_body_bupd_mono with "[HN] [HM]").
        - iIntros "%Φ %eₛ %eₜ HN1".
          iApply ("HN" with "HN1").
        - iIntros "%Φ %eₛ %eₜ HM1".
          iApply ("HM" with "HM1").
      Qed.

      Lemma sim_body_strong_cupd_mono N1 N2 M1 M2 Φ1 Φ2 :
        ((Φ1 +++∗ Φ2) -∗ N1 Φ1 +++∗ N2 Φ2) -∗
        ((Φ1 +++∗ Φ2) -∗ M1 Φ1 +++∗ M2 Φ2) -∗
        (Φ1 +++∗ Φ2) -∗ sim_body N1 M1 Φ1 --∗ sim_body N2 M2 Φ2.
      Proof.
        iIntros "HN HM HΦ".
        iApply (sim_body_monotone (λ Φ1 Φ2, Φ1 +++∗ Φ2)%I with "[HN] [HM] [] HΦ"); [done.. | iIntros "$"].
      Qed.
      Lemma sim_body_strong_bupd_mono N1 N2 M1 M2 Φ1 Φ2 :
        ((Φ1 ===∗ Φ2) -∗ N1 Φ1 +++∗ N2 Φ2) -∗
        ((Φ1 ===∗ Φ2) -∗ M1 Φ1 +++∗ M2 Φ2) -∗
        (Φ1 ===∗ Φ2) -∗ sim_body N1 M1 Φ1 --∗ sim_body N2 M2 Φ2.
      Proof.
        iIntros "HN HM HΦ".
        iApply (sim_body_monotone (λ Φ1 Φ2, Φ1 ===∗ Φ2)%I with "[HN] [HM] [] HΦ"); [done.. |].
        iIntros "HΦ %eₛ %eₜ HΦ1".
        iMod ("HΦ" with "HΦ1") as "$". done.
      Qed.
      Lemma sim_body_strong_mono N1 N2 M1 M2 Φ1 Φ2 :
        ((Φ1 --∗ Φ2) -∗ N1 Φ1 +++∗ N2 Φ2) -∗
        ((Φ1 --∗ Φ2) -∗ M1 Φ1 +++∗ M2 Φ2) -∗
        (Φ1 --∗ Φ2) -∗ sim_body N1 M1 Φ1 --∗ sim_body N2 M2 Φ2.
      Proof.
        iIntros "HN HM HΦ".
        iApply (sim_body_monotone (λ Φ1 Φ2, Φ1 --∗ Φ2)%I with "[HN] [HM] [] HΦ"); [done.. |].
        iIntros "HΦ %eₛ %eₜ HΦ1".
        iApply ("HΦ" with "HΦ1").
      Qed.

      Lemma sim_body_cupd N M Φ :
        (N (λ eₛ eₜ, |++> Φ eₛ eₜ) +++∗ N Φ) -∗
        (M (λ eₛ eₜ, |++> Φ eₛ eₜ) +++∗ M Φ) -∗
        sim_body N M (λ eₛ eₜ, |++> Φ eₛ eₜ) --∗ sim_body N M Φ.
      Proof.
        iIntros "HN HM".
        iApply (sim_body_strong_cupd_mono with "[HN] [HM]"); [iIntros "_ //".. | auto].
      Qed.
      Lemma sim_body_bupd N M Φ :
        (N (λ eₛ eₜ, |==> Φ eₛ eₜ) +++∗ N Φ) -∗
        (M (λ eₛ eₜ, |==> Φ eₛ eₜ) +++∗ M Φ) -∗
        sim_body N M (λ eₛ eₜ, |==> Φ eₛ eₜ) --∗ sim_body N M Φ.
      Proof.
        iIntros "HN HM".
        iApply (sim_body_strong_bupd_mono with "[HN] [HM]"); [iIntros "_ //".. | auto].
      Qed.

      Lemma sim_body_frame_l N M R eₛ eₜ Φ :
        ( ∀ eₛ eₜ,
          R ∗ N Φ eₛ eₜ ++∗
          N (λ eₛ eₜ, R ∗ Φ eₛ eₜ) eₛ eₜ
        ) -∗
        ( ∀ eₛ eₜ,
          R ∗ M Φ eₛ eₜ ++∗
          M (λ eₛ eₜ, R ∗ Φ eₛ eₜ) eₛ eₜ
        ) -∗
        R ∗ sim_body N M Φ eₛ eₜ -∗
        sim_body N M (λ eₛ eₜ, R ∗ Φ eₛ eₜ) eₛ eₜ.
      Proof.
        iIntros "HN HM (HR & Hsim)".
        iApply (sim_body_monotone (λ _ _, R) with "[HN] [HM] [] HR Hsim"); clear eₛ eₜ.
        - iIntros "HR %eₛ %eₜ HN'".
          iApply ("HN" with "[$HR $HN']").
        - iIntros "HR %eₛ %eₜ HM'".
          iApply ("HM" with "[$HR $HM']").
        - iIntros "HR %eₛ %eₜ HΦ !>". iFrame.
      Qed.
      Lemma sim_body_frame_r N M R eₛ eₜ Φ :
        ( ∀ eₛ eₜ,
          N Φ eₛ eₜ ∗ R ++∗
          N (λ eₛ eₜ, Φ eₛ eₜ ∗ R) eₛ eₜ
        ) -∗
        ( ∀ eₛ eₜ,
          M Φ eₛ eₜ ∗ R ++∗
          M (λ eₛ eₜ, Φ eₛ eₜ ∗ R) eₛ eₜ
        ) -∗
        sim_body N M Φ eₛ eₜ ∗ R -∗
        sim_body N M (λ eₛ eₜ, Φ eₛ eₜ ∗ R) eₛ eₜ.
      Proof.
        iIntros "HN HM (Hsim & HR)".
        iApply (sim_body_monotone (λ _ _, R) with "[HN] [HM] [] HR Hsim"); clear eₛ eₜ.
        - iIntros "HR %eₛ %eₜ HN'".
          iApply ("HN" with "[$HR $HN']").
        - iIntros "HR %eₛ %eₜ HM'".
          iApply ("HM" with "[$HR $HM']").
        - iIntros "HR %eₛ %eₜ HΦ !>". iFrame.
      Qed.

      (* TODO: sim_body_bind *)
      (* TODO: sim_body_bindₛ *)
      (* TODO: sim_body_bindₜ *)

      (* TODO: sim_body_bind_inv *)
      (* TODO: sim_body_bind_invₛ *)
      (* TODO: sim_body_bind_invₜ *)

      (* TODO: sim_body_decompose *)

      Lemma sim_body_stepsₛ N M eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ∃ eₛ' σₛ',
            ⌜tc (step sim_progₛ) (eₛ, σₛ) (eₛ', σₛ')⌝ ∗
            sim_state_interp σₛ' σₜ ∗
            M Φ eₛ' eₜ
        ) -∗
        sim_body N M Φ eₛ eₜ.
      Proof.
        iIntros "HM %σₛ %σₜ Hsi".
        iRight. iLeft. iApply ("HM" with "Hsi").
      Qed.
      Lemma sim_body_stepₛ N M eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ∃ eₛ' σₛ',
            ⌜prim_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
            sim_state_interp σₛ' σₜ ∗
            M Φ eₛ' eₜ
        ) -∗
        sim_body N M Φ eₛ eₜ.
      Proof.
        iIntros "HM".
        iApply sim_body_stepsₛ. iIntros "%σₛ %σₜ Hsi".
        iMod ("HM" with "Hsi") as "(%eₛ' & %σₛ' & %Hstepₛ & Hsi)".
        iExists eₛ', σₛ'. iFrame. iPureIntro. eapply tc_once, prim_step_step; done.
      Qed.
      Lemma sim_body_head_stepₛ N M eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ∃ eₛ' σₛ',
            ⌜head_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
            sim_state_interp σₛ' σₜ ∗
            M Φ eₛ' eₜ
        ) -∗
        sim_body N M Φ eₛ eₜ.
      Proof.
        iIntros "HM".
        iApply sim_body_stepₛ. iIntros "%σₛ %σₜ Hsi".
        iMod ("HM" with "Hsi") as "(%eₛ' & %σₛ' & %Hstepₛ & Hsi)".
        iExists eₛ', σₛ'. iFrame. iPureIntro. apply head_step_prim_step. done.
      Qed.
      Lemma sim_body_pure_stepsₛ N M eₛ1 eₛ2 eₜ Φ :
        tc (pure_step sim_progₛ) eₛ1 eₛ2 →
        M Φ eₛ2 eₜ -∗
        sim_body N M Φ eₛ1 eₜ.
      Proof.
        iIntros "%Hstepsₛ HM".
        iApply sim_body_stepsₛ. iIntros "%σₛ %σₜ Hsi".
        iExists eₛ2, σₛ. iSplitR; last auto with iFrame. iPureIntro.
        eapply (tc_congruence (λ eₛ, (eₛ, σₛ))); last done.
        eauto using prim_step_step, pure_step_prim_step.
      Qed.
      Lemma sim_body_pure_stepₛ N M eₛ1 eₛ2 eₜ Φ :
        pure_step sim_progₛ eₛ1 eₛ2 →
        M Φ eₛ2 eₜ -∗
        sim_body N M Φ eₛ1 eₜ.
      Proof.
        intros Hstepₛ.
        iApply sim_body_pure_stepsₛ.
        eauto using tc_once.
      Qed.
      Lemma sim_body_pure_head_stepsₛ N M eₛ1 eₛ2 eₜ Φ :
        tc (pure_head_step sim_progₛ) eₛ1 eₛ2 →
        M Φ eₛ2 eₜ -∗
        sim_body N M Φ eₛ1 eₜ.
      Proof.
        intros Hstepsₛ.
        iApply sim_body_pure_stepsₛ.
        eauto using (tc_congruence id), pure_head_step_pure_step.
      Qed.
      Lemma sim_body_pure_head_stepₛ N M eₛ1 eₛ2 eₜ Φ :
        pure_head_step sim_progₛ eₛ1 eₛ2 →
        M Φ eₛ2 eₜ -∗
        sim_body N M Φ eₛ1 eₜ.
      Proof.
        intros Hstepₛ.
        iApply sim_body_pure_head_stepsₛ.
        eauto using tc_once.
      Qed.

      Lemma sim_body_stepₜ N M eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                sim_state_interp σₛ σₜ' ∗
                M Φ eₛ eₜ'
        ) -∗
        sim_body N M Φ eₛ eₜ.
      Proof.
        iIntros "HM %σₛ %σₜ Hsi".
        do 2 iRight. iLeft.
        iMod ("HM" with "Hsi") as "($ & HM)".
        iIntros "!> %eₜ' %σₜ' %Hstepₜ".
        iLeft. iApply ("HM" with "[//]").
      Qed.
      Lemma sim_body_head_stepₜ N M eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜head_reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜head_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                sim_state_interp σₛ σₜ' ∗
                M Φ eₛ eₜ'
        ) -∗
        sim_body N M Φ eₛ eₜ.
      Proof.
        iIntros "HM".
        iApply sim_body_stepₜ. iIntros "%σₛ %σₜ Hsi".
        iMod ("HM" with "Hsi") as "(%Hreducibleₜ & HM)".
        iSplitR; first auto using head_reducible_reducible. iIntros "!> %eₜ' %σₜ' %Hstepₜ".
        apply head_reducible_prim_step in Hstepₜ; last done.
        iApply "HM". done.
      Qed.
      Lemma sim_body_pure_stepₜ N M eₛ eₜ1 eₜ2 Φ :
        pure_step sim_progₜ eₜ1 eₜ2 →
        M Φ eₛ eₜ2 -∗
        sim_body N M Φ eₛ eₜ1.
      Proof.
        iIntros "%Hstepₜ HM".
        iApply sim_body_stepₜ. iIntros "%σₛ %σₜ Hsi !>".
        iSplit; eauto using pure_step_safe. iIntros "%eₜ' %σₜ' %Hstepₜ' !>".
        eapply pure_step_det in Hstepₜ; last done. destruct Hstepₜ as (-> & ->).
        iFrame.
      Qed.
      Lemma sim_body_pure_head_stepₜ N M eₛ eₜ1 eₜ2 Φ :
        pure_head_step sim_progₜ eₜ1 eₜ2 →
        M Φ eₛ eₜ2 -∗
        sim_body N M Φ eₛ eₜ1.
      Proof.
        intros Hstepₜ.
        iApply sim_body_pure_stepₜ.
        eauto using pure_head_step_pure_step.
      Qed.

      Lemma sim_body_steps N M eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                ∃ eₛ' σₛ',
                ⌜tc (step sim_progₛ) (eₛ, σₛ) (eₛ', σₛ')⌝ ∗
                sim_state_interp σₛ' σₜ' ∗
                N Φ eₛ' eₜ'
        ) -∗
        sim_body N M Φ eₛ eₜ.
      Proof.
        iIntros "HN %σₛ %σₜ Hsi".
        do 2 iRight. iLeft.
        iMod ("HN" with "Hsi") as "($ & HN)".
        iIntros "!> %eₜ' %σₜ' %Hstepₜ".
        iRight. iApply ("HN" with "[//]").
      Qed.
      Lemma sim_body_step N M eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                ∃ eₛ' σₛ',
                ⌜prim_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
                sim_state_interp σₛ' σₜ' ∗
                N Φ eₛ' eₜ'
        ) -∗
        sim_body N M Φ eₛ eₜ.
      Proof.
        iIntros "HN".
        iApply sim_body_steps. iIntros "%σₛ %σₜ Hsi".
        iMod ("HN" with "Hsi") as "(%Hreducibleₜ & HN)".
        iSplitR; first done. iIntros "!> %eₜ' %σₜ' %Hstepₜ".
        iMod ("HN" with "[//]") as "(%eₛ' & %σₛ' & %Hstepₛ & Hsi & HN)".
        iExists eₛ', σₛ'. iFrame. eauto using tc_once, prim_step_step.
      Qed.
      Lemma sim_body_head_step N M eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜head_reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜head_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                ∃ eₛ' σₛ',
                ⌜head_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
                sim_state_interp σₛ' σₜ' ∗
                N Φ eₛ' eₜ'
        ) -∗
        sim_body N M Φ eₛ eₜ.
      Proof.
        iIntros "HN".
        iApply sim_body_step. iIntros "%σₛ %σₜ Hsi".
        iMod ("HN" with "Hsi") as "(%Hreducibleₜ & HN)".
        iSplitR; first auto using head_reducible_reducible. iIntros "!> %eₜ' %σₜ' %Hstepₜ".
        apply head_reducible_prim_step in Hstepₜ; last done.
        iMod ("HN" with "[//]") as "(%eₛ' & %σₛ' & %Hstepₛ & Hsi & HN)".
        iExists eₛ', σₛ'. iFrame. iPureIntro. apply head_step_prim_step. done.
      Qed.
      Lemma sim_body_pure_steps N M eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        tc (pure_step sim_progₛ) eₛ1 eₛ2 →
        pure_step sim_progₜ eₜ1 eₜ2 →
        N Φ eₛ2 eₜ2 -∗
        sim_body N M Φ eₛ1 eₜ1.
      Proof.
        iIntros "%Hstepsₛ %Hstepₜ HN".
        iApply sim_body_steps. iIntros "%σₛ %σₜ Hsi !>".
        iSplit; first eauto using pure_step_safe. iIntros "%_eₜ2 %_σₜ %_Hstepₜ !>".
        eapply pure_step_det in _Hstepₜ as (-> & ->); last done.
        iExists eₛ2, σₛ. iFrame. iPureIntro.
        eapply (tc_congruence (λ eₛ, (eₛ, σₛ))); last done.
        eauto using prim_step_step, pure_step_prim_step.
      Qed.
      Lemma sim_body_pure_step N M eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        pure_step sim_progₛ eₛ1 eₛ2 →
        pure_step sim_progₜ eₜ1 eₜ2 →
        N Φ eₛ2 eₜ2 -∗
        sim_body N M Φ eₛ1 eₜ1.
      Proof.
        iIntros "%Hstepₛ %Hstepₜ HN".
        iApply (sim_body_pure_steps with "HN"); first apply tc_once; done.
      Qed.
      Lemma sim_body_pure_head_steps N M eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        tc (pure_head_step sim_progₛ) eₛ1 eₛ2 →
        pure_head_step sim_progₜ eₜ1 eₜ2 →
        N Φ eₛ2 eₜ2 -∗
        sim_body N M Φ eₛ1 eₜ1.
      Proof.
        iIntros "%Hstepₛ %Hstepₜ HN".
        iApply (sim_body_pure_steps with "HN");
          eauto using (tc_congruence id), pure_head_step_pure_step.
      Qed.
      Lemma sim_body_pure_head_step N M eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        pure_head_step sim_progₛ eₛ1 eₛ2 →
        pure_head_step sim_progₜ eₜ1 eₜ2 →
        N Φ eₛ2 eₜ2 -∗
        sim_body N M Φ eₛ1 eₜ1.
      Proof.
        iIntros "%Hstepₛ %Hstepₜ HN".
        iApply (sim_body_pure_head_steps with "HN"); first apply tc_once; done.
      Qed.

      Lemma sim_body_apply_protocol Ψ Kₛ eₛ' Kₜ eₜ' N M eₛ eₜ Φ :
        eₛ = Kₛ @@ eₛ' →
        eₜ = Kₜ @@ eₜ' →
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            X Ψ eₛ' eₜ' ∗
            sim_state_interp σₛ σₜ ∗
              ∀ eₛ eₜ,
              Ψ eₛ eₜ ++∗
              N Φ (Kₛ @@ eₛ) (Kₜ @@ eₜ)

        ) -∗
        sim_body N M Φ eₛ eₜ.
      Proof.
        iIntros (-> ->) "H %σₛ %σₜ Hsi".
        do 3 iRight. iExists Kₛ, eₛ', Kₜ, eₜ', Ψ. iSplitR; first done.
        iApply ("H" with "Hsi").
      Qed.
    End sim_body.

    Section sim_inner.
      #[local] Instance sim_body'_ne n :
        Proper (
          ((≡{n}≡) ==> (≡{n}≡)) ==>
          ((≡{n}≡) ==> (≡{n}≡)) ==>
          (≡{n}≡) ==>
          (≡{n}≡)
        ) sim_body'.
      Proof.
        intros N1 N2 HN M1 M2 HM ((Φ1 & eₛ1) & eₜ1) ((Φ2 & eₛ2) & eₜ2) ((HΦ & Heₛ%leibniz_equiv) & Heₜ%leibniz_equiv).
        simpl in HΦ, Heₛ, Heₜ. subst.
        apply sim_body_ne; done || solve_proper.
      Qed.
      #[local] Instance sim_body'_proper :
        Proper (
          ((≡) ==> (≡)) ==>
          ((≡) ==> (≡)) ==>
          (≡) ==>
          (≡)
        ) sim_body'.
      Proof.
        intros N1 N2 HN M1 M2 HM ((Φ1 & eₛ1) & eₜ1) ((Φ2 & eₛ2) & eₜ2) ((HΦ & Heₛ%leibniz_equiv) & Heₜ%leibniz_equiv).
        simpl in HΦ, Heₛ, Heₜ. subst.
        apply sim_body_proper; done || solve_proper.
      Qed.

      #[local] Instance sim_body'_mono_pred N :
        NonExpansive N →
        BiMonoPred (sim_body' N).
      Proof.
        intros HN. split; last solve_proper.
        iIntros "%M1 %M2 %HM1 %HM2 #HM" (((Φ & eₛ) & eₜ)) "Hsim /=".
        iApply (sim_body_mono with "[] [] Hsim"); clear; iIntros "%Φ %eₛ %eₜ"; first auto.
        iIntros "HM1". iApply ("HM" with "HM1").
      Qed.

      #[global] Instance sim_inner_ne n :
        Proper (
          ((≡{n}≡) ==> (≡{n}≡)) ==>
          (≡{n}≡) ==>
          (≡{n}≡) ==>
          (≡{n}≡) ==>
          (≡{n}≡)
        ) sim_inner.
      Proof.
        rewrite definition.sim_inner_unseal /definition.sim_inner_def /curry3.
        solve_proper.
      Qed.
      #[global] Instance sim_inner_proper :
        Proper (
          ((≡) ==> (≡)) ==>
          (≡) ==>
          (≡) ==>
          (≡) ==>
          (≡)
        ) sim_inner.
      Proof.
        rewrite definition.sim_inner_unseal /definition.sim_inner_def /curry3.
        solve_proper.
      Qed.

      Lemma sim_inner_fixpoint N Φ eₛ eₜ :
        NonExpansive N →
        sim_inner N Φ eₛ eₜ ⊣⊢
        sim_body N (sim_inner N) Φ eₛ eₜ.
      Proof.
        rewrite definition.sim_inner_unseal.
        intros. setoid_rewrite least_fixpoint_unfold; [done | apply _].
      Qed.
      Lemma sim_inner_unfold N :
        NonExpansive N →
        sim_inner N ---∗
        sim_body N (sim_inner N).
      Proof.
        intros. setoid_rewrite sim_inner_fixpoint; auto.
      Qed.
      Lemma sim_inner_fold N :
        NonExpansive N →
        sim_body N (sim_inner N) ---∗
        sim_inner N.
      Proof.
        intros. setoid_rewrite sim_inner_fixpoint; auto.
      Qed.

      Lemma sim_inner_strong_ind I N :
        NonExpansive N →
        NonExpansive I →
        □ (sim_body N (λ Φ eₛ eₜ, I Φ eₛ eₜ ∧ sim_inner N Φ eₛ eₜ) ---∗ I) -∗
        sim_inner N ---∗ I.
      Proof.
        rewrite definition.sim_inner_unseal.
        iIntros "%HN %HI #Hind %Φ %eₛ %eₜ Hsim".
        replace (I Φ eₛ eₜ) with ((uncurry3 I) (Φ, eₛ, eₜ)); last done.
        iApply (least_fixpoint_ind with "[] Hsim"). clear Φ eₛ eₜ. iIntros "!>" (((Φ & eₛ) & eₜ)) "Hsim /=".
        iApply ("Hind" with "Hsim").
      Qed.
      Lemma sim_inner_ind I N :
        NonExpansive N →
        NonExpansive I →
        □ (sim_body N I ---∗ I) -∗
        sim_inner N ---∗ I.
      Proof.
        iIntros "%HN %HI #Hind".
        iApply sim_inner_strong_ind. iIntros "!> %Φ %eₛ %eₜ Hsim".
        iApply "Hind".
        iApply (sim_body_mono with "[] [] Hsim"); first auto with iFrame. clear Φ eₛ eₜ. iIntros "%Φ %eₛ %eₜ (HI & _) //".
      Qed.

      Lemma sim_inner_strongly_stuck N eₛ eₜ Φ :
        NonExpansive N →
        strongly_stuck sim_progₛ eₛ →
        strongly_stuck sim_progₜ eₜ →
        ⊢ sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN. rewrite sim_inner_fixpoint. apply sim_body_strongly_stuck.
      Qed.
      Lemma sim_inner_strongly_head_stuck N eₛ eₜ Φ :
        NonExpansive N →
        strongly_head_stuck sim_progₛ eₛ →
        strongly_head_stuck sim_progₜ eₜ →
        ⊢ sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN. rewrite sim_inner_fixpoint. apply sim_body_strongly_head_stuck.
      Qed.

      Lemma sim_inner_post N Φ :
        NonExpansive N →
        Φ --∗ sim_inner N Φ.
      Proof.
        intros HN. setoid_rewrite sim_inner_fixpoint; last done. apply sim_body_post.
      Qed.

      Lemma cupd_sim_inner N Φ eₛ eₜ :
        NonExpansive N →
        (|++> sim_inner N Φ eₛ eₜ) -∗
        sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN. rewrite sim_inner_fixpoint. apply cupd_sim_body.
      Qed.
      Lemma bupd_sim_inner N Φ eₛ eₜ :
        NonExpansive N →
        (|==> sim_inner N Φ eₛ eₜ) -∗
        sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN. rewrite sim_inner_fixpoint. apply bupd_sim_body.
      Qed.

      Lemma sim_inner_monotone R N1 N2 Φ1 Φ2 :
        NonExpansive N1 →
        NonExpansive N2 →
        NonExpansive2 R →
        □ (R Φ1 Φ2 -∗ N1 Φ1 +++∗ N2 Φ2) -∗
        □ (R Φ1 Φ2 -∗ Φ1 +++∗ Φ2) -∗
        R Φ1 Φ2 -∗ sim_inner N1 Φ1 --∗ sim_inner N2 Φ2.
      Proof.
        intros HN1 HN2 HR.
        set I := λ Φ1 eₛ eₜ, (
          □ (R Φ1 Φ2 -∗ N1 Φ1 +++∗ N2 Φ2) -∗
          □ (R Φ1 Φ2 -∗ Φ1 +++∗ Φ2) -∗
          R Φ1 Φ2 -∗
          sim_inner N2 Φ2 eₛ eₜ
        )%I.
        cut (sim_inner N1 Φ1 --∗ I Φ1).
        { iIntros "%HI #HN #HΦ HR %eₛ %eₜ Hsim".
          iApply (HI with "Hsim HN HΦ HR").
        }
        iApply (sim_inner_ind with "[]"); first solve_proper. clear Φ1. iIntros "!> %Φ1 %eₛ %eₜ Hsim #HN #HΦ HR".
        iApply sim_inner_fixpoint.
        iApply (sim_body_monotone with "HN [] HΦ HR Hsim"). clear eₛ eₜ. iIntros "HR %eₛ %eₜ HI".
        iApply ("HI" with "HN HΦ HR").
      Qed.

      Lemma sim_inner_cupd_mono N1 N2 :
        NonExpansive N2 →
        □ (N1 ++++∗ N2) -∗
        sim_inner N1 ---∗ sim_inner N2.
      Proof.
        rewrite definition.sim_inner_unseal.
        iIntros "%HN2 #HN %Φ %eₛ %eₜ Hsim". rewrite /sim_inner /curry3.
        iApply (least_fixpoint_iter with "[] Hsim"). clear Φ eₛ eₜ. iIntros "!>" (((Φ & eₛ) & eₜ)) "Hsim".
        rewrite least_fixpoint_unfold /sim_body' {1 3}/uncurry3.
        iApply (sim_body_cupd_mono with "[] [] Hsim"); clear Φ eₛ eₜ; iIntros "%Φ %eₛ %eₜ"; auto.
      Qed.
      Lemma sim_inner_bupd_mono N1 N2 :
        NonExpansive N2 →
        □ (N1 ====∗ N2) -∗
        sim_inner N1 ---∗ sim_inner N2.
      Proof.
        iIntros "%HN2 #HN".
        iApply sim_inner_cupd_mono. iIntros "!> %Φ %eₛ %eₜ HN1".
        iMod ("HN" with "HN1") as "$". done.
      Qed.
      Lemma sim_inner_mono N1 N2 :
        NonExpansive N2 →
        □ (N1 ---∗ N2) -∗
        sim_inner N1 ---∗ sim_inner N2.
      Proof.
        iIntros "%HN2 #HN".
        iApply sim_inner_bupd_mono. iIntros "!> %Φ %eₛ %eₜ HN1".
        iApply ("HN" with "HN1").
      Qed.

      Lemma sim_inner_strong_cupd_mono N1 N2 Φ1 Φ2 :
        NonExpansive N1 →
        NonExpansive N2 →
        □ ((Φ1 +++∗ Φ2) -∗ N1 Φ1 +++∗ N2 Φ2) -∗
        (Φ1 +++∗ Φ2) -∗ sim_inner N1 Φ1 --∗ sim_inner N2 Φ2.
      Proof.
        iIntros "%HN1 %HN2 #HN HΦ".
        iApply (sim_inner_monotone (λ Φ1 Φ2, Φ1 +++∗ Φ2)%I with "HN [] HΦ"); first solve_proper. iIntros "!> HΦ //".
      Qed.
      Lemma sim_inner_strong_bupd_mono N1 N2 Φ1 Φ2 :
        NonExpansive N1 →
        NonExpansive N2 →
        □ ((Φ1 ===∗ Φ2) -∗ N1 Φ1 +++∗ N2 Φ2) -∗
        (Φ1 ===∗ Φ2) -∗ sim_inner N1 Φ1 --∗ sim_inner N2 Φ2.
      Proof.
        iIntros "%HN1 %HN2 #HN HΦ".
        iApply (sim_inner_monotone (λ Φ1 Φ2, Φ1 ===∗ Φ2)%I with "HN [] HΦ"); first solve_proper. iIntros "!> HΦ %eₛ %eₜ HΦ1".
        iMod ("HΦ" with "HΦ1") as "$". done.
      Qed.
      Lemma sim_inner_strong_mono N1 N2 Φ1 Φ2 :
        NonExpansive N1 →
        NonExpansive N2 →
        □ ((Φ1 --∗ Φ2) -∗ N1 Φ1 +++∗ N2 Φ2) -∗
        (Φ1 --∗ Φ2) -∗ sim_inner N1 Φ1 --∗ sim_inner N2 Φ2.
      Proof.
        iIntros "%HN1 %HN2 #HN HΦ".
        iApply (sim_inner_monotone (λ Φ1 Φ2, Φ1 --∗ Φ2)%I with "HN [] HΦ"); first solve_proper. iIntros "!> HΦ %eₛ %eₜ HΦ1".
        iApply ("HΦ" with "HΦ1").
      Qed.

      Lemma sim_inner_cupd N Φ :
        NonExpansive N →
        □ (N (λ eₛ eₜ, |++> Φ eₛ eₜ) +++∗ N Φ) -∗
        sim_inner N (λ eₛ eₜ, |++> Φ eₛ eₜ) --∗ sim_inner N Φ.
      Proof.
        iIntros "%HN #HN".
        iApply (sim_inner_strong_cupd_mono with "[HN]"); [iIntros "!> _ //" | auto].
      Qed.
      Lemma sim_inner_bupd N Φ :
        NonExpansive N →
        □ (N (λ eₛ eₜ, |==> Φ eₛ eₜ) +++∗ N Φ) -∗
        sim_inner N (λ eₛ eₜ, |==> Φ eₛ eₜ) --∗ sim_inner N Φ.
      Proof.
        iIntros "%HN #HN".
        iApply (sim_inner_strong_bupd_mono with "[HN]"); [iIntros "!> _ //" | auto].
      Qed.

      Lemma sim_inner_frame_l N R eₛ eₜ Φ :
        NonExpansive N →
        □ (
          ∀ eₛ eₜ,
          R ∗ N Φ eₛ eₜ ++∗
          N (λ eₛ eₜ, R ∗ Φ eₛ eₜ) eₛ eₜ
        ) -∗
        R ∗ sim_inner N Φ eₛ eₜ -∗
        sim_inner N (λ eₛ eₜ, R ∗ Φ eₛ eₜ) eₛ eₜ.
      Proof.
        iIntros "%HN #HN (HR & Hsim)".
        iApply (sim_inner_monotone (λ _ _, R) with "[HN] [] HR Hsim"); first (by solve_proper_prepare); clear eₛ eₜ.
        - iIntros "!> HR %eₛ %eₜ HN'".
          iApply ("HN" with "[$HR $HN']").
        - iIntros "!> HR %eₛ %eₜ HΦ !>". iFrame.
      Qed.
      Lemma sim_inner_frame_r N R eₛ eₜ Φ :
        NonExpansive N →
        □ (
          ∀ eₛ eₜ,
          N Φ eₛ eₜ ∗ R ++∗
          N (λ eₛ eₜ, Φ eₛ eₜ ∗ R) eₛ eₜ
        ) -∗
        sim_inner N Φ eₛ eₜ ∗ R -∗
        sim_inner N (λ eₛ eₜ, Φ eₛ eₜ ∗ R) eₛ eₜ.
      Proof.
        iIntros "%HN #HN (Hsim & HR)".
        iApply (sim_inner_monotone (λ _ _, R) with "[HN] [] HR Hsim"); first (by solve_proper_prepare); clear eₛ eₜ.
        - iIntros "!> HR %eₛ %eₜ HN'".
          iApply ("HN" with "[$HR $HN']").
        - iIntros "!> HR %eₛ %eₜ HΦ !>". iFrame.
      Qed.

      Lemma sim_inner_bind' N1 N2 Kₛ eₛ Kₜ eₜ Φ1 Φ2 :
        NonExpansive N1 →
        NonExpansive N2 →
        sim_inner N1 Φ1 eₛ eₜ -∗
        ( ∀ eₛ' eₜ',
          N1 Φ1 eₛ' eₜ' -∗
          N2 Φ2 (Kₛ @@ eₛ') (Kₜ @@ eₜ')
        ) -∗
        ( ∀ eₛ' eₜ',
          Φ1 eₛ' eₜ' -∗
          sim_inner N2 Φ2 (Kₛ @@ eₛ') (Kₜ @@ eₜ')
        ) -∗
        sim_inner N2 Φ2 (Kₛ @@ eₛ) (Kₜ @@ eₜ).
      Proof.
        intros HN1 HN2.
        set I : sim_protocol_O := λ Φ1 eₛ eₜ, (
          ( ∀ eₛ' eₜ',
            N1 Φ1 eₛ' eₜ' -∗
            N2 Φ2 (Kₛ @@ eₛ') (Kₜ @@ eₜ')
          ) -∗
          ( ∀ eₛ' eₜ',
            Φ1 eₛ' eₜ' -∗
            sim_inner N2 Φ2 (Kₛ @@ eₛ') (Kₜ @@ eₜ')
          ) -∗
          sim_inner N2 Φ2 (Kₛ @@ eₛ) (Kₜ @@ eₜ)
        )%I.
        assert (NonExpansive I) as HI.
        { solve_proper_prepare. solve_proper_core ltac:(fun _ => apply HN1 || f_equiv). }
        iApply (sim_inner_ind I with "[]"). clear Φ1 eₛ eₜ. iIntros "!> %Φ1 %eₛ %eₜ Hsim1 HN Hsim2".
        rewrite sim_inner_fixpoint. iIntros "%σₛ %σₜ Hsi".
        iMod ("Hsim1" with "Hsi") as "[Hsim1 | [Hsim1 | [Hsim1 | Hsim1]]]".
        - iDestruct "Hsim1" as "(Hsi & [(%Hstuckₛ & %Hstuckₜ) | HΦ1])".
          + iLeft. iFrame. iLeft.
            iPureIntro. split; (apply language_ctx_strongly_stuck; [apply _ | done]).
          +
          iRevert (σₛ σₜ) "Hsi". iApply sim_inner_fixpoint. iApply ("Hsim2" with "HΦ1").
        - iDestruct "Hsim1" as "(%eₛ' & %σₛ' & %Hstepsₛ & Hsi & HI)".
          iRight. iLeft. iExists (Kₛ @@ eₛ'), σₛ'. iFrame. iSplitR.
          { iPureIntro. apply language_ctx_tc_step; [apply _ | done]. }
          iApply ("HI" with "HN Hsim2").
        - iDestruct "Hsim1" as "(%Hreducibleₜ & Hsim1)".
          do 2 iRight. iLeft. iSplitR.
          { iPureIntro. apply language_ctx_reducible; [apply _ | done]. }
          iIntros "!> %eₜ'' %σₜ' %Hstepₜ".
          apply reducible_fill_prim_step in Hstepₜ as (eₜ' & -> & Hstepₜ); last done.
          iMod ("Hsim1" with "[//]") as "[(Hsi & HI) | (%eₛ' & %σₛ' & %Hstepsₛ & Hsi & HN1)]".
          + iLeft. iFrame.
            iApply ("HI" with "HN Hsim2").
          + iRight. iExists (Kₛ @@ eₛ'), σₛ'. iFrame. iSplitR.
            { iPureIntro. apply language_ctx_tc_step; [apply _ | done]. }
            iApply ("HN" with "HN1").
        - iDestruct "Hsim1" as "(%Kₛ' & %eₛ' & %Kₜ' & %eₜ' & %Ψ & (-> & ->) & HX & Hsi & HN1)".
          do 3 iRight. iExists (Kₛ ⋅ Kₛ'), eₛ', (Kₜ ⋅ Kₜ'), eₜ', Ψ. iFrame. iSplitR; first rewrite !fill_op //. iIntros "!> %eₛ'' %eₜ'' HΨ".
          rewrite -!fill_op. iApply ("HN" with "(HN1 HΨ)").
      Qed.
      Lemma sim_inner_bind N1 N2 Kₛ eₛ Kₜ eₜ Φ :
        NonExpansive N1 →
        NonExpansive N2 →
        sim_inner N1 (λ eₛ' eₜ', sim_inner N2 Φ (Kₛ @@ eₛ') (Kₜ @@ eₜ')) eₛ eₜ -∗
        ( ∀ eₛ' eₜ',
          N1 (λ eₛ' eₜ', sim_inner N2 Φ (Kₛ @@ eₛ') (Kₜ @@ eₜ')) eₛ' eₜ' -∗
          N2 Φ (Kₛ @@ eₛ') (Kₜ @@ eₜ')
        ) -∗
        sim_inner N2 Φ (Kₛ @@ eₛ) (Kₜ @@ eₜ).
      Proof.
        iIntros "%HN1 %HN2 Hsim HN".
        iApply (sim_inner_bind' with "Hsim HN"). auto.
      Qed.
      Lemma sim_inner_bindₛ' N1 N2 K eₛ eₜ Φ1 Φ2 :
        NonExpansive N1 →
        NonExpansive N2 →
        sim_inner N1 Φ1 eₛ eₜ -∗
        ( ∀ eₛ' eₜ',
          N1 Φ1 eₛ' eₜ' -∗
          N2 Φ2 (K @@ eₛ') eₜ'
        ) -∗
        ( ∀ eₛ' eₜ',
          Φ1 eₛ' eₜ' -∗
          sim_inner N2 Φ2 (K @@ eₛ') eₜ'
        ) -∗
        sim_inner N2 Φ2 (K @@ eₛ) eₜ.
      Proof.
        iIntros "%HN1 %HN2 Hsim1 HN Hsim2".
        iEval(rewrite -(fill_empty eₜ)).
        iApply (sim_inner_bind' with "Hsim1 [HN] [Hsim2]").
        - iIntros "%eₛ' %eₜ' HN1".
          rewrite fill_empty. iApply ("HN" with "HN1").
        - iIntros "%eₛ' %eₜ' HΦ1".
          rewrite fill_empty. iApply ("Hsim2" with "HΦ1").
      Qed.
      Lemma sim_inner_bindₛ N1 N2 K eₛ eₜ Φ :
        NonExpansive N1 →
        NonExpansive N2 →
        sim_inner N1 (λ eₛ' eₜ', sim_inner N2 Φ (K @@ eₛ') eₜ') eₛ eₜ -∗
        ( ∀ eₛ' eₜ',
          N1 (λ eₛ' eₜ', sim_inner N2 Φ (K @@ eₛ') eₜ') eₛ' eₜ' -∗
          N2 Φ (K @@ eₛ') eₜ'
        ) -∗
        sim_inner N2 Φ (K @@ eₛ) eₜ.
      Proof.
        iIntros "%HN1 %HN2 Hsim HN".
        iApply (sim_inner_bindₛ' with "Hsim HN"). auto.
      Qed.
      Lemma sim_inner_bindₜ' N1 N2 eₛ K eₜ Φ1 Φ2 :
        NonExpansive N1 →
        NonExpansive N2 →
        sim_inner N1 Φ1 eₛ eₜ -∗
        ( ∀ eₛ' eₜ',
          N1 Φ1 eₛ' eₜ' -∗
          N2 Φ2 eₛ' (K @@ eₜ')
        ) -∗
        ( ∀ eₛ' eₜ',
          Φ1 eₛ' eₜ' -∗
          sim_inner N2 Φ2 eₛ' (K @@ eₜ')
        ) -∗
        sim_inner N2 Φ2 eₛ (K @@ eₜ).
      Proof.
        iIntros "%HN1 %HN2 Hsim1 HN Hsim2".
        iEval(rewrite -(fill_empty eₛ)).
        iApply (sim_inner_bind' with "Hsim1 [HN] [Hsim2]").
        - iIntros "%eₛ' %eₜ' HN1".
          rewrite fill_empty. iApply ("HN" with "HN1").
        - iIntros "%eₛ' %eₜ' HΦ1".
          rewrite fill_empty. iApply ("Hsim2" with "HΦ1").
      Qed.
      Lemma sim_inner_bindₜ N1 N2 eₛ K eₜ Φ :
        NonExpansive N1 →
        NonExpansive N2 →
        sim_inner N1 (λ eₛ' eₜ', sim_inner N2 Φ eₛ' (K @@ eₜ')) eₛ eₜ -∗
        ( ∀ eₛ' eₜ',
          N1 (λ eₛ' eₜ', sim_inner N2 Φ eₛ' (K @@ eₜ')) eₛ' eₜ' -∗
          N2 Φ eₛ' (K @@ eₜ')
        ) -∗
        sim_inner N2 Φ eₛ (K @@ eₜ).
      Proof.
        iIntros "%HN1 %HN2 Hsim HN".
        iApply (sim_inner_bindₜ' with "Hsim HN"). auto.
      Qed.

      (* TODO: sim_inner_bind_inv *)
      (* TODO: sim_inner_bind_invₛ *)
      (* TODO: sim_inner_bind_invₜ *)

      (* TODO: sim_inner_decompose *)

      Lemma sim_inner_stepsₛ N eₛ eₜ Φ :
        NonExpansive N →
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ∃ eₛ' σₛ',
            ⌜tc (step sim_progₛ) (eₛ, σₛ) (eₛ', σₛ')⌝ ∗
            sim_state_interp σₛ' σₜ ∗
            sim_inner N Φ eₛ' eₜ
        ) -∗
        sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_stepsₛ.
      Qed.
      Lemma sim_inner_stepₛ N eₛ eₜ Φ :
        NonExpansive N →
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ∃ eₛ' σₛ',
            ⌜prim_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
            sim_state_interp σₛ' σₜ ∗
            sim_inner N Φ eₛ' eₜ
        ) -∗
        sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_stepₛ.
      Qed.
      Lemma sim_inner_head_stepₛ N eₛ eₜ Φ :
        NonExpansive N →
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ∃ eₛ' σₛ',
            ⌜head_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
            sim_state_interp σₛ' σₜ ∗
            sim_inner N Φ eₛ' eₜ
        ) -∗
        sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_head_stepₛ.
      Qed.
      Lemma sim_inner_pure_stepsₛ N eₛ1 eₛ2 eₜ Φ :
        NonExpansive N →
        rtc (pure_step sim_progₛ) eₛ1 eₛ2 →
        sim_inner N Φ eₛ2 eₜ -∗
        sim_inner N Φ eₛ1 eₜ.
      Proof.
        intros HN [-> | Hstepsₛ]%rtc_tc; first done.
        setoid_rewrite sim_inner_fixpoint at 2; first apply sim_body_pure_stepsₛ; done.
      Qed.
      Lemma sim_inner_pure_stepₛ N eₛ1 eₛ2 eₜ Φ :
        NonExpansive N →
        pure_step sim_progₛ eₛ1 eₛ2 →
        sim_inner N Φ eₛ2 eₜ -∗
        sim_inner N Φ eₛ1 eₜ.
      Proof.
        intros HN.
        setoid_rewrite sim_inner_fixpoint at 2; [apply sim_body_pure_stepₛ | done].
      Qed.
      Lemma sim_inner_pure_head_stepsₛ N eₛ1 eₛ2 eₜ Φ :
        NonExpansive N →
        rtc (pure_head_step sim_progₛ) eₛ1 eₛ2 →
        sim_inner N Φ eₛ2 eₜ -∗
        sim_inner N Φ eₛ1 eₜ.
      Proof.
        intros HN [-> | Hstepsₛ]%rtc_tc; first done.
        setoid_rewrite sim_inner_fixpoint at 2; first apply sim_body_pure_head_stepsₛ; done.
      Qed.
      Lemma sim_inner_pure_head_stepₛ N eₛ1 eₛ2 eₜ Φ :
        NonExpansive N →
        pure_head_step sim_progₛ eₛ1 eₛ2 →
        sim_inner N Φ eₛ2 eₜ -∗
        sim_inner N Φ eₛ1 eₜ.
      Proof.
        intros HN.
        setoid_rewrite sim_inner_fixpoint at 2; [apply sim_body_pure_head_stepₛ | done].
      Qed.

      Lemma sim_inner_stepₜ N eₛ eₜ Φ :
        NonExpansive N →
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                sim_state_interp σₛ σₜ' ∗
                sim_inner N Φ eₛ eₜ'
        ) -∗
        sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_stepₜ.
      Qed.
      Lemma sim_inner_head_stepₜ N eₛ eₜ Φ :
        NonExpansive N →
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜head_reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜head_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                sim_state_interp σₛ σₜ' ∗
                sim_inner N Φ eₛ eₜ'
        ) -∗
        sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_head_stepₜ.
      Qed.
      Lemma sim_inner_pure_stepₜ N eₛ eₜ1 eₜ2 Φ :
        NonExpansive N →
        pure_step sim_progₜ eₜ1 eₜ2 →
        sim_inner N Φ eₛ eₜ2 -∗
        sim_inner N Φ eₛ eₜ1.
      Proof.
        intros HN.
        setoid_rewrite sim_inner_fixpoint at 2; [apply sim_body_pure_stepₜ | done].
      Qed.
      Lemma sim_inner_pure_stepsₜ N eₛ eₜ1 eₜ2 Φ :
        NonExpansive N →
        rtc (pure_step sim_progₜ) eₜ1 eₜ2 →
        sim_inner N Φ eₛ eₜ2 -∗
        sim_inner N Φ eₛ eₜ1.
      Proof.
        intros HN.
        induction 1 as [| eₜ eₜ' eₜ'' Hstepₜ Hstepsₜ IH]; first done.
        rewrite IH. apply sim_inner_pure_stepₜ; done.
      Qed.
      Lemma sim_inner_pure_head_stepₜ N eₛ eₜ1 eₜ2 Φ :
        NonExpansive N →
        pure_head_step sim_progₜ eₜ1 eₜ2 →
        sim_inner N Φ eₛ eₜ2 -∗
        sim_inner N Φ eₛ eₜ1.
      Proof.
        intros HN.
        setoid_rewrite sim_inner_fixpoint at 2; [apply sim_body_pure_head_stepₜ | done].
      Qed.
      Lemma sim_inner_pure_head_stepsₜ N eₛ eₜ1 eₜ2 Φ :
        NonExpansive N →
        rtc (pure_head_step sim_progₜ) eₜ1 eₜ2 →
        sim_inner N Φ eₛ eₜ2 -∗
        sim_inner N Φ eₛ eₜ1.
      Proof.
        intros HN.
        induction 1 as [| eₜ eₜ' eₜ'' Hstepₜ Hstepsₜ IH]; first done.
        rewrite IH. apply sim_inner_pure_head_stepₜ; done.
      Qed.

      Lemma sim_inner_steps N eₛ eₜ Φ :
        NonExpansive N →
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                ∃ eₛ' σₛ',
                ⌜tc (step sim_progₛ) (eₛ, σₛ) (eₛ', σₛ')⌝ ∗
                sim_state_interp σₛ' σₜ' ∗
                N Φ eₛ' eₜ'
        ) -∗
        sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_steps.
      Qed.
      Lemma sim_inner_step N eₛ eₜ Φ :
        NonExpansive N →
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                ∃ eₛ' σₛ',
                ⌜prim_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
                sim_state_interp σₛ' σₜ' ∗
                N Φ eₛ' eₜ'
        ) -∗
        sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_step.
      Qed.
      Lemma sim_inner_head_step N eₛ eₜ Φ :
        NonExpansive N →
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜head_reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜head_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                ∃ eₛ' σₛ',
                ⌜head_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
                sim_state_interp σₛ' σₜ' ∗
                N Φ eₛ' eₜ'
        ) -∗
        sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_head_step.
      Qed.
      Lemma sim_inner_pure_steps N eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        NonExpansive N →
        tc (pure_step sim_progₛ) eₛ1 eₛ2 →
        pure_step sim_progₜ eₜ1 eₜ2 →
        N Φ eₛ2 eₜ2 -∗
        sim_inner N Φ eₛ1 eₜ1.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_pure_steps.
      Qed.
      Lemma sim_inner_pure_step N eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        NonExpansive N →
        pure_step sim_progₛ eₛ1 eₛ2 →
        pure_step sim_progₜ eₜ1 eₜ2 →
        N Φ eₛ2 eₜ2 -∗
        sim_inner N Φ eₛ1 eₜ1.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_pure_step.
      Qed.
      Lemma sim_inner_pure_head_steps N eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        NonExpansive N →
        tc (pure_head_step sim_progₛ) eₛ1 eₛ2 →
        pure_head_step sim_progₜ eₜ1 eₜ2 →
        N Φ eₛ2 eₜ2 -∗
        sim_inner N Φ eₛ1 eₜ1.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_pure_head_steps.
      Qed.
      Lemma sim_inner_pure_head_step N eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        NonExpansive N →
        pure_head_step sim_progₛ eₛ1 eₛ2 →
        pure_head_step sim_progₜ eₜ1 eₜ2 →
        N Φ eₛ2 eₜ2 -∗
        sim_inner N Φ eₛ1 eₜ1.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_pure_head_step.
      Qed.

      Lemma sim_inner_apply_protocol Ψ Kₛ eₛ' Kₜ eₜ' N eₛ eₜ Φ :
        NonExpansive N →
        eₛ = Kₛ @@ eₛ' →
        eₜ = Kₜ @@ eₜ' →
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            X Ψ eₛ' eₜ' ∗
            sim_state_interp σₛ σₜ ∗
              ∀ eₛ eₜ,
              Ψ eₛ eₜ ++∗
              N Φ (Kₛ @@ eₛ) (Kₜ @@ eₜ)

        ) -∗
        sim_inner N Φ eₛ eₜ.
      Proof.
        intros HN.
        rewrite sim_inner_fixpoint. apply sim_body_apply_protocol.
      Qed.
    End sim_inner.

    Section sim.
      #[local] Instance sim_inner'_ne n :
        Proper (
          ((≡{n}≡) ==> (≡{n}≡)) ==>
          (≡{n}≡) ==>
          (≡{n}≡)
        ) sim_inner'.
      Proof.
        intros N1 N2 HN ((Φ1 & eₛ1) & eₜ1) ((Φ2 & eₛ2) & eₜ2) ((HΦ & Heₛ%leibniz_equiv) & Heₜ%leibniz_equiv).
        simpl in HΦ, Heₛ, Heₜ. subst.
        apply sim_inner_ne; done || solve_proper.
      Qed.
      #[local] Instance sim_inner'_proper :
        Proper (
          ((≡) ==> (≡)) ==>
          (≡) ==>
          (≡)
        ) sim_inner'.
      Proof.
        intros N1 N2 HN ((Φ1 & eₛ1) & eₜ1) ((Φ2 & eₛ2) & eₜ2) ((HΦ & Heₛ%leibniz_equiv) & Heₜ%leibniz_equiv).
        simpl in HΦ, Heₛ, Heₜ. subst.
        apply sim_inner_proper; done || solve_proper.
      Qed.
      #[local] Instance sim_inner'_mono_pred :
        BiMonoPred sim_inner'.
      Proof.
        split.
        - iIntros "%N1 %N2 %HN1 %HN2 #HN" (((Φ & eₛ) & eₜ)) "Hsim".
          iApply (sim_inner_mono with "[] Hsim"); first solve_proper. clear Φ eₛ eₜ. iIntros "!> %Φ %eₛ %eₜ HN1".
          iApply ("HN" with "HN1").
        - intros N HN n ((Φ1 & eₛ1) & eₜ1) ((Φ2 & eₛ2) & eₜ2) ((HΦ & Heₛ%leibniz_equiv) & Heₜ%leibniz_equiv).
          rewrite /sim_inner' /=.
          apply sim_inner_ne; solve_proper.
      Qed.

      #[global] Instance sim_ne n :
        Proper ((≡{n}≡) ==> (=) ==> (=) ==> (≡{n}≡)) sim.
      Proof.
        rewrite definition.sim_unseal.
        solve_proper.
      Qed.
      #[global] Instance sim_proper :
        Proper ((≡) ==> (=) ==> (=) ==> (≡)) sim.
      Proof.
        rewrite definition.sim_unseal.
        solve_proper.
      Qed.

      Lemma sim_fixpoint Φ eₛ eₜ :
        sim Φ eₛ eₜ ⊣⊢
        sim_inner sim Φ eₛ eₜ.
      Proof.
        rewrite definition.sim_unseal.
        setoid_rewrite greatest_fixpoint_unfold; [done | apply _].
      Qed.
      Lemma sim_unfold :
        sim ---∗ sim_inner sim.
      Proof.
        setoid_rewrite sim_fixpoint. auto.
      Qed.
      Lemma sim_fold :
        sim_inner sim ---∗ sim.
      Proof.
        setoid_rewrite sim_fixpoint. auto.
      Qed.

      Lemma sim_eq Φ eₛ eₜ :
        sim Φ eₛ eₜ ⊣⊢
        sim_body sim sim Φ eₛ eₜ.
      Proof.
        rewrite sim_fixpoint.
        setoid_rewrite sim_inner_fixpoint; last solve_proper.
        rewrite /sim_body. setoid_rewrite <- sim_fixpoint. done.
      Qed.

      Lemma sim_strong_coind I :
        NonExpansive I →
        □ (I ---∗ sim_inner (λ Φ eₛ eₜ, I Φ eₛ eₜ ∨ sim Φ eₛ eₜ)) -∗
        I ---∗ sim.
      Proof.
        rewrite definition.sim_unseal.
        iIntros "%HI #Hind %Φ %eₛ %eₜ HI".
        replace (I Φ eₛ eₜ) with ((uncurry3 I) (Φ, eₛ, eₜ)); last done.
        iApply (greatest_fixpoint_coind with "[] HI"). clear Φ eₛ eₜ. iIntros "!>" (((Φ & eₛ) & eₜ)) "HI /=".
        iApply ("Hind" with "HI").
      Qed.
      Lemma sim_coind I :
        NonExpansive I →
        □ (I ---∗ sim_inner I) -∗
        I ---∗ sim.
      Proof.
        iIntros "%HI #Hind".
        iApply sim_strong_coind. iIntros "!> %Φ %eₛ %eₜ HI".
        iApply (sim_inner_mono with "[] (Hind HI)"); first solve_proper. clear Φ eₛ eₜ. iIntros "!> %Φ %eₛ %eₜ HI".
        iLeft. done.
      Qed.

      Lemma sim_strongly_stuck eₛ eₜ Φ :
        strongly_stuck sim_progₛ eₛ →
        strongly_stuck sim_progₜ eₜ →
        ⊢ sim Φ eₛ eₜ.
      Proof.
        rewrite sim_fixpoint. apply sim_inner_strongly_stuck. solve_proper.
      Qed.
      Lemma sim_strongly_head_stuck eₛ eₜ Φ :
        strongly_head_stuck sim_progₛ eₛ →
        strongly_head_stuck sim_progₜ eₜ →
        ⊢ sim Φ eₛ eₜ.
      Proof.
        rewrite sim_fixpoint. apply sim_inner_strongly_head_stuck. solve_proper.
      Qed.

      Lemma sim_post Φ :
        Φ --∗ sim Φ.
      Proof.
        setoid_rewrite sim_fixpoint. apply sim_inner_post. solve_proper.
      Qed.

      Lemma cupd_sim Φ eₛ eₜ :
        (|++> sim Φ eₛ eₜ) -∗
        sim Φ eₛ eₜ.
      Proof.
        rewrite sim_fixpoint. apply cupd_sim_inner. solve_proper.
      Qed.
      Lemma bupd_sim Φ eₛ eₜ :
        (|==> sim Φ eₛ eₜ) -∗
        sim Φ eₛ eₜ.
      Proof.
        rewrite sim_fixpoint. apply bupd_sim_inner. solve_proper.
      Qed.

      Lemma sim_cupd_mono Φ1 Φ2 :
        (Φ1 +++∗ Φ2) -∗
        sim Φ1 --∗ sim Φ2.
      Proof.
        set I : sim_protocol_O := λ Φ2 eₛ eₜ, (
          ∃ Φ1,
          (Φ1 +++∗ Φ2) ∗
          sim Φ1 eₛ eₜ
        )%I.
        assert (NonExpansive I) by solve_proper.
        cut (I Φ2 --∗ sim Φ2).
        { iIntros "%HI HΦ %eₛ %eₜ Hsim".
          iApply HI. iExists Φ1. iFrame.
        }
        iApply (sim_coind with "[]"). clear Φ1 Φ2. iIntros "!> %Φ2 %eₛ %eₜ (%Φ1 & HΦ & Hsim)".
        rewrite sim_fixpoint.
        iApply (sim_inner_strong_cupd_mono with "[] HΦ Hsim"); first solve_proper. clear eₛ eₜ. iIntros "!> HΦ %eₛ %eₜ Hsim".
        iExists Φ1. iFrame. auto.
      Qed.
      Lemma sim_bupd_mono Φ1 Φ2 :
        (Φ1 ===∗ Φ2) -∗
        sim Φ1 --∗ sim Φ2.
      Proof.
        iIntros "HΦ".
        iApply sim_cupd_mono. iIntros "%eₛ %eₜ HΦ1".
        iMod ("HΦ" with "HΦ1") as "HΦ2". done.
      Qed.
      Lemma sim_mono Φ1 Φ2 :
        (Φ1 --∗ Φ2) -∗
        sim Φ1 --∗ sim Φ2.
      Proof.
        iIntros "HΦ".
        iApply sim_bupd_mono. iIntros "%eₛ %eₜ HΦ1".
        iApply ("HΦ" with "HΦ1").
      Qed.
      Lemma sim_mono' eₛ eₜ Φ1 Φ2 :
        sim Φ1 eₛ eₜ -∗
        (Φ1 --∗ Φ2) -∗
        sim Φ2 eₛ eₜ.
      Proof.
        iIntros "Hsim HΦ".
        iApply (sim_mono with "HΦ Hsim").
      Qed.

      Lemma sim_cupd Φ :
        sim (λ eₛ eₜ, |++> Φ eₛ eₜ) --∗ sim Φ.
      Proof.
        iApply (sim_cupd_mono with "[]"). auto.
      Qed.
      Lemma sim_bupd Φ :
        sim (λ eₛ eₜ, |==> Φ eₛ eₜ) --∗ sim Φ.
      Proof.
        iApply (sim_bupd_mono with "[]"). auto.
      Qed.

      Lemma sim_frame_l R eₛ eₜ Φ :
        R ∗ sim Φ eₛ eₜ -∗
        sim (λ eₛ eₜ, R ∗ Φ eₛ eₜ) eₛ eₜ.
      Proof.
        iIntros "(HR & Hsim)".
        iApply (sim_mono with "[HR] Hsim"). auto with iFrame.
      Qed.
      Lemma sim_frame_r R eₛ eₜ Φ :
        sim Φ eₛ eₜ ∗ R -∗
        sim (λ eₛ eₜ, Φ eₛ eₜ ∗ R) eₛ eₜ.
      Proof.
        iIntros "(Hsim & HR)".
        iApply (sim_mono with "[HR] Hsim"). auto with iFrame.
      Qed.

      Lemma sim_bind Kₛ eₛ Kₜ eₜ Φ :
        SIM eₛ ≳ eₜ [[ X ]] {{ λ eₛ' eₜ',
          SIM Kₛ @@ eₛ' ≳ Kₜ @@ eₜ' [[ X ]] {{ Φ }}
        }} -∗
        SIM Kₛ @@ eₛ ≳ Kₜ @@ eₜ [[ X ]] {{ Φ }}.
      Proof.
        set I : sim_protocol_O := λ Φ eₛ'' eₜ'', (
          ∃ Kₛ eₛ Kₜ eₜ,
          ⌜eₛ'' = Kₛ @@ eₛ ∧ eₜ'' = Kₜ @@ eₜ⌝ ∗
          SIM eₛ ≳ eₜ [[ X ]] {{ λ eₛ' eₜ',
            SIM Kₛ @@ eₛ' ≳ Kₜ @@ eₜ' [[ X ]] {{ Φ }}
          }}
        )%I.
        assert (NonExpansive I) as HI by solve_proper+.
        enough (∀ eₛ eₜ, I Φ eₛ eₜ -∗ SIM eₛ ≳ eₜ [[ X ]] {{ Φ }}) as H.
        { iIntros "Hsim". iApply H. iExists Kₛ, eₛ, Kₜ, eₜ. auto. }
        iApply (sim_coind with "[]"). clear Φ Kₛ eₛ Kₜ eₜ. iIntros "!> %Φ %eₛ'' %eₜ'' (%Kₛ & %eₛ & %Kₜ & %eₜ & (-> & ->) & Hsim)".
        rewrite sim_fixpoint. iApply (sim_inner_bind' with "Hsim"); first solve_proper.
        - iIntros "%eₛ' %eₜ' Hsim ".
          iExists Kₛ, eₛ', Kₜ, eₜ'. auto.
        - iIntros "%eₛ' %eₜ' Hsim".
          rewrite sim_fixpoint. iApply (sim_inner_mono with "[] Hsim"). clear Φ eₛ eₜ. iIntros "!> %Φ %eₛ %eₜ Hsim".
          iExists ∅, eₛ, ∅, eₜ. iSplit; first rewrite !fill_empty //.
          iApply sim_post. rewrite !fill_empty //.
      Qed.
      Lemma sim_bind' Kₛ eₛ Kₜ eₜ Φ1 Φ2 :
        SIM eₛ ≳ eₜ [[ X ]] {{ Φ1 }} -∗
        ( ∀ eₛ' eₜ',
          Φ1 eₛ' eₜ' -∗
          SIM Kₛ @@ eₛ' ≳ Kₜ @@ eₜ' [[ X ]] {{ Φ2 }}
        ) -∗
        SIM Kₛ @@ eₛ ≳ Kₜ @@ eₜ [[ X ]] {{ Φ2 }}.
      Proof.
        iIntros "Hsim HΦ1".
        iApply sim_bind. iApply (sim_mono with "HΦ1 Hsim").
      Qed.
      Lemma sim_bindₛ K eₛ eₜ Φ :
        SIM eₛ ≳ eₜ [[ X ]] {{ λ eₛ' eₜ',
          SIM K @@ eₛ' ≳ eₜ' [[ X ]] {{ Φ }}
        }} -∗
        SIM K @@ eₛ ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        rewrite -{2}(fill_empty eₜ) -(sim_bind ∅).
        iApply (sim_mono with "[]"). iIntros "%eₛ' %eₜ'".
        rewrite fill_empty. auto.
      Qed.
      Lemma sim_bindₜ eₛ K eₜ Φ :
        SIM eₛ ≳ eₜ [[ X ]] {{ λ eₛ' eₜ',
          SIM eₛ' ≳ K @@ eₜ' [[ X ]] {{ Φ }}
        }} -∗
        SIM eₛ ≳ K @@ eₜ [[ X ]] {{ Φ }}.
      Proof.
        rewrite -{2}(fill_empty eₛ) -(sim_bind ∅).
        iApply (sim_mono with "[]"). iIntros "%eₛ' %eₜ'".
        rewrite fill_empty. auto.
      Qed.

      Lemma sim_bind_inv Kₛ eₛ Kₜ eₜ Φ :
        SIM Kₛ @@ eₛ ≳ Kₜ @@ eₜ [[ X ]] {{ Φ }} -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ λ eₛ' eₜ',
          SIM Kₛ @@ eₛ' ≳ Kₜ @@ eₜ' [[ X ]] {{ Φ }}
        }}.
      Proof.
        iIntros "Hsim". iApply sim_post. done.
      Qed.
      Lemma sim_bind_invₛ K eₛ eₜ Φ :
        SIM K @@ eₛ ≳ eₜ [[ X ]] {{ Φ }} -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ λ eₛ' eₜ',
          SIM K @@ eₛ' ≳ eₜ' [[ X ]] {{ Φ }}
        }}.
      Proof.
        iIntros "Hsim". iApply sim_post. done.
      Qed.
      Lemma sim_bind_invₜ eₛ K eₜ Φ :
        SIM eₛ ≳ K @@ eₜ [[ X ]] {{ Φ }} -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ λ eₛ' eₜ',
          SIM eₛ' ≳ K @@ eₜ' [[ X ]] {{ Φ }}
        }}.
      Proof.
        iIntros "Hsim". iApply sim_post. done.
      Qed.

      Lemma sim_decompose eₛ eₜ Φ1 Φ2 :
        SIM eₛ ≳ eₜ [[ X ]] {{ Φ1 }} -∗
        ( ∀ eₛ' eₜ',
          Φ1 eₛ' eₜ' -∗
          SIM eₛ' ≳ eₜ' [[ X ]] {{ Φ2 }}
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ Φ2 }}.
      Proof.
        iIntros "Hsim1 Hsim2".
        iEval (rewrite -(fill_empty eₛ) -(fill_empty eₜ)). iApply sim_bind.
        iApply (sim_mono with "[Hsim2] Hsim1").
        setoid_rewrite fill_empty. iApply "Hsim2".
      Qed.

      Lemma sim_stepsₛ eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ∃ eₛ' σₛ',
            ⌜tc (step sim_progₛ) (eₛ, σₛ) (eₛ', σₛ')⌝ ∗
            sim_state_interp σₛ' σₜ ∗
            SIM eₛ' ≳ eₜ [[ X ]] {{ Φ }}
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        setoid_rewrite sim_fixpoint. apply sim_inner_stepsₛ. solve_proper.
      Qed.
      Lemma sim_stepₛ eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ∃ eₛ' σₛ',
            ⌜prim_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
            sim_state_interp σₛ' σₜ ∗
            SIM eₛ' ≳ eₜ [[ X ]] {{ Φ }}
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        setoid_rewrite sim_fixpoint. apply sim_inner_stepₛ. solve_proper.
      Qed.
      Lemma sim_head_stepₛ eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ∃ eₛ' σₛ',
            ⌜head_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
            sim_state_interp σₛ' σₜ ∗
            SIM eₛ' ≳ eₜ [[ X ]] {{ Φ }}
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        setoid_rewrite sim_fixpoint. apply sim_inner_head_stepₛ. solve_proper.
      Qed.
      Lemma sim_pure_stepsₛ eₛ1 eₛ2 eₜ Φ :
        rtc (pure_step sim_progₛ) eₛ1 eₛ2 →
        SIM eₛ2 ≳ eₜ [[ X ]] {{ Φ }} -∗
        SIM eₛ1 ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        rewrite !sim_fixpoint. apply sim_inner_pure_stepsₛ. solve_proper.
      Qed.
      Lemma sim_pure_stepₛ eₛ1 eₛ2 eₜ Φ :
        pure_step sim_progₛ eₛ1 eₛ2 →
        SIM eₛ2 ≳ eₜ [[ X ]] {{ Φ }} -∗
        SIM eₛ1 ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        rewrite !sim_fixpoint. apply sim_inner_pure_stepₛ. solve_proper.
      Qed.
      Lemma sim_pure_head_stepsₛ eₛ1 eₛ2 eₜ Φ :
        rtc (pure_head_step sim_progₛ) eₛ1 eₛ2 →
        SIM eₛ2 ≳ eₜ [[ X ]] {{ Φ }} -∗
        SIM eₛ1 ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        rewrite !sim_fixpoint. apply sim_inner_pure_head_stepsₛ. solve_proper.
      Qed.
      Lemma sim_pure_head_stepₛ eₛ1 eₛ2 eₜ Φ :
        pure_head_step sim_progₛ eₛ1 eₛ2 →
        SIM eₛ2 ≳ eₜ [[ X ]] {{ Φ }} -∗
        SIM eₛ1 ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        rewrite !sim_fixpoint. apply sim_inner_pure_head_stepₛ. solve_proper.
      Qed.

      Lemma sim_stepₜ eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                sim_state_interp σₛ σₜ' ∗
                SIM eₛ ≳ eₜ' [[ X ]] {{ Φ }}
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        setoid_rewrite sim_fixpoint. apply sim_inner_stepₜ. solve_proper.
      Qed.
      Lemma sim_head_stepₜ eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜head_reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜head_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                sim_state_interp σₛ σₜ' ∗
                SIM eₛ ≳ eₜ' [[ X ]] {{ Φ }}
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        setoid_rewrite sim_fixpoint. apply sim_inner_head_stepₜ. solve_proper.
      Qed.
      Lemma sim_pure_stepsₜ eₛ eₜ1 eₜ2 Φ :
        rtc (pure_step sim_progₜ) eₜ1 eₜ2 →
        SIM eₛ ≳ eₜ2 [[ X ]] {{ Φ }} -∗
        SIM eₛ ≳ eₜ1 [[ X ]] {{ Φ }}.
      Proof.
        rewrite !sim_fixpoint. apply sim_inner_pure_stepsₜ. solve_proper.
      Qed.
      Lemma sim_pure_stepₜ eₛ eₜ1 eₜ2 Φ :
        pure_step sim_progₜ eₜ1 eₜ2 →
        SIM eₛ ≳ eₜ2 [[ X ]] {{ Φ }} -∗
        SIM eₛ ≳ eₜ1 [[ X ]] {{ Φ }}.
      Proof.
        rewrite !sim_fixpoint. apply sim_inner_pure_stepₜ. solve_proper.
      Qed.
      Lemma sim_pure_head_stepsₜ eₛ eₜ1 eₜ2 Φ :
        rtc (pure_head_step sim_progₜ) eₜ1 eₜ2 →
        SIM eₛ ≳ eₜ2 [[ X ]] {{ Φ }} -∗
        SIM eₛ ≳ eₜ1 [[ X ]] {{ Φ }}.
      Proof.
        rewrite !sim_fixpoint. apply sim_inner_pure_head_stepsₜ. solve_proper.
      Qed.
      Lemma sim_pure_head_stepₜ eₛ eₜ1 eₜ2 Φ :
        pure_head_step sim_progₜ eₜ1 eₜ2 →
        SIM eₛ ≳ eₜ2 [[ X ]] {{ Φ }} -∗
        SIM eₛ ≳ eₜ1 [[ X ]] {{ Φ }}.
      Proof.
        rewrite !sim_fixpoint. apply sim_inner_pure_head_stepₜ. solve_proper.
      Qed.

      Lemma sim_steps eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                ∃ eₛ' σₛ',
                ⌜tc (step sim_progₛ) (eₛ, σₛ) (eₛ', σₛ')⌝ ∗
                sim_state_interp σₛ' σₜ' ∗
                SIM eₛ' ≳ eₜ' [[ X ]] {{ Φ }}
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        rewrite sim_fixpoint. apply sim_inner_steps. solve_proper.
      Qed.
      Lemma sim_step eₛ eₜ Φ :
        ( ∀ σₛ σₜ, sim_state_interp σₛ σₜ ==∗
            ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                ∃ eₛ' σₛ',
                ⌜prim_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
                sim_state_interp σₛ' σₜ' ∗
                SIM eₛ' ≳ eₜ' [[ X ]] {{ Φ }}
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        rewrite sim_fixpoint. apply sim_inner_step. solve_proper.
      Qed.
      Lemma sim_head_step eₛ eₜ Φ :
        ( ∀ σₛ σₜ, sim_state_interp σₛ σₜ ==∗
            ⌜head_reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜head_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                ∃ eₛ' σₛ',
                ⌜head_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
                sim_state_interp σₛ' σₜ' ∗
                SIM eₛ' ≳ eₜ' [[ X ]] {{ Φ }}
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        rewrite sim_fixpoint. apply sim_inner_head_step. solve_proper.
      Qed.
      Lemma sim_pure_steps eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        rtc (pure_step sim_progₛ) eₛ1 eₛ2 →
        rtc (pure_step sim_progₜ) eₜ1 eₜ2 →
        SIM eₛ2 ≳ eₜ2 [[ X ]] {{ Φ }} -∗
        SIM eₛ1 ≳ eₜ1 [[ X ]] {{ Φ }}.
      Proof.
        intros. rewrite sim_pure_stepsₛ // sim_pure_stepsₜ //.
      Qed.
      Lemma sim_pure_step eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        pure_step sim_progₛ eₛ1 eₛ2 →
        pure_step sim_progₜ eₜ1 eₜ2 →
        SIM eₛ2 ≳ eₜ2 [[ X ]] {{ Φ }} -∗
        SIM eₛ1 ≳ eₜ1 [[ X ]] {{ Φ }}.
      Proof.
        intros. rewrite sim_pure_stepₛ // sim_pure_stepₜ //.
      Qed.
      Lemma sim_pure_head_steps eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        rtc (pure_head_step sim_progₛ) eₛ1 eₛ2 →
        rtc (pure_head_step sim_progₜ) eₜ1 eₜ2 →
        SIM eₛ2 ≳ eₜ2 [[ X ]] {{ Φ }} -∗
        SIM eₛ1 ≳ eₜ1 [[ X ]] {{ Φ }}.
      Proof.
        intros. rewrite sim_pure_head_stepsₛ // sim_pure_head_stepsₜ //.
      Qed.
      Lemma sim_pure_head_step eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        pure_head_step sim_progₛ eₛ1 eₛ2 →
        pure_head_step sim_progₜ eₜ1 eₜ2 →
        SIM eₛ2 ≳ eₜ2 [[ X ]] {{ Φ }} -∗
        SIM eₛ1 ≳ eₜ1 [[ X ]] {{ Φ }}.
      Proof.
        intros. rewrite sim_pure_head_stepₛ // sim_pure_head_stepₜ //.
      Qed.

      Lemma sim_apply_protocol Ψ eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            X Ψ eₛ eₜ ∗
            sim_state_interp σₛ σₜ ∗
              ∀ eₛ eₜ,
              Ψ eₛ eₜ -∗
              SIM eₛ ≳ eₜ [[ X ]] {{ Φ }}
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] {{ Φ }}.
      Proof.
        rewrite sim_fixpoint. iIntros "Hsim".
        iApply (sim_inner_apply_protocol Ψ ∅ _ ∅); [solve_proper | rewrite fill_empty //.. |].
        iIntros "%σₛ %σₜ Hsi".
        iMod ("Hsim" with "Hsi") as "($ & $ & Hsim)".
        clear eₛ eₜ. iIntros "!> %eₛ %eₜ HΨ !>".
        rewrite !fill_empty. iApply ("Hsim" with "HΨ").
      Qed.
    End sim.

    Section simv.
      Lemma simv_strongly_stuck eₛ eₜ Φ :
        strongly_stuck sim_progₛ eₛ →
        strongly_stuck sim_progₜ eₜ →
        ⊢ simv Φ eₛ eₜ.
      Proof.
        rewrite definition.simv_unseal. apply sim_strongly_stuck.
      Qed.
      Lemma simv_strongly_head_stuck eₛ eₜ Φ :
        strongly_head_stuck sim_progₛ eₛ →
        strongly_head_stuck sim_progₜ eₜ →
        ⊢ simv Φ eₛ eₜ.
      Proof.
        intros.
        apply simv_strongly_stuck; apply strongly_head_stuck_strongly_stuck; done.
      Qed.

      Lemma simv_post vₛ vₜ eₛ eₜ Φ :
        eₛ = of_val vₛ →
        eₜ = of_val vₜ →
        Φ vₛ vₜ -∗
        simv Φ eₛ eₜ.
      Proof.
        rewrite definition.simv_unseal.
        iIntros (-> ->) "HΦ".
        iApply sim_post. iExists vₛ, vₜ. auto.
      Qed.

      Lemma cupd_simv Φ eₛ eₜ :
        (|++> simv Φ eₛ eₜ) -∗
        simv Φ eₛ eₜ.
      Proof.
        rewrite definition.simv_unseal. apply cupd_sim.
      Qed.
      Lemma bupd_simv Φ eₛ eₜ :
        (|==> simv Φ eₛ eₜ) -∗
        simv Φ eₛ eₜ.
      Proof.
        rewrite definition.simv_unseal. apply bupd_sim.
      Qed.

      Lemma simv_cupd_mono Φ1 Φ2 :
        (Φ1 +++∗ Φ2) -∗
        simv Φ1 --∗ simv Φ2.
      Proof.
        rewrite definition.simv_unseal -sim_cupd_mono.
        iIntros "HΦ %eₛ %eₜ (%vₛ & %vₜ & (-> & ->) & HΦ1)".
        iExists vₛ, vₜ. iSplitR; first done. iApply ("HΦ" with "HΦ1").
      Qed.
      Lemma simv_bupd_mono Φ1 Φ2 :
        (Φ1 ===∗ Φ2) -∗
        simv Φ1 --∗ simv Φ2.
      Proof.
        iIntros "HΦ".
        iApply simv_cupd_mono. iIntros "%eₛ %eₜ HΦ1".
        iMod ("HΦ" with "HΦ1") as "HΦ2". done.
      Qed.
      Lemma simv_mono Φ1 Φ2 :
        (Φ1 --∗ Φ2) -∗
        simv Φ1 --∗ simv Φ2.
      Proof.
        iIntros "HΦ".
        iApply simv_bupd_mono. iIntros "%eₛ %eₜ HΦ1".
        iApply ("HΦ" with "HΦ1").
      Qed.
      Lemma simv_mono' eₛ eₜ Φ1 Φ2 :
        simv Φ1 eₛ eₜ -∗
        (Φ1 --∗ Φ2) -∗
        simv Φ2 eₛ eₜ.
      Proof.
        iIntros "Hsim HΦ".
        iApply (simv_mono with "HΦ Hsim").
      Qed.

      Lemma simv_cupd Φ :
        simv (λ eₛ eₜ, |++> Φ eₛ eₜ) --∗ simv Φ.
      Proof.
        iApply (simv_cupd_mono with "[]"). auto.
      Qed.
      Lemma simv_bupd Φ :
        simv (λ eₛ eₜ, |==> Φ eₛ eₜ) --∗ simv Φ.
      Proof.
        iApply (simv_bupd_mono with "[]"). auto.
      Qed.

      Lemma simv_frame_l R eₛ eₜ Φ :
        R ∗ simv Φ eₛ eₜ -∗
        simv (λ eₛ eₜ, R ∗ Φ eₛ eₜ) eₛ eₜ.
      Proof.
        iIntros "(HR & Hsim)".
        iApply (simv_mono with "[HR] Hsim"). auto with iFrame.
      Qed.
      Lemma simv_frame_r R eₛ eₜ Φ :
        simv Φ eₛ eₜ ∗ R -∗
        simv (λ eₛ eₜ, Φ eₛ eₜ ∗ R) eₛ eₜ.
      Proof.
        iIntros "(Hsim & HR)".
        iApply (simv_mono with "[HR] Hsim"). auto with iFrame.
      Qed.

      Lemma simv_bind Kₛ eₛ Kₜ eₜ Φ :
        SIM eₛ ≳ eₜ [[ X ]] [[ λ vₛ vₜ,
          SIM Kₛ @@ of_val vₛ ≳ Kₜ @@ of_val vₜ [[ X ]] [[ Φ ]]
        ]] -∗
        SIM Kₛ @@ eₛ ≳ Kₜ @@ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal.
        iIntros "Hsim".
        iApply sim_bind. iApply (sim_mono with "[] Hsim"). iIntros "%eₛ' %eₜ' (%vₛ & %vₜ & (-> & ->) & HΦ) //".
      Qed.
      Lemma simv_bindₛ K eₛ eₜ Φ :
        SIM eₛ ≳ eₜ [[ X ]] [[ λ vₛ vₜ,
          SIM K @@ of_val vₛ ≳ of_val vₜ [[ X ]] [[ Φ ]]
        ]] -∗
        SIM K @@ eₛ ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite -{2}(fill_empty eₜ) -(simv_bind ∅).
        iApply (simv_mono with "[]"). iIntros "%eₛ' %eₜ'".
        rewrite fill_empty. auto.
      Qed.
      Lemma simv_bindₜ eₛ K eₜ Φ :
        SIM eₛ ≳ eₜ [[ X ]] [[ λ vₛ vₜ,
          SIM of_val vₛ ≳ K @@ of_val vₜ [[ X ]] [[ Φ ]]
        ]] -∗
        SIM eₛ ≳ K @@ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite -{2}(fill_empty eₛ) -(simv_bind ∅).
        iApply (simv_mono with "[]"). iIntros "%eₛ' %eₜ'".
        rewrite fill_empty. auto.
      Qed.

      Lemma simv_stepsₛ eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ∃ eₛ' σₛ',
            ⌜tc (step sim_progₛ) (eₛ, σₛ) (eₛ', σₛ')⌝ ∗
            sim_state_interp σₛ' σₜ ∗
            SIM eₛ' ≳ eₜ [[ X ]] [[ Φ ]]
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_stepsₛ.
      Qed.
      Lemma simv_stepₛ eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ∃ eₛ' σₛ',
            ⌜prim_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
            sim_state_interp σₛ' σₜ ∗
            SIM eₛ' ≳ eₜ [[ X ]] [[ Φ ]]
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_stepₛ.
      Qed.
      Lemma simv_head_stepₛ eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ∃ eₛ' σₛ',
            ⌜head_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
            sim_state_interp σₛ' σₜ ∗
            SIM eₛ' ≳ eₜ [[ X ]] [[ Φ ]]
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_head_stepₛ.
      Qed.
      Lemma simv_pure_stepsₛ eₛ1 eₛ2 eₜ Φ :
        rtc (pure_step sim_progₛ) eₛ1 eₛ2 →
        SIM eₛ2 ≳ eₜ [[ X ]] [[ Φ ]] -∗
        SIM eₛ1 ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_pure_stepsₛ.
      Qed.
      Lemma simv_pure_stepₛ eₛ1 eₛ2 eₜ Φ :
        pure_step sim_progₛ eₛ1 eₛ2 →
        SIM eₛ2 ≳ eₜ [[ X ]] [[ Φ ]] -∗
        SIM eₛ1 ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_pure_stepₛ.
      Qed.
      Lemma simv_pure_head_stepsₛ eₛ1 eₛ2 eₜ Φ :
        rtc (pure_head_step sim_progₛ) eₛ1 eₛ2 →
        SIM eₛ2 ≳ eₜ [[ X ]] [[ Φ ]] -∗
        SIM eₛ1 ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_pure_head_stepsₛ.
      Qed.
      Lemma simv_pure_head_stepₛ eₛ1 eₛ2 eₜ Φ :
        pure_head_step sim_progₛ eₛ1 eₛ2 →
        SIM eₛ2 ≳ eₜ [[ X ]] [[ Φ ]] -∗
        SIM eₛ1 ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_pure_head_stepₛ.
      Qed.

      Lemma simv_stepₜ eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                sim_state_interp σₛ σₜ' ∗
                SIM eₛ ≳ eₜ' [[ X ]] [[ Φ ]]
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_stepₜ.
      Qed.
      Lemma simv_head_stepₜ eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜head_reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜head_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                sim_state_interp σₛ σₜ' ∗
                SIM eₛ ≳ eₜ' [[ X ]] [[ Φ ]]
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_head_stepₜ.
      Qed.
      Lemma simv_pure_stepsₜ eₛ eₜ1 eₜ2 Φ :
        rtc (pure_step sim_progₜ) eₜ1 eₜ2 →
        SIM eₛ ≳ eₜ2 [[ X ]] [[ Φ ]] -∗
        SIM eₛ ≳ eₜ1 [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_pure_stepsₜ.
      Qed.
      Lemma simv_pure_stepₜ eₛ eₜ1 eₜ2 Φ :
        pure_step sim_progₜ eₜ1 eₜ2 →
        SIM eₛ ≳ eₜ2 [[ X ]] [[ Φ ]] -∗
        SIM eₛ ≳ eₜ1 [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_pure_stepₜ.
      Qed.
      Lemma simv_pure_head_stepsₜ eₛ eₜ1 eₜ2 Φ :
        rtc (pure_head_step sim_progₜ) eₜ1 eₜ2 →
        SIM eₛ ≳ eₜ2 [[ X ]] [[ Φ ]] -∗
        SIM eₛ ≳ eₜ1 [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_pure_head_stepsₜ.
      Qed.
      Lemma simv_pure_head_stepₜ eₛ eₜ1 eₜ2 Φ :
        pure_head_step sim_progₜ eₜ1 eₜ2 →
        SIM eₛ ≳ eₜ2 [[ X ]] [[ Φ ]] -∗
        SIM eₛ ≳ eₜ1 [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_pure_head_stepₜ.
      Qed.

      Lemma simv_steps eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                ∃ eₛ' σₛ',
                ⌜tc (step sim_progₛ) (eₛ, σₛ) (eₛ', σₛ')⌝ ∗
                sim_state_interp σₛ' σₜ' ∗
                SIM eₛ' ≳ eₜ' [[ X ]] [[ Φ ]]
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_steps.
      Qed.
      Lemma simv_step eₛ eₜ Φ :
        ( ∀ σₛ σₜ, sim_state_interp σₛ σₜ ==∗
            ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                ∃ eₛ' σₛ',
                ⌜prim_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
                sim_state_interp σₛ' σₜ' ∗
                SIM eₛ' ≳ eₜ' [[ X ]] [[ Φ ]]
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_step.
      Qed.
      Lemma simv_head_step eₛ eₜ Φ :
        ( ∀ σₛ σₜ, sim_state_interp σₛ σₜ ==∗
            ⌜head_reducible sim_progₜ eₜ σₜ⌝ ∗
              ∀ eₜ' σₜ',
              ⌜head_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
                ∃ eₛ' σₛ',
                ⌜head_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
                sim_state_interp σₛ' σₜ' ∗
                SIM eₛ' ≳ eₜ' [[ X ]] [[ Φ ]]
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_head_step.
      Qed.
      Lemma simv_pure_steps eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        rtc (pure_step sim_progₛ) eₛ1 eₛ2 →
        rtc (pure_step sim_progₜ) eₜ1 eₜ2 →
        SIM eₛ2 ≳ eₜ2 [[ X ]] [[ Φ ]] -∗
        SIM eₛ1 ≳ eₜ1 [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_pure_steps.
      Qed.
      Lemma simv_pure_step eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        pure_step sim_progₛ eₛ1 eₛ2 →
        pure_step sim_progₜ eₜ1 eₜ2 →
        SIM eₛ2 ≳ eₜ2 [[ X ]] [[ Φ ]] -∗
        SIM eₛ1 ≳ eₜ1 [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_pure_step.
      Qed.
      Lemma simv_pure_head_steps eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        rtc (pure_head_step sim_progₛ) eₛ1 eₛ2 →
        rtc (pure_head_step sim_progₜ) eₜ1 eₜ2 →
        SIM eₛ2 ≳ eₜ2 [[ X ]] [[ Φ ]] -∗
        SIM eₛ1 ≳ eₜ1 [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_pure_head_steps.
      Qed.
      Lemma simv_pure_head_step eₛ1 eₛ2 eₜ1 eₜ2 Φ :
        pure_head_step sim_progₛ eₛ1 eₛ2 →
        pure_head_step sim_progₜ eₜ1 eₜ2 →
        SIM eₛ2 ≳ eₜ2 [[ X ]] [[ Φ ]] -∗
        SIM eₛ1 ≳ eₜ1 [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_pure_head_step.
      Qed.

      Lemma simv_apply_protocol Ψ eₛ eₜ Φ :
        ( ∀ σₛ σₜ,
          sim_state_interp σₛ σₜ ==∗
            X Ψ eₛ eₜ ∗
            sim_state_interp σₛ σₜ ∗
              ∀ eₛ eₜ,
              Ψ eₛ eₜ -∗
              SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]]
        ) -∗
        SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]].
      Proof.
        rewrite definition.simv_unseal. apply sim_apply_protocol.
      Qed.
    End simv.
  End protocol.

  Section protocol.
    Context X.

    Lemma sim_close eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ eₜ,
        X Ψ eₛ eₜ -∗
        sim_inner ⊥ (λ _, sim X Ψ) (λ _ _, False) eₛ eₜ
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] {{ Φ }} -∗
      SIM eₛ ≳ eₜ {{ Φ }}.
    Proof.
      iIntros "#H".
      iApply (sim_coind with "[]"); first solve_proper. clear Φ eₛ eₜ. iIntros "!> %Φ %eₛ %eₜ".
      rewrite sim_fixpoint. iApply (sim_inner_ind with "[]"); first solve_proper.
      { solve_proper_prepare. apply sim_inner_ne; done || solve_proper. }
      clear Φ eₛ eₜ. iIntros "!> %Φ %eₛ %eₜ Hsim".
      setoid_rewrite sim_inner_fixpoint at 2; last solve_proper.
      iIntros "%σₛ %σₜ Hsi".
      iMod ("Hsim" with "Hsi") as "[Hsim | [Hsim | [Hsim | Hsim]]]"; auto.
      iDestruct "Hsim" as "(%Kₛ & %eₛ' & %Kₜ & %eₜ' & %Ψ & (-> & ->) & HX & Hsi & Hsim)".
      iDestruct ("H" with "HX") as "HΨ". iClear "H".
      iRevert (σₛ σₜ) "Hsi". setoid_rewrite <- sim_inner_fixpoint; last solve_proper.
      iApply (sim_inner_bind' with "HΨ [Hsim]"); [solve_proper | iIntros "%eₛ %eₜ HΨ" | iIntros "%eₛ %eₜ []"].
      iApply (sim_bind' with "HΨ"). clear eₛ eₜ. iIntros "%eₛ %eₜ HΨ".
      iApply cupd_sim. iApply ("Hsim" with "HΨ").
    Qed.
    Lemma sim_close_steps eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ σₛ eₜ σₜ,
        X Ψ eₛ eₜ -∗
        sim_state_interp σₛ σₜ ==∗
          ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
            ∀ eₜ' σₜ',
            ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
              ∃ eₛ' σₛ',
              ⌜tc (step sim_progₛ) (eₛ, σₛ) (eₛ', σₛ')⌝ ∗
              sim_state_interp σₛ' σₜ' ∗
              SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] {{ Φ }} -∗
      SIM eₛ ≳ eₜ {{ Φ }}.
    Proof.
      iIntros "#H".
      iApply sim_close.
      setoid_rewrite <- sim_inner_steps; last solve_proper.
      clear eₛ eₜ. iIntros "!> %Ψ %eₛ %eₜ HX %σₛ %σₜ".
      iApply ("H" with "HX").
    Qed.
    Lemma sim_close_step eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ σₛ eₜ σₜ,
        X Ψ eₛ eₜ -∗
        sim_state_interp σₛ σₜ ==∗
          ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
            ∀ eₜ' σₜ',
            ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
              ∃ eₛ' σₛ',
              ⌜prim_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
              sim_state_interp σₛ' σₜ' ∗
              SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] {{ Φ }} -∗
      SIM eₛ ≳ eₜ {{ Φ }}.
    Proof.
      iIntros "#H".
      iApply sim_close_steps. clear eₛ eₜ. iIntros "!> %Ψ %eₛ %σₛ %eₜ %σₜ HX Hsi".
      iMod ("H" with "HX Hsi") as "(%Hreducibleₜ & Hsim)". iClear "H".
      iSplitR; first done. iIntros "!> %eₜ' %σₜ' %Hstepₜ".
      iMod ("Hsim" with "[//]") as "(%eₛ' & %σₛ' & %Hstepₛ & Hsi & Hsim)".
      iExists eₛ', σₛ'. iFrame. eauto using tc_once, prim_step_step.
    Qed.
    Lemma sim_close_head_step eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ σₛ eₜ σₜ,
        X Ψ eₛ eₜ -∗
        sim_state_interp σₛ σₜ ==∗
          ⌜head_reducible sim_progₜ eₜ σₜ⌝ ∗
            ∀ eₜ' σₜ',
            ⌜head_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
              ∃ eₛ' σₛ',
              ⌜head_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
              sim_state_interp σₛ' σₜ' ∗
              SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] {{ Φ }} -∗
      SIM eₛ ≳ eₜ {{ Φ }}.
    Proof.
      iIntros "#H".
      iApply sim_close_step. clear eₛ eₜ. iIntros "!> %Ψ %eₛ %σₛ %eₜ %σₜ HX Hsi".
      iMod ("H" with "HX Hsi") as "(%Hreducibleₜ & Hsim)". iClear "H".
      iSplitR; first auto using head_reducible_reducible. iIntros "!> %eₜ' %σₜ' %Hstepₜ".
      apply head_reducible_prim_step in Hstepₜ; last done.
      iMod ("Hsim" with "[//]") as "(%eₛ' & %σₛ' & %Hstepₛ & Hsi & Hsim)".
      iExists eₛ', σₛ'. iFrame. iPureIntro. apply head_step_prim_step. done.
    Qed.
    Lemma sim_close_pure_steps eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ eₜ,
        X Ψ eₛ eₜ -∗
          ∃ eₛ' eₜ',
          ⌜tc (pure_step sim_progₛ) eₛ eₛ' ∧ pure_step sim_progₜ eₜ eₜ'⌝ ∗
          SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] {{ Φ }} -∗
      SIM eₛ ≳ eₜ {{ Φ }}.
    Proof.
      iIntros "#H".
      iApply sim_close_steps. clear eₛ eₜ. iIntros "!> %Ψ %eₛ %σₛ %eₜ %σₜ HX Hsi !>".
      iDestruct ("H" with "HX") as "(%eₛ' & %eₜ' & (%Hstepsₛ & %Hstepₜ) & Hsim)".
      iSplit; first eauto using pure_step_safe. iIntros "%_eₜ' %_σₜ %_Hstepₜ !>".
      eapply pure_step_det in _Hstepₜ as (-> & ->); last done.
      iExists eₛ', σₛ. iFrame. iPureIntro.
      eapply (tc_congruence (λ eₛ, (eₛ, σₛ))); last done.
      eauto using prim_step_step, pure_step_prim_step.
    Qed.
    Lemma sim_close_pure_step eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ eₜ,
        X Ψ eₛ eₜ -∗
          ∃ eₛ' eₜ',
          ⌜pure_step sim_progₛ eₛ eₛ' ∧ pure_step sim_progₜ eₜ eₜ'⌝ ∗
          SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] {{ Φ }} -∗
      SIM eₛ ≳ eₜ {{ Φ }}.
    Proof.
      iIntros "#H".
      iApply sim_close_pure_steps. clear eₛ eₜ. iIntros "!> %Ψ %eₛ %eₜ HX".
      iDestruct ("H" with "HX") as "(%eₛ' & %eₜ' & (%Hstepₛ & %Hstepₜ) & Hsim)". iClear "H".
      iExists eₛ', eₜ'. iFrame. auto using tc_once.
    Qed.
    Lemma sim_close_pure_head_steps eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ eₜ,
        X Ψ eₛ eₜ -∗
          ∃ eₛ' eₜ',
          ⌜tc (pure_head_step sim_progₛ) eₛ eₛ' ∧ pure_head_step sim_progₜ eₜ eₜ'⌝ ∗
          SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] {{ Φ }} -∗
      SIM eₛ ≳ eₜ {{ Φ }}.
    Proof.
      iIntros "#H".
      iApply sim_close_pure_steps. clear eₛ eₜ. iIntros "!> %Ψ %eₛ %eₜ HX".
      iDestruct ("H" with "HX") as "(%eₛ' & %eₜ' & (%Hstepₛ & %Hstepsₜ) & Hsim)". iClear "H".
      iExists eₛ', eₜ'. iFrame. eauto 10 using (tc_congruence id), pure_head_step_pure_step.
    Qed.
    Lemma sim_close_pure_head_step eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ eₜ,
        X Ψ eₛ eₜ -∗
          ∃ eₛ' eₜ',
          ⌜pure_head_step sim_progₛ eₛ eₛ' ∧ pure_head_step sim_progₜ eₜ eₜ'⌝ ∗
          SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] {{ Φ }} -∗
      SIM eₛ ≳ eₜ {{ Φ }}.
    Proof.
      iIntros "#H".
      iApply sim_close_pure_head_steps. clear eₛ eₜ. iIntros "!> %Ψ %eₛ %eₜ HX".
      iDestruct ("H" with "HX") as "(%eₛ' & %eₜ' & (%Hstepₛ & %Hstepₜ) & Hsim)". iClear "H".
      iExists eₛ', eₜ'. iFrame. auto using tc_once.
    Qed.

    Lemma simv_close eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ eₜ,
        X Ψ eₛ eₜ -∗
        sim_inner ⊥ (λ _, sim X Ψ) (λ _ _, False) eₛ eₜ
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]] -∗
      SIM eₛ ≳ eₜ [[ Φ ]].
    Proof.
      rewrite !definition.simv_unseal. apply sim_close.
    Qed.
    Lemma simv_close_steps eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ σₛ eₜ σₜ,
        X Ψ eₛ eₜ -∗
        sim_state_interp σₛ σₜ ==∗
          ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
            ∀ eₜ' σₜ',
            ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
              ∃ eₛ' σₛ',
              ⌜tc (step sim_progₛ) (eₛ, σₛ) (eₛ', σₛ')⌝ ∗
              sim_state_interp σₛ' σₜ' ∗
              SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]] -∗
      SIM eₛ ≳ eₜ [[ Φ ]].
    Proof.
      rewrite !definition.simv_unseal. apply sim_close_steps.
    Qed.
    Lemma simv_close_step eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ σₛ eₜ σₜ,
        X Ψ eₛ eₜ -∗
        sim_state_interp σₛ σₜ ==∗
          ⌜reducible sim_progₜ eₜ σₜ⌝ ∗
            ∀ eₜ' σₜ',
            ⌜prim_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
              ∃ eₛ' σₛ',
              ⌜prim_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
              sim_state_interp σₛ' σₜ' ∗
              SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]] -∗
      SIM eₛ ≳ eₜ [[ Φ ]].
    Proof.
      rewrite !definition.simv_unseal. apply sim_close_step.
    Qed.
    Lemma simv_close_head_step eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ σₛ eₜ σₜ,
        X Ψ eₛ eₜ -∗
        sim_state_interp σₛ σₜ ==∗
          ⌜head_reducible sim_progₜ eₜ σₜ⌝ ∗
            ∀ eₜ' σₜ',
            ⌜head_step sim_progₜ eₜ σₜ eₜ' σₜ'⌝ ==∗
              ∃ eₛ' σₛ',
              ⌜head_step sim_progₛ eₛ σₛ eₛ' σₛ'⌝ ∗
              sim_state_interp σₛ' σₜ' ∗
              SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]] -∗
      SIM eₛ ≳ eₜ [[ Φ ]].
    Proof.
      rewrite !definition.simv_unseal. apply sim_close_head_step.
    Qed.
    Lemma simv_close_pure_steps eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ eₜ,
        X Ψ eₛ eₜ -∗
          ∃ eₛ' eₜ',
          ⌜tc (pure_step sim_progₛ) eₛ eₛ' ∧ pure_step sim_progₜ eₜ eₜ'⌝ ∗
          SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]] -∗
      SIM eₛ ≳ eₜ [[ Φ ]].
    Proof.
      rewrite !definition.simv_unseal. apply sim_close_pure_steps.
    Qed.
    Lemma simv_close_pure_step eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ eₜ,
        X Ψ eₛ eₜ -∗
          ∃ eₛ' eₜ',
          ⌜pure_step sim_progₛ eₛ eₛ' ∧ pure_step sim_progₜ eₜ eₜ'⌝ ∗
          SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]] -∗
      SIM eₛ ≳ eₜ [[ Φ ]].
    Proof.
      rewrite !definition.simv_unseal. apply sim_close_pure_step.
    Qed.
    Lemma simv_close_pure_head_steps eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ eₜ,
        X Ψ eₛ eₜ -∗
          ∃ eₛ' eₜ',
          ⌜tc (pure_head_step sim_progₛ) eₛ eₛ' ∧ pure_head_step sim_progₜ eₜ eₜ'⌝ ∗
          SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]] -∗
      SIM eₛ ≳ eₜ [[ Φ ]].
    Proof.
      rewrite !definition.simv_unseal. apply sim_close_pure_head_steps.
    Qed.
    Lemma simv_close_pure_head_step eₛ eₜ Φ :
      □ (
        ∀ Ψ eₛ eₜ,
        X Ψ eₛ eₜ -∗
          ∃ eₛ' eₜ',
          ⌜pure_head_step sim_progₛ eₛ eₛ' ∧ pure_head_step sim_progₜ eₜ eₜ'⌝ ∗
          SIM eₛ' ≳ eₜ' [[ X ]] {{ Ψ }}
      ) -∗
      SIM eₛ ≳ eₜ [[ X ]] [[ Φ ]] -∗
      SIM eₛ ≳ eₜ [[ Φ ]].
    Proof.
      rewrite !definition.simv_unseal. apply sim_close_pure_head_step.
    Qed.
  End protocol.
End sim_state.

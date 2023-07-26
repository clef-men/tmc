From simuliris Require Import
  prelude.
From simuliris.lambda_lang Require Export
  rsim.bisubst.
From simuliris.lambda_lang Require Import
  sim.notations.

Section sim_GS.
  Context `{sim_programs : !SimPrograms lambda_ectx_lang lambda_ectx_lang}.
  Context `{sim_GS : !SimGS Σ}.
  Context (Χ : sim_protocol Σ).
  Implicit Types Γ : bisubst.

  Definition rsim Φ eₛ eₜ : iProp Σ :=
    ∀ Γ eₛ' eₜ',
    ⌜eₛ' = eₛ.[Γ.ₛ#] ∧ eₜ' = eₜ.[Γ.ₜ#]⌝ -∗
    bisubst_well_formed Γ -∗
    SIM eₛ' ≳ eₜ' [[ Χ ]] {{ Φ }}.
  #[global] Arguments rsim _%I (_ _)%lambda_expr : assert.

  Definition rsimv Φ eₛ eₜ : iProp Σ :=
    rsim (sim_post_vals Φ) eₛ eₜ.
  #[global] Arguments rsimv _%I (_ _)%lambda_expr : assert.
End sim_GS.
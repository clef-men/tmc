From simuliris Require Import
  prelude.
From simuliris.lambda_lang Require Export
  syntax.
From simuliris.lambda_lang Require Import
  notations.

Implicit Types func func_aps : lambda_function.
Implicit Types v vₛ vₜ : lambda_val.
Implicit Types e eₛ eₜ : lambda_expr.
Implicit Types prog progₛ progₜ : lambda_program.
Implicit Types ξ : gmap lambda_function lambda_function.

Inductive aps_plus_dir ξ : lambda_expr → lambda_expr → Prop :=
  | aps_plus_dir_val v :
      aps_plus_dir ξ
        #v
        #v
  | aps_plus_dir_var x :
      aps_plus_dir ξ
        $x
        $x
  | aps_plus_dir_let eₛ1 eₛ2 eₜ1 eₜ2 :
      aps_plus_dir ξ eₛ1 eₜ1 →
      aps_plus_dir ξ eₛ2 eₜ2 →
      aps_plus_dir ξ
        (let: eₛ1 in eₛ2)
        (let: eₜ1 in eₜ2)
  | aps_plus_dir_call eₛ1 eₛ2 eₜ1 eₜ2 :
      aps_plus_dir ξ eₛ1 eₜ1 →
      aps_plus_dir ξ eₛ2 eₜ2 →
      aps_plus_dir ξ
        (eₛ1 eₛ2)
        (eₜ1 eₜ2)
  | aps_plus_dir_unop op eₛ eₜ :
      aps_plus_dir ξ eₛ eₜ →
      aps_plus_dir ξ
        (LambdaUnop op eₛ)
        (LambdaUnop op eₜ)
  | aps_plus_dir_binop op eₛ1 eₛ2 eₜ1 eₜ2 :
      aps_plus_dir ξ eₛ1 eₜ1 →
      aps_plus_dir ξ eₛ2 eₜ2 →
      aps_plus_dir ξ
        (LambdaBinop op eₛ1 eₛ2)
        (LambdaBinop op eₜ1 eₜ2)
  | aps_plus_dir_plus_1 eₛ1 eₛ2 eₜ1 eₜ2 :
      aps_plus_dir ξ eₛ1 eₜ1 →
      aps_plus_aps ξ $0 eₛ2.[ren (+1)] eₜ2 →
      aps_plus_dir ξ
        (eₛ1 + eₛ2)
        (let: eₜ1 in eₜ2)
  | aps_plus_dir_plus_2 eₛ1 eₛ2 eₜ1 eₜ2 :
      aps_plus_dir ξ eₛ2 eₜ2 →
      aps_plus_aps ξ $0 eₛ1.[ren (+1)] eₜ1 →
      aps_plus_dir ξ
        (eₛ1 + eₛ2)
        (let: eₜ2 in eₜ1)
  | aps_plus_dir_binop_det op eₛ1 eₛ2 eₜ1 eₜ2 :
      aps_plus_dir ξ eₛ1 eₜ1 →
      aps_plus_dir ξ eₛ2 eₜ2 →
      aps_plus_dir ξ
        (LambdaBinopDet op eₛ1 eₛ2)
        (LambdaBinopDet op eₜ1 eₜ2)
  | aps_plus_dir_if eₛ0 eₛ1 eₛ2 eₜ0 eₜ1 eₜ2 :
      aps_plus_dir ξ eₛ0 eₜ0 →
      aps_plus_dir ξ eₛ1 eₜ1 →
      aps_plus_dir ξ eₛ2 eₜ2 →
      aps_plus_dir ξ
        (if: eₛ0 then eₛ1 else eₛ2)
        (if: eₜ0 then eₜ1 else eₜ2)
  | aps_plus_dir_constr tag eₛ1 eₛ2 eₜ1 eₜ2 :
      aps_plus_dir ξ eₛ1 eₜ1 →
      aps_plus_dir ξ eₛ2 eₜ2 →
      aps_plus_dir ξ
        (&tag eₛ1 eₛ2)
        (&tag eₜ1 eₜ2)
  | aps_plus_dir_constr_det tag eₛ1 eₛ2 eₜ1 eₜ2 :
      aps_plus_dir ξ eₛ1 eₜ1 →
      aps_plus_dir ξ eₛ2 eₜ2 →
      aps_plus_dir ξ
        (&&tag eₛ1 eₛ2)
        (&&tag eₜ1 eₜ2)
  | aps_plus_dir_load eₛ1 eₛ2 eₜ1 eₜ2 :
      aps_plus_dir ξ eₛ1 eₜ1 →
      aps_plus_dir ξ eₛ2 eₜ2 →
      aps_plus_dir ξ
        (![eₛ2] eₛ1)
        (![eₜ2] eₜ1)
  | aps_plus_dir_store eₛ1 eₛ2 eₛ3 eₜ1 eₜ2 eₜ3 :
      aps_plus_dir ξ eₛ1 eₜ1 →
      aps_plus_dir ξ eₛ2 eₜ2 →
      aps_plus_dir ξ eₛ3 eₜ3 →
      aps_plus_dir ξ
        (eₛ1 <-[eₛ2]- eₛ3)
        (eₜ1 <-[eₜ2]- eₜ3)
with aps_plus_aps ξ : lambda_expr → lambda_expr → lambda_expr → Prop :=
  | aps_plus_aps_base acc eₛ eₜ :
      aps_plus_dir ξ eₛ eₜ →
      aps_plus_aps ξ acc
        eₛ
        (eₜ + acc)
  | aps_plus_aps_let acc eₛ1 eₛ2 eₜ1 eₜ2 :
      aps_plus_dir ξ eₛ1 eₜ1 →
      aps_plus_aps ξ acc.[ren (+1)] eₛ2 eₜ2 →
      aps_plus_aps ξ acc
        (let: eₛ1 in eₛ2)
        (let: eₜ1 in eₜ2)
  | aps_plus_aps_call acc func func_aps eₛ eₜ eₜ' :
      ξ !! func = Some func_aps →
      aps_plus_dir ξ eₛ eₜ →
      eₜ' = (let: eₜ in func_aps (acc.[ren (+1)], $0))%lambda_expr →
      aps_plus_aps ξ acc
        (func eₛ)
        eₜ'
  | aps_plus_aps_plus_1 acc eₛ1 eₛ2 eₜ1 eₜ2 eₜ :
      aps_plus_dir ξ eₛ1 eₜ1 →
      aps_plus_aps ξ ($0 + acc.[ren (+1)]) eₛ2.[ren (+1)] eₜ2 →
      eₜ = (let: eₜ1 in eₜ2)%lambda_expr →
      aps_plus_aps ξ acc
        (eₛ1 + eₛ2)
        eₜ
  | aps_plus_aps_plus_2 acc eₛ1 eₛ2 eₜ1 eₜ2 eₜ :
      aps_plus_dir ξ eₛ2 eₜ2 →
      aps_plus_aps ξ ($0 + acc.[ren (+1)]) eₛ1.[ren (+1)] eₜ1 →
      eₜ = (let: eₜ2 in eₜ1)%lambda_expr →
      aps_plus_aps ξ acc
        (eₛ1 + eₛ2)
        eₜ
  | aps_plus_aps_if acc eₛ0 eₛ1 eₛ2 eₜ0 eₜ1 eₜ2 :
      aps_plus_dir ξ eₛ0 eₜ0 →
      aps_plus_aps ξ acc eₛ1 eₜ1 →
      aps_plus_aps ξ acc eₛ2 eₜ2 →
      aps_plus_aps ξ acc
        (if: eₛ0 then eₛ1 else eₛ2)
        (if: eₜ0 then eₜ1 else eₜ2).

Scheme aps_plus_dir_aps_ind := Minimality for aps_plus_dir Sort Prop
with aps_plus_aps_dir_ind := Minimality for aps_plus_aps Sort Prop.
Combined Scheme aps_plus_ind from aps_plus_dir_aps_ind, aps_plus_aps_dir_ind.

Create HintDb aps_plus.

#[export] Hint Constructors aps_plus_dir : aps_plus.
#[export] Hint Constructors aps_plus_aps : aps_plus.

Record aps_plus {progₛ progₜ} := {
  aps_plus_ξ : gmap lambda_function lambda_function ;

  aps_plus_ξ_dom :
    dom aps_plus_ξ ⊆ dom progₛ ;
  aps_plus_dom :
    dom progₜ = dom progₛ ∪ map_img aps_plus_ξ ;
  aps_plus_dirs func eₛ :
    progₛ !! func = Some eₛ →
      ∃ eₜ,
      aps_plus_dir aps_plus_ξ eₛ eₜ ∧
      progₜ !! func = Some eₜ ;
  aps_plus_apss func eₛ func_aps :
    progₛ !! func = Some eₛ →
    aps_plus_ξ !! func = Some func_aps →
      ∃ eₜ,
      aps_plus_aps aps_plus_ξ $1 eₛ eₜ ∧
      progₜ !! func_aps = Some (let: ![𝟙] $0 in let: ![𝟚] $1 in eₜ)%lambda_expr ;
}.
#[global] Arguments aps_plus : clear implicits.
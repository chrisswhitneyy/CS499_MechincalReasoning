Require Import Arith ZArith List String.
Import ListNotations.

(** * Identifiers and Polymorphic States *)

Module Id.

  Inductive t := Id : nat -> t.

  Definition beq (id1 id2:t) : bool :=
    match (id1, id2) with
    | (Id n1, Id n2) => beq_nat n1 n2
    end.

  (** Properties of Id.beq: reflexivity, symmetry. *)

  Fact beq_refl: forall id, beq id id = true.
  Proof.
    intros id.
    destruct id as [ n ].
    unfold beq.
    symmetry.
    apply beq_nat_refl.
  Qed.

  Fact beq_sym: forall id1 id2, beq id1 id2 = beq id2 id1.
  Proof.
    intros id1 id2.
    destruct id1 as [ n1 ].
    destruct id2 as [ n2 ].
    unfold beq.
    now rewrite Nat.eqb_sym.
  Qed.

  Fact beq_eq: forall id1 id2,
      beq id1 id2 = true -> id1 = id2.
  Proof.
    intros [ id1 ] [ id2 ] H; unfold beq in *; simpl in *.
    apply beq_nat_true in H; now rewrite H.
  Qed.
  
End Id.

(* State *)
Module State.

  Definition t := Id.t -> Z.
  
  Definition update (s:t)(x:Id.t)(v:Z) : t :=
    fun y => if Id.beq y x
          then v
          else s y.

End State.

(* Evaluation Stack *)
Module Stack.

  Inductive A : Type :=
  | z : Z -> A 
  | T: bool -> A.

  Definition t : Type := list A.

End Stack.
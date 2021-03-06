(* Project 3: 
  The purpose of this project is to implement transtion functions which take in a statement in the While lanauge
  and out put an equavalent statement in the AM lanauage. This is accomplished by using the transtion tables in 
  chapter 4 of the course text. The functions are then tested by using some examples. 
  
  Author: Charles Chawtin and Christopher D. Whitney 
  Last Modified: Dec. 2n, 2016
*) 

Require Import Arith ZArith List String Project2 Bool Relation_Operators.
Import ListNotations.

Fixpoint CA (e:Aexp.t): code := 
  match e with 
  | Aexp.Int n => [(PUSH n)]
  | Aexp.Var x => [(FETCH x)]
  | Aexp.Binop Aexp.Add a1 a2 => (CA a2) ++ (CA a1) ++ [ADD]
  | Aexp.Binop Aexp.Mul a1 a2 => (CA a2) ++ (CA a1) ++ [MULT]
  | Aexp.Binop Aexp.Sub a1 a2 => (CA a2) ++ (CA a1) ++ [SUB]
  end.

Fixpoint CB (e:Bexp.t): code := 
  match e with 
  | Bexp.Bool true => [TRUE]
  | Bexp.Bool false => [FALSE]
  | Bexp.Neg t => CB t ++ [NEG]
  | Bexp.And t1 t2 => (CB t2) ++ (CB t1) ++ [AND]
  | Bexp.Cmp Bexp.Equal t1 t2 => (CA t2) ++ (CA t1) ++ [EQ]
  | Bexp.Cmp Bexp.LowerEq t1 t2 =>(CA t2) ++ (CA t1) ++ [LE]
  end.

Fixpoint CS (s:stm) : code := 
  match s with 
  | Assign x a => CA (a) ++ [STORE x]
  | Skip => [NOOP]
  | Seq s1 s2 => CS s1 ++ CS s2
  | If b s1 s2 => CB b  ++ [BRANCH (CS s1) (CS s2)]
  | While b s => [LOOP (CB b) (CS s)]
  end.


Module Examples. 
  
    Definition x : Id.t := Id.Id 0. 
    Definition y : Id.t := Id.Id 1.
    Definition z : Id.t := Id.Id 2.

    Example ex_4_10 : 
      CA (Aexp.Int 1%Z) ++ CA (Aexp.Var x) ++ [ADD] = [PUSH 1%Z] ++ [FETCH x] ++ [ADD]. 
      Proof. 
        compute. trivial.
      Qed.

    Example ex_4_12 :
      CS (Seq 
           (Assign y (Aexp.Int 1%Z))  
           (While (Bexp.Neg (Bexp.Cmp Bexp.Equal (Aexp.Var x) (Aexp.Int 1%Z))) 
                     (Seq (Assign y (Aexp.Binop Aexp.Mul (Aexp.Var x)  (Aexp.Var y))) 
                             (Assign x (Aexp.Binop Aexp.Sub (Aexp.Var x) (Aexp.Int 1%Z)))))) = 
           PUSH 1%Z :: STORE y :: [LOOP (PUSH 1%Z :: FETCH x :: EQ :: [NEG]) 
                                                         (FETCH y :: FETCH x :: MULT :: STORE y :: PUSH 1%Z :: FETCH x :: SUB :: [STORE x]) ].
    Proof.
        compute. trivial.
    Qed.
  
  Lemma _4_18: 
    forall a s, 
      (clos_refl_trans_1n _ am) (CA a, [ ], s) ([ ], [Stack.z (Aexp.A a s)], s). 
  Proof. 
    intros. induction a. 
    - simpl. econstructor. apply am_push. constructor.
    - simpl. econstructor. apply am_fetch. constructor.
    - simpl. destruct b.
       +  repeat econstructor. apply am_add. 
       +  econstructor. 
       + admit.
  Admitted.

  Lemma _4_19: 
     forall (b:Bexp.t) s, 
      (clos_refl_trans_1n _ am) (CB b, [ ], s) ([ ], [Stack.T (Bexp.B b s)], s). 
  Proof. 
  intros. induction b.
  - simpl. 
     + destruct b;  repeat econstructor.
  - admit.
  Admitted.
  

End Examples.

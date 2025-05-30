(defmodule manejar-incertidumbre (export ?ALL) (import MAIN ?ALL))

; Funcion combinacion
(deffunction combinacion (?fc1 ?fc2)
   (if (and (> ?fc1 0) (> ?fc2 0) ) 
      then
         (bind ?rv (- (+ ?fc1 ?fc2) (* ?fc1 ?fc2) ) )
      else
         (if (and (< ?fc1 0) (< ?fc2 0) ) 
            then
               (bind ?rv (+ (+ ?fc1 ?fc2) (* ?fc1 ?fc2) ) )
            else
               (bind ?rv (/ (+ ?fc1 ?fc2) (- 1 (min (abs ?fc1) (abs ?fc2))) ))
         )
   ) 
   ?rv
)

(defrule mostrar-mejor-receta
  ?r <- (SimilitudTotal (receta ?n) (valor ?v))
  (not (SimilitudTotal (valor ?v2&:(> ?v2 ?v))))
  =>
  (printout t crlf "*** RECETA RECOMENDADA: " ?n " con similitud " ?v crlf))
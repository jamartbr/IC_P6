(defmodule manejar-incertidumbre (export ?ALL) (import MAIN ?ALL))

(defrule mostrar-recetas-descartadas
(declare (salience 1))
  ?r <- (receta (nombre ?n))
  (SimilitudTotal (receta ?n) (valor ?v))
  (SimilitudTotal (valor ?mejor_v&:(> ?mejor_v ?v)))
  =>
  (printout t "--- RECETA DESCARTADA: " ?n 
             " (similitud: " (format nil "%.2f" ?v) ")" crlf))


(defrule mostrar-mejor-receta
(declare (salience 2))
  ?r <- (receta (nombre ?n))
  (SimilitudTotal (receta ?n) (valor ?v))
  (not (SimilitudTotal (valor ?v2&:(> ?v2 ?v))))
  (explicacion (receta ?r) (texto1 ?t) (texto2 ?t2) (texto3 ?t3))
  (not (estado recomendada))
  =>
  (printout t crlf "*** RECETA RECOMENDADA: " ?n " con similitud " ?v crlf)

   (bind ?ingredientes (fact-slot-value ?r ingredientes))

   (printout t crlf " Justificación de la recomendación de la receta: " ?n crlf)
   (printout t "- Ingredientes: " (implode$ ?ingredientes) crlf)

   (do-for-all-facts ((?j justificacion)) TRUE
      (printout t "- Se tuvo en cuenta el " ?j:campo ": " ?j:valor crlf))
   (printout t ?t crlf ?t2 crlf ?t3 crlf)
   (assert (estado recomendada))
)


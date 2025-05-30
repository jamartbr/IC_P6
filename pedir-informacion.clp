(defmodule pedir-informacion (export ?ALL) (import MAIN ?ALL))

(deffunction opcion-valida? (?valor $?validas)
   (return (member$ ?valor ?validas)))

; si se desea picante -> no se pregunta por restriccion alimentaria
(defrule omitir-restriccion-por-picante
(declare (salience 80))
   ?i <- (info-faltante (campo preferencia-alimentaria))
   (preferencia-picante (desea si))
   =>
   ;(printout t crlf " No se preguntará por restricciones alimentarias porque se desea una receta picante." crlf)
   (assert (preferencia-alimentaria (tipo ninguna)))
   (assert (justificacion (campo restriccion-alimentaria) (valor omitida-por-picante)))
   (retract ?i)
)

; preguntar por restricción alimentaria solo si no se desea picante
(defrule preguntar-preferencia-alimentaria
(declare (salience 80))
   ?i <- (info-faltante (campo preferencia-alimentaria))
   (preferencia-picante (desea ?p&:(neq ?p si)))
   =>
   (printout t crlf "¿Tiene alguna restricción alimentaria? (vegana / vegetariana / sin_lactosa / sin_gluten / ninguna): " crlf)
   (bind ?resp (lowcase (read)))
   (if (opcion-valida? ?resp (create$ vegana vegetariana sin_lactosa sin_gluten ninguna)) then
      (assert (preferencia-alimentaria (tipo ?resp)))
   else
      (printout t "Opción no válida. Se asumirá que no hay restricciones alimentarias." crlf)
      (assert (preferencia-alimentaria (tipo ninguna))))
   (retract ?i)
   (assert (justificacion (campo restriccion-alimentaria) (valor ?resp)))
)

; preguntar si le gustaría que sea picante -> si el momento es comida o cualquiera
(defrule preguntar-picante
(declare (salience 90))
   ?i <- (info-faltante (campo preferencia-picante))
   (momento (tipo ?m&:(or (eq ?m comida) (eq ?m cualquiera)))) ; solo se pregunta si es comida o cualquiera
   =>
   (printout t crlf "¿Desea que la receta sea picante? (si / no / cualquiera): " crlf)
   (bind ?resp (lowcase (read)))
   (if (opcion-valida? ?resp (create$ si no cualquiera)) then
      (assert (preferencia-picante (desea ?resp)))
   else
      (printout t "No se aplicará ninguna preferencia de picante." crlf)
      (assert (preferencia-picante (desea cualquiera))))
   (retract ?i)
   (assert (justificacion (campo picante) (valor ?resp)))
)

; si el momento es desayuno o postre, no se pregunta por picante y se asume "cualquiera"
(defrule omitir-picante-por-momento
(declare (salience 90))
   ?i <- (info-faltante (campo preferencia-picante))
   (momento (tipo ?m&:(or (eq ?m desayuno) (eq ?m postre))))
   =>
   ;(printout t crlf " No se preguntará por picante porque no aplica para " ?m "." crlf)
   (assert (preferencia-picante (desea cualquiera)))
   (assert (justificacion (campo picante) (valor omitida-por-momento)))
   (retract ?i)
)

; preguntar momento del día -> esto se pregunta siempre lo primero
(defrule preguntar-momento
(declare (salience 100))
   ?i <- (info-faltante (campo momento))
   =>
   (printout t crlf "¿Para qué momento del día busca la receta? (desayuno / comida / postre / cualquiera): " crlf)
   (bind ?resp (lowcase (read)))
   (if (opcion-valida? ?resp (create$ desayuno comida postre cualquiera)) then
      (assert (momento (tipo ?resp)))
   else
      (printout t "No se aplicará ninguna preferencia de momento del día." crlf)
      (assert (momento (tipo cualquiera))))
   (retract ?i)
   (assert (justificacion (campo momento) (valor ?resp)))
)

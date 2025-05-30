(defmodule proponer-receta (export ?ALL) (import MAIN ?ALL))

; vemos si se busca alguna dificultad especifica
(deftemplate dificultad-encontrada
   (slot valor))

; se cuentan si hay dificultades distintas para pregntar por la dificultad o no
(defrule buscar-dificultades-distintas
   (declare (salience 100))
   ?r <- (recomendacion (receta ?rec-fact))
   =>
   (assert (dificultad-encontrada (valor (fact-slot-value ?rec-fact dificultad)))))

; si hay recetas compatbles con dificultades distintas -> se pregunta por la dificultad
(defrule preguntar-si-cambiar-dificultad
   (declare (salience 90))
   (not (respuesta-cambio dificultad))
   (dificultad-encontrada (valor ?v1))
   (dificultad-encontrada (valor ?v2&:(neq ?v1 ?v2))) ; si hay al menos dos dificultades distintas
   =>
   ;(printout t crlf " Se han encontrado recetas con distintos niveles de dificultad." crlf)
   (printout t "¿Quieres filtrar por un nivel de dificultad específico? Estas son las opciones disponibles:" crlf)
   (do-for-all-facts ((?d dificultad-encontrada)) TRUE
      (printout t " - " ?d:valor crlf))
   (printout t "Escribe una de las opciones anteriores o 'no' para continuar sin filtrar: ")
   (bind ?resp (lowcase (read)))
   (if (member$ ?resp (create$ baja muy_baja media alta)) then
      (assert (dificultad-preferida ?resp))
      (assert (justificacion (campo dificultad) (valor ?resp)))
   else
      (if (eq ?resp "no") then
         (assert (dificultad-preferida no))
      else
         (printout t "Opción no válida. No se tendrá en cuenta la dificultad." crlf)
         (assert (dificultad-preferida no))))
   (assert (respuesta-cambio dificultad))
)


(defrule filtrar-por-dificultad-seleccionada
   (declare (salience 90))
   (dificultad-preferida ?dif)
   ?r <- (recomendacion (receta ?rec-fact))
   (test (neq ?dif no)) ; si se ha respondido no -> no se hace nada
   (test (neq (fact-slot-value ?rec-fact dificultad) ?dif))
   =>
   (bind ?nombre (fact-slot-value ?rec-fact nombre))
   ;(printout t ":( Se descarta la receta '" ?nombre "' por no tener dificultad " ?dif crlf)
   (retract ?r)
)

(defrule mostrar-recetas-compatibles
   (declare (salience 86))
   (dificultad-preferida ?dif)
   (recomendacion (receta ?r))
   =>
   (bind ?nombre (fact-slot-value ?r nombre))
   (printout t "✅ Receta compatible: " ?nombre crlf)
   )

; si solo hay una receta compatible -> se propone directamente
(defrule proponer-si-solo-una-recomendacion
   (declare (salience 85))
   (not (propuesta (receta ?)))
   (recomendacion (receta ?rec))
   (not (recomendacion (receta ?otra&:(neq ?otra ?rec)))) ; solo una recomendación
   =>
   (bind ?nombre       (fact-slot-value ?rec nombre))

   (assert (propuesta (receta ?rec)))

   (printout t crlf "Propuesta basada en las especificaciones indicadas: " ?nombre crlf))


; ahora vemos si se quiere priorizar algun ingrediente
(defrule preguntar-por-prioridad-ingrediente
   (declare (salience 80))
   (not (ingrediente-priorizado))
   (not (propuesta (receta ?)))
   (exists (recomendacion (receta ?))) ; se activa solo una vez si existe alguna recomendación
   =>
   (printout t crlf "¿Te gustaría priorizar algún ingrediente en la receta? (Escribe 'ninguno' si no): ")
   (bind ?resp (lowcase (read)))
   (if (neq ?resp "ninguno") then
      (assert (ingrediente-priorizado ?resp))
   else
      (assert (ingrediente-priorizado ninguno)))

)

(defrule marcar-recetas-con-ingrediente-priorizado
   (declare (salience 75))
   (ingrediente-priorizado ?ing)
   (test (neq ?ing ninguno))
   (recomendacion (receta ?rec-fact))
   (test (or
           (member$ ?ing (fact-slot-value ?rec-fact ingredientes))
           (neq FALSE
                (str-index (lowcase ?ing)
                           (lowcase (implode$ (fact-slot-value ?rec-fact ingredientes)))))))
   =>
   (assert (receta-preferida ?rec-fact))
   (assert (justificacion (campo ingrediente-priorizado) (valor ?ing)))
)

(defrule proponer-receta-prioritaria
(declare (salience 73))
   ?p <- (receta-preferida ?rec) ; si hay alguna receta con el ingrediente a priorizar
   (not (propuesta (receta ?))) ; si todavía no se ha propuesto ninguna receta
   =>
   (bind ?nombre       (fact-slot-value ?rec nombre))

   (assert (propuesta (receta ?rec)))
   (retract ?p)

   (printout t crlf "Propuesta basada en tu ingrediente preferido:" ?nombre crlf))

; si no se ha hecho ninguna propuesta todavia -> que se haga
(defrule proponer-cualquier-receta
   (declare (salience 70))
   (not (propuesta (receta ?)))
   ?r <- (recomendacion (receta ?rec))
   =>
   (bind ?nombre       (fact-slot-value ?rec nombre))

   (assert (propuesta (receta ?rec)))
   (retract ?r)

   (printout t crlf "No se encuentran recetas con el ingrediente indicado. Te propongo esta receta:" ?nombre crlf)
)

; Mostrar justificación de la receta propuesta
(defrule justificar-recomendacion
   (declare (salience 50))
   ?p <- (propuesta (receta ?rec))
   =>
   (bind ?nombre       (fact-slot-value ?rec nombre))
   (bind ?ingredientes (fact-slot-value ?rec ingredientes))

   (printout t crlf " Justificación de la recomendación de la receta: " ?nombre crlf)
   (printout t "- Ingredientes: " (implode$ ?ingredientes) crlf)

   (do-for-all-facts ((?j justificacion)) TRUE
      (printout t "- Se tuvo en cuenta el " ?j:campo ": " ?j:valor crlf))
)



(defmodule obtener-compatibles (import MAIN ?ALL) (export ?ALL))

(defrule marcar-no-compatible-por-vegana
(declare(salience 90))
   (preferencia-alimentaria (tipo vegana))
   (receta (nombre ?n))
   (not (propiedad_receta (tipo es_vegana) (receta ?n)))
   =>
   ;(printout t "Receta NO compatible por VEGANA: " ?n  crlf)
   (assert (no_compatible ?n)))

(defrule marcar-no-compatible-por-vegetariana
(declare(salience 90))
   (preferencia-alimentaria (tipo vegetariana))
   (receta (nombre ?n))
   (not (propiedad_receta (tipo es_vegetariana) (receta ?n)))
   =>
   ;(printout t "Receta NO compatible por VEGETARIANA: " ?n  crlf)
   (assert (no_compatible ?n)))

(defrule marcar-no-compatible-por-sin-gluten
(declare(salience 90))
   (preferencia-alimentaria (tipo sin_gluten))
   (receta (nombre ?n))
   (not (propiedad_receta (tipo es_sin_gluten) (receta ?n)))
   =>
   ;(printout t "Receta NO compatible por SIN GLUTEN: " ?n  crlf)
   (assert (no_compatible ?n)))

(defrule marcar-no-compatible-por-sin-lactosa
(declare(salience 90))
   (preferencia-alimentaria (tipo sin_lactosa))
   (receta (nombre ?n))
   (not (propiedad_receta (tipo es_sin_lactosa) (receta ?n)))
   =>
   ;(printout t "Receta NO compatible por SIN LACTOSA: " ?n crlf)
   (assert (no_compatible ?n)))

(defrule marcar-no-compatible-por-picante
(declare(salience 90))
   (preferencia-picante (desea si))
   (receta (nombre ?n))
   (not (propiedad_receta (tipo es_picante) (receta ?n)))
   =>
   ;(printout t "Receta NO compatible por PICANTE: " ?n   crlf)
   (assert (no_compatible ?n))
)

(defrule marcar-no-compatible-por-no-picante
(declare(salience 90))
   (preferencia-picante (desea no))
   (receta (nombre ?n))
   (propiedad_receta (tipo es_picante) (receta ?n))
   =>
   ;(printout t "Receta NO compatible por PICANTE: " ?n   crlf)
   (assert (no_compatible ?n))
)

(defrule no-compatible-por-momento-desayuno
   (declare (salience 89))
   (momento (tipo desayuno))
   (receta (nombre ?n) (tipo_plato $?tipos))
   (test (not (member$ desayuno_merienda $?tipos)))
   =>
   ;(printout t "Receta NO compatible por DESAYUNO: " ?n " (" $?tipos ")" crlf)
   (assert (no_compatible ?n))
)

(defrule no-compatible-por-momento-comida
   (declare (salience 89))
   (momento (tipo comida))
   (receta (nombre ?n) (tipo_plato $?tipos))
   (test (not (or (member$ plato_principal $?tipos)
                  (member$ primer_plato $?tipos)
                  (member$ entrante $?tipos))))
   =>
   ;(printout t "Receta NO compatible por COMIDA: " ?n " (" $?tipos ")" crlf)
   (assert (no_compatible ?n))
)

(defrule no-compatible-por-momento-postre
   (declare (salience 89))
   (momento (tipo postre))
   (receta (nombre ?n) (tipo_plato $?tipos))
   (test (not (member$ postre $?tipos)))
   =>
   ;(printout t "Receta NO compatible por POSTRE: " ?n " (" $?tipos ")" crlf)
   (assert (no_compatible ?n))
)

; marcamos la recetas compatibles gracias a las no_compatibles
(defrule marcar-compatible
(declare(salience 80))
   (receta (nombre ?n))
   (not (no_compatible ?n))
   =>
   (assert (compatible ?n)))

; añadimos cada receta comptabible al fact recomendacion
(defrule mostrar-recetas-compatibles
   (declare (salience 70))
   (compatible ?n)
   ?r <- (receta (nombre ?n) (ingredientes $?i))
   =>
   (assert (recomendacion (receta ?r)))
   (printout t " Receta compatible: " ?n crlf)
   )

; esta regla no se ejecutará nunca -> pq no esta la opcion de que no haya recetas disponibles
(defrule sin-recetas-compatibles
   (declare (salience 60))
   (not (compatible ?))
   =>
   (printout t " No se encontró ninguna receta compatible con tus preferencias." crlf))


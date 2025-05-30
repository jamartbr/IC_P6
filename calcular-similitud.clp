(defmodule calcular-similitud (export ?ALL) (import MAIN ?ALL))

(deffunction calcular-similitud::duracion-minutos (?d)
  (string-to-field (sub-string 1 (- (str-length ?d) 1) ?d))) ; convierte "45m" -> 45

; Funcion encadenado
(deffunction encadenado (?fc_antecedente ?fc_regla)
(if (> ?fc_antecedente 0) 
   then
      (bind ?rv (* ?fc_antecedente ?fc_regla))
   else
      (bind ?rv 0) 
)
?rv
)

;; Comparar dificultad (exact match = 1.0, si no 0.0)
(deffunction distancia-dificultad (?d1 ?d2)
  (bind ?niveles (create$ muy_baja baja media alta))
  (bind ?i1 (member$ ?d1 ?niveles))
  (bind ?i2 (member$ ?d2 ?niveles))
  (if (and ?i1 ?i2)
    then (abs (- ?i1 ?i2))
    else 3)) ; distancia máxima si alguno no se reconoce

(deffunction similitud-dificultad (?d1 ?d2)
  (bind ?dist (distancia-dificultad ?d1 ?d2))
  (bind ?simi (max 0 (- 1 (/ ?dist 3.0)))) ; 0 → 1.0, 1 → 0.66..., 2 → 0.33..., 3 → 0.0
  ?simi)


(defrule comparar-dificultad
  ?r <- (receta (nombre ?n) (dificultad ?dif))
  (recomendacion (receta ?r))
  (preferencia (campo dificultad) (valor ?p) (certeza ?fc_dificultad))
  (not (estado ?r dificultad_comprobada))
  
  =>
  (bind ?sim (similitud-dificultad ?dif ?p))
  ;(printout t crlf "Similitud dificultad " ?n " "?fc_dificultad "*" ?sim crlf)
  (assert (FactorCerteza (receta ?n) (fc (* ?fc_dificultad ?sim))))
  (assert (estado ?r dificultad_comprobada))
  (assert (explicacion 
            (receta ?r) 
            (texto1 (str-cat "- La dificultad de la receta es " ?dif 
                            " y se parece a tu preferencia (" ?p 
                            ") con similitud " (format nil "%.2f" ?sim) "."))))
)


;; Comparar duración por cercanía
(defrule comparar-duracion
  ?r <- (receta (nombre ?n) (duracion ?d))
  (recomendacion (receta ?r))
  ?fc_antecedente <- (FactorCerteza (receta ?n) (fc ?fc_receta))
  (preferencia (campo duracion) (valor ?pd) (certeza ?fc_duracion))
  (not (estado ?r duracion_comprobada))
  (estado ?r dificultad_comprobada)  
  ?e <- (explicacion (receta ?r))
  =>
  (bind ?dr (abs (- (duracion-minutos ?d) (duracion-minutos ?pd))))
  (bind ?sim (max 0 (- 1 (/ ?dr 30.0)))) ; más cercano a 0 = más parecido
  ;(printout t crlf "Similitud duracion " ?n " "?fc_receta "*" ?sim crlf)
  (retract ?fc_antecedente)
  (assert (FactorCerteza (receta ?n) (fc (* ?sim ?fc_receta))))
  (assert (estado ?r duracion_comprobada))
  (modify ?e (texto2 (str-cat "- La duración de la receta es " ?d
                            " y se parece a tu preferencia (" ?pd 
                            ") con similitud " (format nil "%.2f" ?sim) ".")))
)

;; Comparar número de personas por cercanía
(defrule comparar-personas
  ?r <- (receta (nombre ?n) (numero_personas ?rp))
  (recomendacion (receta ?r))
  ?fc_antecedente <- (FactorCerteza (receta ?n) (fc ?fc_receta))
  (preferencia (campo numero_personas) (valor ?np) (certeza ?fc_personas))
  ?e <- (explicacion (receta ?r))
  (not (estado ?r personas_comprobada))
  (estado ?r dificultad_comprobada)
  (estado ?r duracion_comprobada)
  =>
  (bind ?dist (abs (- ?rp ?np)))
  (bind ?sim (max 0 (- 1 (/ ?dist 5.0))))
  ;(printout t crlf "Similitud personas " ?n " "?fc_receta "*" ?sim crlf)
  (retract ?fc_antecedente)
  (assert (SimilitudTotal (receta ?n) (valor (* ?sim ?fc_receta)))) ; SIMILITUD TOTAL DE LA CERTEZA
  (assert (estado ?r personas_comprobada))
  (modify ?e (texto3 (str-cat "- El número de personas de la receta es " ?rp
                            " y se parece a tu preferencia (" ?np
                            ") con similitud " (format nil "%.2f" ?sim) ".")))
  )

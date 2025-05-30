(defmodule cargar-recetas (import MAIN ?ALL) (export ?ALL))

; ESTE MÓDULO SERÍA EL DE obtener-propiedades, le he cambiado el nombre porque es el mismo archivo que el de la p2

(defrule carga_recetas
(declare (salience 1000))
=>
(load-facts "recetas.txt")
)

; tengo que sacar todos los ingredientes de cada receta
(defrule guardar_ingredientes
(declare (salience 997))
	?receta <- (receta (ingredientes $?ingredientes))
	=>
	(foreach ?ingrediente ?ingredientes
		(assert (ingrediente ?ingrediente))
        ;(printout t "Ingrediente: " ?ingrediente crlf)
        )
)

; generalizar los tipos de ingredientes
(defrule determinar-carnes
(declare (salience 996))
    (es-carne (name ?carne)) 
    (ingrediente ?i&:(str-index (lowcase (sym-cat ?carne)) 
                               (lowcase (sym-cat ?i))))
    (not (es-carne (name ?i)))  
    => 
    (assert (es-carne (name ?i)))
    ;(printout t "Carne identificada (por patrón): " ?i crlf)
)


(defrule determinar-pescados
(declare (salience 996))
    (es-pescado (name ?pez)) 
    (ingrediente ?i&:(str-index (lowcase (sym-cat ?pez)) 
                               (lowcase (sym-cat ?i))))
    (not (es-pescado (name ?i)))  
    => 
    (assert (es-pescado (name ?i)))
    ;(printout t "Pescado identificada (por patrón): " ?i crlf)
)

(defrule determinar-mariscos
(declare (salience 996))
    (es-marisco (name ?marisco)) 
    (ingrediente ?i&:(str-index (lowcase (sym-cat ?marisco)) 
                               (lowcase (sym-cat ?i))))
    (not (es-marisco (name ?i)))  
    => 
    (assert (es-marisco (name ?i)))
    ;(printout t "Marisco identificada (por patrón): " ?i crlf)
)

(defrule determinar-reposteria
(declare (salience 996))
    (es-reposteria (name ?reposteria)) 
    (ingrediente ?i&:(str-index (lowcase (sym-cat ?reposteria)) 
                               (lowcase (sym-cat ?i))))
    (not (es-reposteria (name ?i)))  
    => 
    (assert (es-reposteria (name ?i)))
    ;(printout t "Reposteria identificada (por patrón): " ?i crlf)
)

(defrule determinar-pasta
(declare (salience 996))
    (es-pasta (name ?p)) 
    (ingrediente ?i&:(str-index (lowcase (sym-cat ?p)) 
                               (lowcase (sym-cat ?i))))
    (not (es-pasta (name ?i)))  
    => 
    (assert (es-pasta (name ?i)))
    ;(printout t "Pasta identificada (por patrón): " ?i crlf)
)

(defrule determinar-lacteo
(declare (salience 996))
    (es-lacteo (name ?p)) 
    (ingrediente ?i&:(str-index (lowcase (sym-cat ?p)) 
                               (lowcase (sym-cat ?i))))
    (not (es-lacteo (name ?i)))  
    => 
    (assert (es-lacteo (name ?i)))
    ;(printout t "Lacteo identificado (por patrón): " ?i crlf)
)

(defrule determinar-picante
(declare (salience 996))
    (es-picante (name ?p)) 
    (ingrediente ?i&:(str-index (lowcase (sym-cat ?p)) 
                               (lowcase (sym-cat ?i))))
    (not (es-picante (name ?i)))  
    => 
    (assert (es-picante (name ?i)))
    ;(printout t "Picante identificado (por patrón): " ?i crlf)
)

(defrule determinar-gluten
(declare (salience 996))
    (con-gluten (name ?p)) 
    (ingrediente ?i&:(str-index (lowcase (sym-cat ?p)) 
                               (lowcase (sym-cat ?i))))
    (not (con-gluten (name ?i)))  
    => 
    (assert (con-gluten (name ?i)))
    ;(printout t "Gluten identificado (por patrón): " ?i crlf)
)


(defrule determinar-legumbre
(declare (salience 996))
    (es-legumbre (name ?p)) 
    (ingrediente ?i&:(str-index (lowcase (sym-cat ?p)) 
                               (lowcase (sym-cat ?i))))
    (not (es-legumbre (name ?i)))  
    => 
    (assert (es-legumbre (name ?i)))
    ;(printout t "Legumbre identificado (por patrón): " ?i crlf)
)


;;;EJERCICIO: Añadir reglas para  deducir tal y como tu lo harias (usando razonamiento basado en conocimiento):
;;;  1) cual o cuales son los ingredientes relevantes de una receta

; si tiene el ingrediente en el nombre -> ese ingrediente es relevante. Tambien si algun ingrediente contiene parcialmente el nombre de la receta
; esta función sirve para ignorar palabras cortas en el nomre de la receta
(deffunction palabra-significativa? (?palabra)
   (bind ?longitud (str-length ?palabra))
   ; Ignorar palabras de menos de 3 letras o artículos/preposiciones
   (return (and (>= ?longitud 3)
                (not (member$ (lowcase ?palabra) (create$ "de" "a" "la" "las" "los" "el" "en" "con" "para")))))
)

; si la receta es "pastel de coco", el ingrediente coco_rallado es relevante -> miramos si alguna palabra de la receta aparece parcialmente en el ingrediente
(deffunction alguna-palabra-en-ingrediente (?nombre ?ingrediente)
   (bind ?result FALSE)
   (bind ?ing (lowcase (sym-cat ?ingrediente))) ; Convertir ingrediente a string
   
   (if (stringp ?nombre) then
      (bind ?palabras-nombre (explode$ ?nombre))
      (foreach ?palabra ?palabras-nombre
         (if (and (palabra-significativa? ?palabra)
                 (str-index (lowcase ?palabra) ?ing)) then
            (bind ?result TRUE))))
   
   (return ?result)
)

; si el ingrediente aparece parcialmente o por completo en el nombre de la receta -> es relevante
(defrule ingrediente_relevante_por_nombre
(declare (salience 80))
    ?receta <- (receta (nombre ?nombre) (ingredientes $? ?ingrediente $?))
    =>
    (if (alguna-palabra-en-ingrediente ?nombre ?ingrediente) then 
        (assert (propiedad_receta (tipo ingrediente_relevante) (receta ?receta) (ingrediente ?ingrediente)))
    )
    ;(printout t "Receta: " ?nombre " Ingrediente relevante: " ?ingrediente crlf)
)

; si es paella -> ingrediente relevante es arroz
(defrule nombre-paella-arroz-relevante
(declare (salience 80))
    ?r <- (receta (nombre ?nombre) (ingredientes $? ?i $?))
    (test (or (eq (lowcase ?nombre) "paella") 
              (str-index "paella" (lowcase ?nombre))
              (str-index "risotto" (lowcase ?nombre))))
    (test (eq (lowcase ?i) arroz))
    =>
    (assert (propiedad_receta (tipo ingrediente_relevante) (receta ?r) (ingrediente ?i)))
    ;(printout t "Receta: " ?nombre " Ingrediente relevante: " ?i crlf)
)

; si es jugo -> agua es relevante
(defrule nombre-jugo-agua-relevante
(declare (salience 80))
    ?r <- (receta (nombre ?nombre) (ingredientes $? ?i $?))
    (test (or (eq (lowcase ?nombre) "jugo") 
              (str-index "jugo" (lowcase ?nombre))))
    (test (eq (lowcase ?i) agua))
    =>
    (assert (propiedad_receta (tipo ingrediente_relevante) (receta ?r) (ingrediente ?i)))
    ;(printout t "Receta: " ?nombre " Ingrediente relevante: " ?i crlf)
)

; en una receta donde hay 4 ingredientes o menos -> todos los ingredientes son relevantes
(defrule pocos-ingredientes-todos-relevantes
(declare (salience 80))
    ?r <- (receta (nombre ?n) (ingredientes $?i&:(<= (length$ ?i) 4)))
    =>
    (foreach ?ing ?i
        (assert (propiedad_receta (tipo ingrediente_relevante) (receta ?r) (ingrediente ?ing)))
        ;(printout t "Receta: " ?n " Ingrediente relevante: " ?ing crlf)
        )
)

; poner que se quiten los condimentos
(defrule eliminar-condimento-de-ingredientes-relevantes
   ?pr <- (propiedad_receta (tipo ingrediente_relevante) (receta ?r) (ingrediente ?ing))
   (es-condimento (name ?ing))
   =>
   (retract ?pr)
   ;(printout t "Eliminado ingrediente relevante por ser condimento: " ?ing " de la receta " ?r crlf)
)

; si es postre -> los ingredientes de reposteria y la fruta son relevantes
(defrule ingredientes-relevantes-postre
(declare (salience 80))
   ?r <- (receta (nombre ?nombre) (tipo_plato postre) (ingredientes $? ?ing $?))
   (or (es-reposteria (name ?ing)) (es-fruta (name ?ing)) (eq pan ?ing))
   =>
   (assert (propiedad_receta (tipo ingrediente_relevante) (receta ?r) (ingrediente ?ing)))
)
; si es entrante -> los mariscos y embutidos son relevantes
(defrule ingredientes-relevantes-entrante-marisco
(declare (salience 80))
   ?r <- (receta (nombre ?nombre) (tipo_plato entrante) (ingredientes $? ?ing $?))
   (or (es-marisco (name ?ing)) (es-embutido (name ?ing)))
   =>
   (assert (propiedad_receta (tipo ingrediente_relevante) (receta ?r) (ingrediente ?ing)))
)


; si es desayuno_merienda ->  los lacteos, frutas, reposteria y embutidos son relevantes
(defrule ingredientes-relevantes-desayuno
(declare (salience 80))
   ?r <- (receta (nombre ?nombre) (tipo_plato desayuno_merienda) (ingredientes $? ?ing $?))
   (or (es-lacteo (name ?ing)) (es-embutido (name ?ing)) (es-fruta (name ?ing)) (es-reposteria (name ?ing)))
   =>
   (assert (propiedad_receta (tipo ingrediente_relevante) (receta ?r) (ingrediente ?ing)))
)


; si es plato_principal -> la carne y el pescado son relevantes
(defrule ingredientes-relevantes-principal
(declare (salience 80))
   ?r <- (receta (nombre ?nombre) (tipo_plato plato_principal) (ingredientes $? ?ing $?))
   (or (es-carne (name ?ing)) (es-pescado (name ?ing)))
   =>
   (assert (propiedad_receta (tipo ingrediente_relevante) (receta ?r) (ingrediente ?ing)))
)
; si es primer_plato -> la verdura y la legumbre es relevante 
(defrule ingredientes-relevantes-primer-plato
(declare (salience 80))
   ?r <- (receta (nombre ?nombre) (tipo_plato primer_plato) (ingredientes $? ?ing $?))
   (or (es-legumbre (name ?ing)) (es-verdura (name ?ing)))
   =>
   (assert (propiedad_receta (tipo ingrediente_relevante) (receta ?r) (ingrediente ?ing)))
)
; si es acompañamiento (como paatas fritas, ensalada...) -> todos menos los condimentos son relevantes
(defrule ingredientes-relevantes-acompanamiento
(declare (salience 80))
   ?r <- (receta (nombre ?nombre) (tipo_plato acompanamiento) (ingredientes $?ings))
   =>
   (foreach ?i ?ings
      (assert (propiedad_receta (tipo ingrediente_relevante) (receta ?r) (ingrediente ?i))))
)

; si no tiene ingredientes relevantes -> todos los no condiemtnos son relevantes
(defrule marcar-no-condimentos-como-relevantes-si-no-hay-otros
   (declare (salience 79))
   ?r <- (receta (nombre ?nombre) (ingredientes $?ings))
   ;; No hay ningún ingrediente relevante para esta receta
   (not (propiedad_receta (tipo ingrediente_relevante) (receta ?r) (ingrediente ?)))
   =>
   (foreach ?ing ?ings
      (if (not (any-factp ((?f es-condimento)) (eq ?f:name ?ing)))
         then
            (assert (propiedad_receta (tipo ingrediente_relevante) (receta ?r) (ingrediente ?ing)))))
)




;;;  2) modificar las recetas completando cual seria el/los tipo_plato asociados a una receta, SOLO PUEDE SER UN TIPO DE PLATO
;;;;;;;; especialmente para el caso de que no incluya ninguno

;;; Reglas de inferencia para tipo_plato
(deffunction ingredientes_postre ($?ingredientes)
   (bind ?count 0)

   ;; Si hay al menos un ingrediente que sea carne/pescado/marisco → false
   (foreach ?ing $?ingredientes
      (if (or
            (any-factp ((?f es-carne)) (eq ?f:name ?ing))
            (any-factp ((?f es-pescado)) (eq ?f:name ?ing))
            (any-factp ((?f es-marisco)) (eq ?f:name ?ing)))
         then
            (return FALSE)))

   ;; Si hay al menos 2 ingredientes de repostería → true
   (foreach ?ing $?ingredientes
      (if (any-factp ((?f es-reposteria)) (eq ?f:name ?ing))
         then
            (bind ?count (+ ?count 1))))

   (return (>= ?count 2))
)

(deffunction ingredientes_entrante ($?ingredientes)
   ;; Si no contiene carne, pescado, ni repostería, ni pasta -> marisco es normal que tenga un entrante
   (foreach ?ing $?ingredientes
      (if (or
            (any-factp ((?f es-carne)) (eq ?f:name ?ing))
            (any-factp ((?f es-pescado)) (eq ?f:name ?ing))
            (any-factp ((?f es-pasta)) (eq ?f:name ?ing))
            (any-factp ((?f es-reposteria)) (eq ?f:name ?ing))
            )
         then
            (return FALSE)))

   (return TRUE)
)

(defrule es-postre
(declare (salience 90))
    ?receta <- (receta (nombre ?nombre)
                      (ingredientes $?ingredientes)
                      (tipo_plato $?tp&:(= (length$ $?tp) 0))) ; que no tenga tipo de plato
    =>
    (if (ingredientes_postre $?ingredientes) then
        ;(modify ?receta (tipo_plato postre))
        ;(printout t "Identificado como POSTRE: " ?nombre crlf)
    )
    (if (ingredientes_postre $?ingredientes) then
        (modify ?receta (tipo_plato postre))
    )
)

(defrule es-entrante
(declare (salience 90))
    ?receta <- (receta (nombre ?nombre)
                      (ingredientes $?ingredientes)
                      (tipo_plato $?tp&:(= (length$ $?tp) 0))
                      )  ; que no tenga tipo de plato    
    =>
    (if (ingredientes_entrante $?ingredientes) then 
        ;(printout t "Voy a identificar como ENTRANTE: " ?nombre crlf)
        )
    (if (ingredientes_entrante $?ingredientes) then 
        (modify ?receta (tipo_plato entrante))
    )
)

(deffunction ingredientes_primer_plato ($?ingredientes)
   (bind ?tiene_base FALSE)
   (bind ?tiene_proteina FALSE)

    ; si tiene pasta, legumbres o arroz y NO tiene proteina
   (foreach ?ing $?ingredientes
      (if (or 
            (any-factp ((?f es-pasta)) (eq ?f:name ?ing))
            (any-factp ((?f es-legumbre)) (eq ?f:name ?ing))
            (eq ?ing arroz))
         then (bind ?tiene_base TRUE))

      (if (or 
            (any-factp ((?f es-carne)) (eq ?f:name ?ing))
            (any-factp ((?f es-pescado)) (eq ?f:name ?ing)))
         then (bind ?tiene_proteina TRUE)))

   (return (and ?tiene_base (not ?tiene_proteina)))
)

(defrule es-primer-plato
(declare (salience 90))
   ?receta <- (receta (nombre ?nombre)
                      (ingredientes $?ingredientes)
                      (tipo_plato $?tp&:(= (length$ $?tp) 0)))
   =>
   (if (ingredientes_primer_plato $?ingredientes) then
      ;(printout t "Identificado como PRIMER PLATO: " ?nombre crlf)
      (modify ?receta (tipo_plato primer_plato)))
)


(deffunction ingredientes_acompanamiento ($?ingredientes)
   (bind ?n (length$ $?ingredientes))
   (return (or (= ?n 2) (= ?n 3)))
)

(defrule es-acompanamiento
(declare (salience 90))
    ?receta <- (receta (nombre ?nombre)
                       (ingredientes $?ingredientes)
                       (tipo_plato $?tp&:(= (length$ $?tp) 0)))
    =>
    (if (ingredientes_acompanamiento $?ingredientes) then
        ;(printout t "Identificado como ACOMPAÑAMIENTO: " ?nombre crlf)
        (modify ?receta (tipo_plato acompanamiento))
    )
)


(deffunction ingredientes_desayuno_merienda ($?ingredientes)
   (bind ?es_dulce TRUE)
   (bind ?es_salado TRUE)

   ;; Comprobamos si todos los ingredientes son fruta o lacteo (dulce)
   (foreach ?ing $?ingredientes
      (if (not (or
            (any-factp ((?f es-fruta)) (eq ?f:name ?ing))
            (any-factp ((?f es-lacteo)) (eq ?f:name ?ing))))
         then
            (bind ?es_dulce FALSE)))

   ;; Comprobamos si todos los ingredientes son pan o embutido (salado)
   (foreach ?ing $?ingredientes
      (if (not (or
            (eq ?ing pan)
            (any-factp ((?f es-embutido)) (eq ?f:name ?ing))))
         then
            (bind ?es_salado FALSE)))

   (return (or ?es_dulce ?es_salado))
)

(defrule es-desayuno-merienda
(declare (salience 90))
    ?receta <- (receta (nombre ?nombre)
                       (ingredientes $?ingredientes)
                       (tipo_plato $?tp&:(= (length$ $?tp) 0)))
    =>
    (if (ingredientes_desayuno_merienda $?ingredientes) then
        ;(printout t "Identificado como DESAYUNO/MERIENDA: " ?nombre crlf)
        (modify ?receta (tipo_plato desayuno_merienda))
    )
)

(defrule es-plato-principal
(declare (salience 89)) ; prioridad baja para que se aplique al final
    ?receta <- (receta (nombre ?nombre)
                       (tipo_plato $?tp&:(= (length$ $?tp) 0)))
    =>
    ;(printout t "Identificado como PLATO PRINCIPAL (por defecto): " ?nombre crlf)
    (modify ?receta (tipo_plato plato_principal))
)




;;;  3) si una receta es: vegana, vegetariana, de dieta, picante, sin gluten o sin lactosa

(defrule receta-vegana
(declare (salience 50))
   (receta (nombre ?n) (ingredientes $?ingredientes))
   (not (es-carne (name ?i&:(member$ ?i $?ingredientes))))
   (not (es-pescado (name ?i&:(member$ ?i $?ingredientes))))
   (not (es-marisco (name ?i&:(member$ ?i $?ingredientes))))
   (not (es-lacteo (name ?i&:(member$ ?i $?ingredientes))))
   (not (es-embutido (name ?i&:(member$ ?i $?ingredientes))))
   (not (find$ "huevo" $?ingredientes))
   =>
   (assert (propiedad_receta (tipo es_vegana) (receta ?n)))
   ;(printout t "La receta " ?n " es vegana." crlf)
)

(defrule receta-vegetariana
(declare (salience 50))
   (receta (nombre ?n) (ingredientes $?ingredientes))
   (not (es-carne (name ?i&:(member$ ?i $?ingredientes))))
   (not (es-pescado (name ?i&:(member$ ?i $?ingredientes))))
   (not (es-marisco (name ?i&:(member$ ?i $?ingredientes))))
   (not (es-embutido (name ?i&:(member$ ?i $?ingredientes))))
   =>
   (assert (propiedad_receta (tipo es_vegetariana) (receta ?n)))
   ;(printout t "La receta " ?n " es vegetariana." crlf)
)

(defrule receta-de-dieta
(declare (salience 50))
   (receta (nombre ?n) (numero_personas ?num_personas)
           (Calorias ?calorias) (Grasa ?grasa) (tipo_copcion ?tipo_copcion))
   (test (and (numberp ?calorias) (numberp ?num_personas) (> ?num_personas 0)))
   
   ; Verificamos si las calorías y la grasa por persona están por debajo de los límites establecidos
   (test (and (< (/ ?calorias ?num_personas) 300) (< (/ ?grasa ?num_personas) 15)))
   (not (find$ "azucar" $?ingredientes))
   (test (neq ?tipo_copcion frito))
   =>
   (assert (propiedad_receta (tipo es_de_dieta) (receta ?n)))
   ;(printout t "La receta " ?n " es de dieta." crlf)
)


(defrule receta-picante
(declare (salience 50))
   (receta (nombre ?n) (ingredientes $? ?ingrediente $?))
   (es-picante (name ?ingrediente))
   =>
   (assert (propiedad_receta (tipo es_picante) (receta ?n)))
   ;(printout t "La receta " ?n " es picante." crlf)
)

(defrule receta-sin-gluten
(declare (salience 50))
   (receta (nombre ?n) (ingredientes $?ingredientes))
   (not (con-gluten (name ?i&:(member$ ?i $?ingredientes))))
   (not (es-pasta (name ?i&:(member$ ?i $?ingredientes))))
   =>
   (assert (propiedad_receta (tipo es_sin_gluten) (receta ?n)))
   ;(printout t "La receta " ?n " es sin gluten." crlf)
)

(defrule receta-sin-lactosa
(declare (salience 50))
   (receta (nombre ?n) (ingredientes $?ingredientes))
   (not (es-lacteo (name ?i&:(member$ ?i $?ingredientes))))
   =>
   (assert (propiedad_receta (tipo es_sin_lactosa)(receta ?n)))
   ;(printout t "La receta " ?n " es sin lactosa." crlf)
)


;;;FORMATO DE LOS HECHOS: 
;  
;       (propiedad_receta ingrediente_relevante ?r ?a)
;       (propiedad_receta es_vegetariana ?r) 
;       (propiedad_receta es_vegana ?r)
;       (propiedad_receta es_sin_gluten ?r)
;       (propiedad_receta es_picante ?r)
;       (propiedad_receta es_sin_lactosa ?r)
;       (propiedad_receta es_de_dieta ?r)







 

 
; CARMEN AZORÍN MARTÍ

(defmodule MAIN
   (export ?ALL)
)

; DEFINO LOS TEMPLATES
(deftemplate info-faltante (slot campo))
(deftemplate justificacion (slot campo) (slot valor))

(deftemplate receta
(slot nombre)   ; necesario
(slot introducido_por) ; necesario
(slot numero_personas)  ; necesario
(multislot ingredientes)   ; necesario
(slot dificultad (allowed-symbols alta media baja muy_baja))  ; necesario
(slot duracion)  ; necesario
(slot enlace)  ; necesario
(multislot tipo_plato (allowed-symbols entrante primer_plato plato_principal postre desayuno_merienda acompanamiento)) ; necesario, introducido o deducido en este ejercicio
(slot coste)  ; opcional relevante
(slot tipo_copcion (allowed-symbols crudo cocido a_la_plancha frito al_horno al_vapor))   ; opcional
(multislot tipo_cocina)   ;opcional
(slot temporada)  ; opcional
;;;; Estos slot se calculan, se haria mediante un algoritmo que no vamos a implementar para este prototipo, lo usamos con la herramienta indicada y lo introducimos
(slot Calorias) ; calculado necesario
(slot Proteinas) ; calculado necesario
(slot Grasa) ; calculado necesario
(slot Carbohidratos) ; calculado necesario
(slot Fibra) ; calculado necesario
(slot Colesterol) ; calculado necesario
)

(deftemplate propiedad_receta
   (slot tipo)
   (slot receta)
   (slot ingrediente))


(deftemplate es-carne (slot name))
(deftemplate es-pescado (slot name))
(deftemplate es-marisco (slot name))
(deftemplate es-reposteria (slot name))
(deftemplate es-pasta (slot name))
(deftemplate es-lacteo (slot name))
(deftemplate es-embutido (slot name))
(deftemplate es-picante (slot name))
(deftemplate con-gluten (slot name))
(deftemplate es-legumbre (slot name))
(deftemplate es-fruta (slot name))
(deftemplate es-verdura (slot name))
(deftemplate es-condimento (slot name))


; hechos de clasificación de alimentos
(deffacts clasificacion-ingredientes
  ;; Carnes
  (es-carne (name pollo))
  (es-carne (name pavo))
  (es-carne (name ternera))
  (es-carne (name cerdo))
  (es-carne (name cordero))
  (es-carne (name carne))
  
  ;; Pescados
  (es-pescado (name pescado))
  (es-pescado (name salmon))
  (es-pescado (name atun))
  (es-pescado (name bacalao))
  (es-pescado (name merluza))
  
  ;; Mariscos
  (es-marisco (name langostino))
  (es-marisco (name gamba))
  (es-marisco (name mejillon))
  (es-marisco (name almeja))
  
  ;; Ingredientes de repostería
  (es-reposteria (name azucar))
  (es-reposteria (name harina))
  (es-reposteria (name chocolate))
  (es-reposteria (name leche))
  (es-reposteria (name huevo))
  (es-reposteria (name vainilla))
  (es-reposteria (name miel))
  (es-reposteria (name fruta))
  (es-reposteria (name levadura))

  (es-pasta (name macarrones))
  (es-pasta (name lasania))
  (es-pasta (name espaguetis))
  (es-pasta (name tallarines))
  (es-pasta (name pasta))

  (es-lacteo (name leche))
  (es-lacteo (name yogur))
  (es-lacteo (name queso))
  (es-lacteo (name parmesano))

  (es-embutido (name jamon))
  (es-embutido (name salchichon))
  (es-embutido (name chorizo))

  (es-picante (name aji))
  (es-picante (name chile))
  (es-picante (name jalapeño))
  (es-picante (name jalapenio))
  (es-picante (name picante))
  (es-picante (name curry))
  (es-picante (name sriracha))

  (con-gluten (name harina))
  (con-gluten (name trigo))
  (con-gluten (name pan))

  (es-legumbre (name garbanzos))
  (es-legumbre (name lenteja))
  (es-legumbre (name frijoles))
  (es-legumbre (name guisante))
  (es-legumbre (name judia))
  (es-legumbre (name tomate))

  (es-fruta (name mora))
  (es-fruta (name fresa))
  (es-fruta (name coco))
  (es-fruta (name platano))
  (es-fruta (name limon))

  (es-condimento (name sal))
   (es-condimento (name pimienta))
   (es-condimento (name ketchup))
   (es-condimento (name mayonesa))
   (es-condimento (name mostaza))
   (es-condimento (name aceite))
   (es-condimento (name vinagre))
   (es-condimento (name ajo))
   (es-condimento (name perejil))
   (es-condimento (name pimenton))
   (es-condimento (name comino))
   (es-condimento (name canela))
   (es-condimento (name nuez_moscada))
   (es-condimento (name azucar))
   (es-condimento (name miel))
   (es-condimento (name soja))
   (es-condimento (name guindilla))
   (es-condimento (name orégano))
   (es-condimento (name albahaca))

)

(deftemplate preferencia-alimentaria
   (slot tipo)) ; vegana, vegetariana, sin_lactosa, sin_gluten, ninguna

(deftemplate preferencia-picante
   (slot desea)) ; si o no

(deftemplate momento
   (slot tipo)) ; desayuno, comida, postre

(deftemplate recomendacion
   (slot receta))

(deftemplate propuesta
   (slot receta))

; COMIENZAN LAS REGLAS
(defrule carga-modulos
    (declare (salience 1000))
    =>
    (load "cargar-recetas.clp")
    (load "pedir-informacion.clp")
    (load "obtener-compatibles.clp")
    (load "proponer-receta.clp")
)

(defrule iniciar-sistema
(declare (salience 100))
   =>
   (printout t crlf "🎉 Bienvenido al sistema de recomendación de recetas 🎉" crlf)
   (assert (estado activo))
   (assert (info-faltante (campo preferencia-alimentaria)))
   (assert (info-faltante (campo preferencia-picante)))
   (assert (info-faltante (campo momento)))
   (focus cargar-recetas)
)

(defrule control-informacion
(declare (salience 90))
   (estado activo)
   (info-faltante (campo ?x))
   =>
   (focus pedir-informacion)
)

(defrule control-compatibles
(declare (salience 80))
   (estado activo)
   (not (info-faltante (campo ?)))
   =>
   (focus obtener-compatibles)
   (assert (estado recomendar))
   )

(defrule buscar-siguiente-propuesta
(declare (salience 70))
   (estado recomendar)
   ;(not (propuesta (receta ?)))
   ;?r <- (recomendacion (receta ?rec))
   =>
   ;(retract ?r)
   ;(assert (propuesta (receta ?rec)))
   (focus proponer-receta))


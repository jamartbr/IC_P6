(defmodule pedir-informacion-incertidumbre (export ?ALL) (import MAIN ?ALL))


(defrule preguntar-dificultad
  (declare (salience 100))
  (not (preferencia (campo dificultad)))
  =>
  (printout t crlf "¿Qué dificultad prefieres? (muy_baja, baja, media, alta): " )
  (bind ?d (read))
  (assert (preferencia (campo dificultad) (valor ?d) (certeza 1.0))))

(defrule preguntar-duracion
  (not (preferencia (campo duracion)))
  =>
  (printout t "¿Qué duración prefieres? (por ejemplo: 30m, 45m): " )
  (bind ?t (read))
  (assert (preferencia (campo duracion) (valor ?t) (certeza 1.0))))

(defrule preguntar-personas
  (not (preferencia (campo numero_personas)))
  =>
  (printout t "¿Para cuántas personas vas a cocinar?: " )
  (bind ?n (read))
  (assert (preferencia (campo numero_personas) (valor ?n) (certeza 1.0))))
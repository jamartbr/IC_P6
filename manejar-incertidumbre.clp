(defmodule manejar-incertidumbre (export ?ALL) (import MAIN ?ALL))

(deffacts variables_difusas
(variable duracion)
(variable dificultad)
(variable numero_personas)
)

(deffacts conjuntos_difusos
(cd duracion baja 0 0 15 30)   ; entre 36 y 37
(cd duracion media 15 30 45 60)
(cd duracion alta 45 60 90 90 )

(cd peso bajo 0 0 50 60)     ; aproximadamente  menos de 50
(cd peso medio 55 62 70 75)  ; aproximadamente entre 62 y 70
(cd peso alto 70 80 300 300) ; aproximadamente mas de 80

(cd dosis cero 0 0 0 0)
(cd dosis baja 4 5 5 6.5)    ; aproximadamente 5
(cd dosis media 6 7 7 8)     ; aproximadamente 7
(cd dosis alta 8 9 9 10)     ; aprximadamente 9
(cd dosis muy_alta 10 11 12 12) ; aproximadamente mas de 10

(cd edad infantil 0 0 8 10) ; aproximadamente menos de 10
(cd edad joven 10 15 20 30)   ; aproximadamente entre 10 y 20
(cd edad adulto 20 30 50 60) ; aproximadamente entre 30 y 50
(cd edad anciano 60 80 100 100) ; aproximadamente mas de 60
)

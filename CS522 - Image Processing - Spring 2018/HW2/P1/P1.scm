;;definitions
;functions
(define (blueness blueim) (apply (lambda(r g b) (/ b (+ r g b 1))) (color-image->rgb blueim)))
(define blend
  (lambda (fgc bgc binim)
    (lambda (i j) ;(cond (pred1 val1) (else valN))
      (cond ((= (image-ref binim i j) 0) (image-ref bgc i j)) (else (image-ref fgc i j))))))
;variables
(define fg (read-color-image "bluescreen27.ppm"))
(define row (image-rows fg))
(define col (image-cols fg))
(define starwars (read-color-image "starwars.ppm"))
(define bg (image-crop starwars 0 0 row col))
(define fg-rgb (color-image->rgb fg))
(define fgr (list-ref fg-rgb 0))
(define fgg (list-ref fg-rgb 1))
(define fgb (list-ref fg-rgb 2))
(define bg-rgb (color-image->rgb bg))
(define bgr (list-ref bg-rgb 0))
(define bgg (list-ref bg-rgb 1))
(define bgb (list-ref bg-rgb 2))

;;operations
(define fg-bin (< (blueness bluescreen27) 0.485))
(define mixr (make-image row col (blend fgr bgr fg-bin)))
(define mixg (make-image row col (blend fgg bgg fg-bin)))
(define mixb (make-image row col (blend fgb bgb fg-bin)))
(define mix (rgb->color-image mixr mixg mixb))
(write-color-image mix "bluescreen27-in-starwars.ppm")

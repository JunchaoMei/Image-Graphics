;function flag
(define flag
	(lambda(height)
		(define width (* height (/ 4 3)))
		(define a (/ height 2))
		(define b (/ width 2))
		(define r (/ a 2))
		(define r2 (* r r))
		(define japanses
			lambda(x y)
			(cond 
				((<= (+ (* (- x a) (- x a)) (* (- y b) (- y b))) r2) 155)
				(else 255)
			)
		)
		(make-image height width (japanses(x y)))
	)
)
;test function
(flag 300)

;if not using function
(define height 300)
(define width (* height (/ 4 3)))
(define a (/ height 2))
(define b (/ width 2))
(define r (/ a 2))
(define r2 (* r r))
(define japanses
	lambda(x y)
	(cond 
		((<= (+ (* (- x a) (- x a)) (* (- y b) (- y b))) r2) 155)
		(else 255)
	)
)
(make-image height width (japanses(x y)))
(define R (read-image "R.pgm"))

;function {flip-image}
(define flip-image
	(lambda(image)
		;get [Y,X]
		(define rows (image-rows image))
		(define Y (- rows 1))
		(define cols (image-cols image))	
		(define X (- cols 1))
		;function {exchange}
		(define exchange
			(lambda(i j)
				(define temp (image-ref image i j))
				(image-set! image i j (image-ref image (- Y i) (- X j)))
				(image-set! image (- Y i) (- X j) temp)
			)
		)
			;(exchange 149 49)
		;loop	
		(define loop
			(lambda(i j)
				(cond
					((<= i Y)
						(cond 
							((<= j X)
								(exchange i j)
								(set! j (+ j 1)))
							(else
								(set! j 0)
								(set! i (+ i 1)))
						)
					)
				)
				(loop i j)
			)
		)
		(loop 0 0)
	)
)
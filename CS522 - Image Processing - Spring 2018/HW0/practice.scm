;loop of scheme
(define loop
	(lambda(x y)
		(if (<= x y)
			(begin (display x) (set! x (+ x 1))
				(loop x y)))))

;function {exchange}
(define exchange
	(lambda(i j)
		(define temp (image-ref R i j))
		(image-set! R i j (image-ref R (- Y i) (- X j)))
		(image-set! R (- Y i) (- X j) temp)
	)
)

(define rows (image-rows R))
(define Y (- rows 1))
(define cols (image-cols R))	
(define X (- cols 1))

(image-set! R 50 150 0)

(define loop
	(lambda(i j)
		(cond
			(<= i Y)
				(cond
					((<= j X)
						(exchange i j)
						(set! j (+ j 1)))
					(else
						(set! j 0)
						(set! i (+ i 1)))
					(loop i j)
				)
		)
	)
)

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
		;loop
		(define loop
			(lambda()
			(exchange 149 49)))
		(loop)
	)
)
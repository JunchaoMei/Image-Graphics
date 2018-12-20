(define R (read-image "R.pgm"))
;(image-transpose R)

;function {flip-image}
(define flip-image
	(lambda(image)
		;get [Y,X]
		(define rows (image-rows image))
		(define Y (- rows 1))
		(define cols (image-cols image))	
		(define X (- cols 1))
		(make-image rows cols (lambda(i j) ((image-ref image (- Y i) (- X j)))))
	)
)

;if not using function
(define rows (image-rows R))
(define Y (- rows 1))
(define cols (image-cols R))	
(define X (- cols 1))
(make-image rows cols (lambda(i j) ((image-ref R (- Y i) (- X j)))))
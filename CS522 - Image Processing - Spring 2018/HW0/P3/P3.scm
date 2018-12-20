(define R (read-image "R.pgm"))
(write-image (image-transpose R) "R-transpose.pgm")

;;if not using function
(define rows (image-rows R))
(define Y (- rows 1))
(define cols (image-cols R))	
(define X (- cols 1))
(define flipped0 (make-image rows cols (lambda(i j) (image-ref R (- Y i) (- X j)))))
flipped0

;;function {flip-image}
(define flip-image
  (lambda(image)
    (make-image rows cols (lambda(i j) (image-ref image (- (image-rows image) 1 i) (- (image-cols image) 1 j))))))
;;test function
(define flipped1 (flip-image R))
flipped1
;;use function
(write-image (flip-image R) "R-flip.pgm")
